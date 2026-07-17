using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services
{
    public sealed class PayrollService : IPayrollService
    {
        private readonly ShopPetDatabaseContext _db;

        public PayrollService(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        public async Task<PayrollListResultDto> GeneratePayrollForStaffAsync(
            int staffId, DateOnly periodStart, DateOnly periodEnd, CancellationToken ct = default)
        {
            var staff = await _db.Staff
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.StaffId == staffId, ct);

            if (staff is null)
                return new PayrollListResultDto("error", "Khong tim thay nhan vien.", []);

            var salaryConfig = await _db.StaffSalaries
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.StaffId == staffId, ct);

            decimal monthlyBase = (decimal)(salaryConfig?.MonthlyBaseSalary ?? 0);
            int standardShifts = salaryConfig?.StandardShifts ?? 26;

            if (monthlyBase == 0)
            {
                Console.WriteLine($"[GeneratePayrollForStaff] StaffId={staffId} — No MonthlyBaseSalary configured.");
                return new PayrollListResultDto("error",
                    $"Nhan vien #{staffId} chua duoc cau hinh luong thang (MonthlyBaseSalary). Vui long Admin cai dat luong truoc.", []);
            }

            if (periodEnd < periodStart)
                return new PayrollListResultDto("error", "Ngay ket thuc phai lon hon hoac bang ngay bat dau.", []);

            int actualShifts = await _db.AttendanceRecords
                .CountAsync(a => a.StaffId == staffId
                    && a.CheckIn >= periodStart.ToDateTime(TimeOnly.MinValue)
                    && a.CheckIn < periodEnd.AddDays(1).ToDateTime(TimeOnly.MinValue), ct);

            double totalHours = await _db.AttendanceRecords
                .Where(a => a.StaffId == staffId
                    && a.CheckIn >= periodStart.ToDateTime(TimeOnly.MinValue)
                    && a.CheckIn < periodEnd.AddDays(1).ToDateTime(TimeOnly.MinValue))
                .SumAsync(a => a.TotalHours ?? 0, ct);

            decimal totalSalary = Math.Round(monthlyBase * (actualShifts / (decimal)standardShifts), 2);

            var existing = await _db.PayrollRecords
                .FirstOrDefaultAsync(p =>
                    p.StaffId == staffId &&
                    p.PeriodStart == periodStart &&
                    p.PeriodEnd == periodEnd, ct);

            if (existing is not null)
            {
                existing.TotalHours = totalHours;
                existing.ActualShifts = actualShifts;
                existing.BaseSalary = monthlyBase;
                existing.TotalSalary = totalSalary;
                existing.CreatedAt = DateTime.Now;
            }
            else
            {
                _db.PayrollRecords.Add(new PayrollRecord
                {
                    StaffId = staffId,
                    PeriodStart = periodStart,
                    PeriodEnd = periodEnd,
                    TotalHours = totalHours,
                    ActualShifts = actualShifts,
                    BaseSalary = monthlyBase,
                    HourlyRate = salaryConfig?.HourlyRate,
                    TotalSalary = totalSalary,
                    CreatedAt = DateTime.Now,
                });
            }

            await _db.SaveChangesAsync(ct);

            var record = await _db.PayrollRecords
                .AsNoTracking()
                .Where(p => p.StaffId == staffId && p.PeriodStart == periodStart && p.PeriodEnd == periodEnd)
                .FirstAsync(ct);

            var dto = new PayrollSummaryDto(
                record.PayrollId, record.StaffId, staff.Name,
                record.PeriodStart, record.PeriodEnd,
                record.TotalHours, record.HourlyRate,
                record.BaseSalary, record.ActualShifts, standardShifts,
                record.TotalSalary, record.CreatedAt);

            Console.WriteLine($"[GeneratePayrollForStaff] StaffId={staffId}, Period={periodStart}→{periodEnd}, " +
                $"ActualShifts={actualShifts}, StandardShifts={standardShifts}, " +
                $"BaseSalary={monthlyBase}, TotalSalary={totalSalary}");

            return new PayrollListResultDto("success", $"Tinh luong thanh cong cho {staff.Name}.", [dto]);
        }

        public async Task<PayrollListResultDto> GenerateAllPayrollAsync(
            DateOnly periodStart, DateOnly periodEnd, CancellationToken ct = default)
        {
            var staffIds = await _db.Staff
                .AsNoTracking()
                .Select(s => s.StaffId)
                .ToListAsync(ct);

            var results = new List<PayrollSummaryDto>();
            foreach (var staffId in staffIds)
            {
                var result = await GeneratePayrollForStaffAsync(staffId, periodStart, periodEnd, ct);
                if (result.Status == "success" && result.Records.Count > 0)
                    results.Add(result.Records[0]);
            }

            return new PayrollListResultDto("success",
                $"Da tinh luong cho {results.Count} nhan vien.",
                results);
        }

        public async Task<IReadOnlyList<PayrollSummaryDto>> GetPayrollHistoryAsync(
            int? staffId, CancellationToken ct = default)
        {
            var records = await _db.PayrollRecords
                .AsNoTracking()
                .Where(p => staffId == null || p.StaffId == staffId)
                .OrderByDescending(p => p.PeriodEnd)
                .Take(100)
                .ToListAsync(ct);

            var staffIds = records.Where(r => r.StaffId.HasValue).Select(r => r.StaffId!.Value).Distinct();
            var staffNames = await _db.Staff
                .AsNoTracking()
                .Where(s => staffIds.Contains(s.StaffId))
                .ToDictionaryAsync(s => s.StaffId, s => s.Name, ct);

            var standardByStaff = await _db.StaffSalaries
                .AsNoTracking()
                .Where(s => staffIds.Contains(s.StaffId))
                .ToDictionaryAsync(s => s.StaffId, s => s.StandardShifts, ct);

            return records.Select(r => new PayrollSummaryDto(
                r.PayrollId, r.StaffId,
                r.StaffId.HasValue && staffNames.ContainsKey(r.StaffId.Value) ? staffNames[r.StaffId.Value] : null,
                r.PeriodStart, r.PeriodEnd,
                r.TotalHours, r.HourlyRate,
                r.BaseSalary, r.ActualShifts,
                r.StaffId.HasValue && standardByStaff.TryGetValue(r.StaffId.Value, out var std) ? std : null,
                r.TotalSalary, r.CreatedAt))
                .ToList();
        }

        public async Task<StaffPayrollDetailDto?> GetStaffPayrollDetailAsync(
            int staffId, DateOnly periodStart, DateOnly periodEnd, CancellationToken ct = default)
        {
            var staff = await _db.Staff
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.StaffId == staffId, ct);

            if (staff is null) return null;

            var salaryConfig = await _db.StaffSalaries
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.StaffId == staffId, ct);

            var attendances = await _db.AttendanceRecords
                .AsNoTracking()
                .Where(a => a.StaffId == staffId
                    && a.CheckIn >= periodStart.ToDateTime(TimeOnly.MinValue)
                    && a.CheckIn < periodEnd.AddDays(1).ToDateTime(TimeOnly.MinValue))
                .OrderBy(a => a.CheckIn)
                .Select(a => new PayrollAttendanceDetailDto(
                    DateOnly.FromDateTime(a.CheckIn),
                    a.TotalHours,
                    a.Status))
                .ToListAsync(ct);

            var payroll = await _db.PayrollRecords
                .AsNoTracking()
                .FirstOrDefaultAsync(p =>
                    p.StaffId == staffId && p.PeriodStart == periodStart && p.PeriodEnd == periodEnd, ct);

            decimal monthlyBase = (decimal)(salaryConfig?.MonthlyBaseSalary ?? 0);
            int standardShifts = salaryConfig?.StandardShifts ?? 26;
            int actualShifts = attendances.Count;
            decimal totalSalary = payroll?.TotalSalary
                ?? Math.Round(monthlyBase * (actualShifts / (decimal)standardShifts), 2);

            return new StaffPayrollDetailDto(
                staffId, staff.Name, periodStart, periodEnd,
                actualShifts, standardShifts, monthlyBase, totalSalary, attendances);
        }

        public async Task<IReadOnlyList<StaffSalaryConfigDto>> GetAllSalaryConfigsAsync(CancellationToken ct = default)
        {
            return await _db.StaffSalaries
                .AsNoTracking()
                .Include(s => s.Staff)
                .Where(s => s.Staff != null)
                .Select(s => new StaffSalaryConfigDto(
                    s.SalaryId, s.StaffId, s.Staff!.Name,
                    s.HourlyRate, (decimal?)s.MonthlyBaseSalary, s.StandardShifts,
                    s.UpdatedAt))
                .ToListAsync(ct);
        }

        public async Task<PayrollConfigResultDto> UpdateSalaryConfigAsync(
            UpdateSalaryConfigDto dto, CancellationToken ct = default)
        {
            var staff = await _db.Staff
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.StaffId == dto.StaffId, ct);

            if (staff is null)
                return new PayrollConfigResultDto("error", "Khong tim thay nhan vien.", null);

            if (dto.MonthlyBaseSalary.HasValue && dto.MonthlyBaseSalary < 3000000m)
                return new PayrollConfigResultDto("error", "Luong thang toi thieu la 3.000.000 VND.", null);

            if (dto.StandardShifts.HasValue && (dto.StandardShifts < 10 || dto.StandardShifts > 30))
                return new PayrollConfigResultDto("error", "So ca chuan phai tu 10 den 30 ca/thang.", null);

            var config = await _db.StaffSalaries
                .FirstOrDefaultAsync(s => s.StaffId == dto.StaffId, ct);

            if (config is null)
            {
                config = new StaffSalary
                {
                    StaffId = dto.StaffId,
                    MonthlyBaseSalary = (double)(dto.MonthlyBaseSalary ?? 0),
                    StandardShifts = dto.StandardShifts ?? 26,
                    HourlyRate = dto.HourlyRate,
                    UpdatedAt = DateTime.Now,
                };
                _db.StaffSalaries.Add(config);
            }
            else
            {
                if (dto.MonthlyBaseSalary.HasValue) config.MonthlyBaseSalary = (double)dto.MonthlyBaseSalary.Value;
                if (dto.StandardShifts.HasValue) config.StandardShifts = dto.StandardShifts;
                if (dto.HourlyRate.HasValue) config.HourlyRate = dto.HourlyRate;
                config.UpdatedAt = DateTime.Now;
            }

            await _db.SaveChangesAsync(ct);

            var result = await _db.StaffSalaries
                .AsNoTracking()
                .Include(s => s.Staff)
                .Where(s => s.StaffId == dto.StaffId)
                .FirstAsync(ct);

            var dto2 = new StaffSalaryConfigDto(
                result.SalaryId, result.StaffId, result.Staff!.Name,
                result.HourlyRate, (decimal?)result.MonthlyBaseSalary, result.StandardShifts,
                result.UpdatedAt);

            Console.WriteLine($"[UpdateSalaryConfig] StaffId={dto.StaffId}, MonthlyBase={dto.MonthlyBaseSalary}, StandardShifts={dto.StandardShifts}");

            return new PayrollConfigResultDto("success", $"Da cap nhat luong cho nhan vien {staff.Name}.", dto2);
        }

        public async Task<PayrollConfigResultDto> GetSalaryConfigAsync(int staffId, CancellationToken ct = default)
        {
            var config = await _db.StaffSalaries
                .AsNoTracking()
                .Include(s => s.Staff)
                .Where(s => s.StaffId == staffId)
                .FirstOrDefaultAsync(ct);

            if (config is null)
                return new PayrollConfigResultDto("error", "Chua co cau hinh luong cho nhan vien nay.", null);

            var dto = new StaffSalaryConfigDto(
                config.SalaryId, config.StaffId, config.Staff!.Name,
                config.HourlyRate, (decimal?)config.MonthlyBaseSalary, config.StandardShifts,
                config.UpdatedAt);

            return new PayrollConfigResultDto("success", "OK", dto);
        }
    }
}
