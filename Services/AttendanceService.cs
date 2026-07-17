using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;
using PetShop.Services;

namespace PetShop.Services
{
    public sealed class AttendanceService : IAttendanceService
    {
        private readonly ShopPetDatabaseContext _db;

        public AttendanceService(ShopPetDatabaseContext db) => _db = db;

        // ══════════════════════════════════════════════════════════════
        // LUẬT TÍNH CÔNG – Pets4Care
        //
        //  Bước 1: Lấy checkout
        //  Bước 2:
        //    ✅ Case 1 – Có checkout:
        //       if (checkout > ShiftEnd) checkout = ShiftEnd;
        //       workTime = checkout - CheckIn;
        //       earlyMinutes = ShiftEnd - checkout;
        //    ✅ Case 2 – Không checkout:
        //       workTime = ShiftEnd - CheckIn;
        //       isMissingCheckout = true;
        //       earlyMinutes = 0;
        // ══════════════════════════════════════════════════════════════

        public WorkHoursResult CalculateWorkHours(AttendanceRecord attendance, WorkSchedule schedule)
        {
            var shiftEnd = schedule.WorkDate.ToDateTime(schedule.EndTime);
            var checkIn = attendance.CheckIn;
            var effectiveCheckOut = attendance.CheckOut;

            // Case 1: Có checkout
            if (effectiveCheckOut.HasValue)
            {
                // Ép checkout về shiftEnd nếu checkout vượt quá giờ kết thúc ca
                var actualCheckOut = effectiveCheckOut.Value > shiftEnd ? shiftEnd : effectiveCheckOut.Value;

                var workMs = (actualCheckOut - checkIn).TotalMinutes;
                var workHours = Math.Max(0, Math.Round(workMs / 60.0, 2));

                var earlyMs = (shiftEnd - actualCheckOut).TotalMinutes;
                var earlyMinutes = Math.Max(0, Math.Round(earlyMs, 2));

                return new WorkHoursResult(workHours, earlyMinutes, false);
            }

            // Case 2: Không checkout – KHÔNG giả định giờ, đánh dấu thiếu
            var workMs2 = (shiftEnd - checkIn).TotalMinutes;
            var workHours2 = Math.Max(0, Math.Round(workMs2 / 60.0, 2));

            return new WorkHoursResult(workHours2, 0, true);
        }

        public async Task<AttendanceOverviewDto> GetOverviewAsync(int staffId, CancellationToken ct = default)
        {
            var now = DateTime.Now;
            var today = DateOnly.FromDateTime(now);
            var nowTime = TimeOnly.FromDateTime(now);

            var shiftsTodayRaw = await _db.WorkSchedules
                .AsNoTracking()
                .Where(w => w.StaffId == staffId && w.WorkDate == today)
                .OrderBy(w => w.StartTime)
                .ToListAsync(ct);
            var shiftsToday = WorkScheduleDedup.ByStaffDateTimeSlot(shiftsTodayRaw);

            var hasShiftToday = shiftsToday.Count > 0;

            // Trả về toàn bộ ca trong ngày kèm nhãn
            var todayShifts = shiftsToday
                .Select(s => new ShiftDetailDto(
                    s.ScheduleId,
                    s.StartTime.ToTimeSpan(),
                    s.EndTime.ToTimeSpan(),
                    ClassifyShiftLabel(s.StartTime, s.EndTime)
                ))
                .ToList();

            var historyEntities = await _db.AttendanceRecords
                .AsNoTracking()
                .Where(a => a.StaffId == staffId)
                .OrderByDescending(a => a.CheckIn)
                .Take(30)
                .ToListAsync(ct);

            var history = historyEntities
                .Select(MapAttendance)
                .ToList();

            var todayRecord = historyEntities
                .Where(a => DateOnly.FromDateTime(a.CheckIn) == today)
                .OrderByDescending(a => a.CheckIn)
                .FirstOrDefault();

            var todayDto = todayRecord is null ? null : MapAttendance(todayRecord);

            var isCheckedIn = todayRecord is not null && todayRecord.CheckOut is null;
            var isCompletedToday = todayRecord is not null && todayRecord.CheckOut is not null;

            // Có thể toggle nếu: chưa hoàn thành hôm nay VÀ còn ca đang/mở trong ngày
            var currentOrNext = PickShiftForOverview(shiftsToday, nowTime);
            var canToggle = isCompletedToday
                ? false
                : isCheckedIn
                    ? true
                    : hasShiftToday && currentOrNext is not null;

            return new AttendanceOverviewDto(
                staffId,
                now,
                hasShiftToday,
                todayShifts,
                isCheckedIn,
                isCompletedToday,
                canToggle,
                todayDto,
                history
            );
        }

        public async Task<AttendanceToggleResponseDto> ToggleAsync(int staffId, CancellationToken ct = default)
        {
            var now = DateTime.Now;
            var today = DateOnly.FromDateTime(now);
            var nowTime = TimeOnly.FromDateTime(now);

            var shiftsTodayRaw = await _db.WorkSchedules
                .AsNoTracking()
                .Where(w => w.StaffId == staffId && w.WorkDate == today)
                .OrderBy(w => w.StartTime)
                .ToListAsync(ct);
            var shiftsToday = WorkScheduleDedup.ByStaffDateTimeSlot(shiftsTodayRaw);

            if (shiftsToday.Count == 0)
            {
                var noShiftOverview = await GetOverviewAsync(staffId, ct);
                return new AttendanceToggleResponseDto(
                    "error",
                    "Hôm nay bạn không có ca làm.",
                    noShiftOverview
                );
            }

            if (!TryPickShiftForToggle(shiftsToday, nowTime, out var shiftToday))
            {
                var allShiftTimes = string.Join(" | ", shiftsToday
                    .OrderBy(s => s.StartTime)
                    .Select(s => $"{ClassifyShiftLabel(s.StartTime, s.EndTime)} ({s.StartTime:HH\\:mm}–{s.EndTime:HH\\:mm})"));

                var gapOverview = await GetOverviewAsync(staffId, ct);
                return new AttendanceToggleResponseDto(
                    "error",
                    $"Hiện không trong khung giờ ca làm. Các ca hôm nay: {allShiftTimes}. Vui lòng quay lại khi đến giờ ca tiếp theo.",
                    gapOverview
                );
            }

            var earlyAllowed = shiftToday.StartTime.AddMinutes(-15);
            var lateAllowed = shiftToday.StartTime.AddMinutes(15);

            if (nowTime < earlyAllowed)
            {
                var earlyOverview = await GetOverviewAsync(staffId, ct);
                return new AttendanceToggleResponseDto(
                    "error",
                    $"Bạn đến quá sớm. Ca {ClassifyShiftLabel(shiftToday.StartTime, shiftToday.EndTime)} bắt đầu lúc {shiftToday.StartTime:HH\\:mm}.",
                    earlyOverview
                );
            }

            if (nowTime > shiftToday.EndTime)
            {
                var endedOverview = await GetOverviewAsync(staffId, ct);
                return new AttendanceToggleResponseDto(
                    "error",
                    $"Ca {ClassifyShiftLabel(shiftToday.StartTime, shiftToday.EndTime)} ({shiftToday.StartTime:HH\\:mm}–{shiftToday.EndTime:HH\\:mm}) đã kết thúc.",
                    endedOverview
                );
            }

            var todayRecord = await _db.AttendanceRecords
                .Where(a => a.StaffId == staffId && DateOnly.FromDateTime(a.CheckIn) == today)
                .OrderByDescending(a => a.CheckIn)
                .FirstOrDefaultAsync(ct);

            if (todayRecord is not null && todayRecord.CheckOut is null)
            {
                todayRecord.CheckOut = now;

                // Tính TotalHours theo luật Pets4Care
                var result = CalculateWorkHours(todayRecord, shiftToday);
                todayRecord.TotalHours = result.WorkHours;

                if (string.IsNullOrWhiteSpace(todayRecord.Status) || todayRecord.Status == "Đang làm")
                {
                    todayRecord.Status = result.IsMissingCheckout
                        ? "Chưa checkout"
                        : "Hoàn thành";
                }

                await _db.SaveChangesAsync(ct);
                var overview = await GetOverviewAsync(staffId, ct);
                return new AttendanceToggleResponseDto("success", "Checkout thành công!", overview);
            }

            if (todayRecord is not null && todayRecord.CheckOut is not null)
            {
                var completedOverview = await GetOverviewAsync(staffId, ct);
                return new AttendanceToggleResponseDto(
                    "error",
                    "Bạn đã hoàn thành ca hôm nay.",
                    completedOverview
                );
            }

            var isLate = nowTime > lateAllowed && nowTime < shiftToday.EndTime;

            var newRecord = new AttendanceRecord
            {
                StaffId = staffId,
                CheckIn = now,
                CheckOut = null,
                TotalHours = null,
                Status = isLate ? "Đi muộn" : "Đang làm",
                CreatedAt = now,
                IsLate = isLate
            };

            _db.AttendanceRecords.Add(newRecord);
            await _db.SaveChangesAsync(ct);

            var checkedOverview = await GetOverviewAsync(staffId, ct);
            var message = isLate ? "Đi muộn! Đã check-in." : "Check-in thành công!";

            return new AttendanceToggleResponseDto("success", message, checkedOverview);
        }

        public async Task<IReadOnlyList<AttendanceWithScheduleDto>> GetAttendanceWithScheduleAsync(
            int staffId,
            DateOnly? from = null,
            DateOnly? to = null,
            CancellationToken ct = default)
        {
            var query = _db.AttendanceRecords
                .AsNoTracking()
                .Where(a => a.StaffId == staffId);

            if (from.HasValue)
                query = query.Where(a => DateOnly.FromDateTime(a.CheckIn) >= from.Value);
            if (to.HasValue)
                query = query.Where(a => DateOnly.FromDateTime(a.CheckIn) <= to.Value);

            var attendanceList = await query
                .OrderByDescending(a => a.CheckIn)
                .ToListAsync(ct);

            if (attendanceList.Count == 0)
                return Array.Empty<AttendanceWithScheduleDto>();

            var dates = attendanceList
                .Select(a => DateOnly.FromDateTime(a.CheckIn))
                .Distinct()
                .ToList();

            var scheduleMap = (await _db.WorkSchedules
                .AsNoTracking()
                .Where(s => s.StaffId == staffId && dates.Contains(s.WorkDate))
                .ToListAsync(ct))
                .GroupBy(s => s.WorkDate)
                .ToDictionary(g => g.Key, g => g.ToList());

            var results = new List<AttendanceWithScheduleDto>();

            foreach (var att in attendanceList)
            {
                var attDate = DateOnly.FromDateTime(att.CheckIn);

                // Tìm schedule phù hợp nhất trong ngày (ưu tiên ca đang active hoặc ca đầu tiên)
                var now = DateTime.Now;
                var nowTime = TimeOnly.FromDateTime(now);

                WorkSchedule? best = null;
                if (scheduleMap.TryGetValue(attDate, out var daySchedules))
                {
                    best = FindShiftInWindow(daySchedules, nowTime)
                        ?? daySchedules.OrderBy(s => s.StartTime).FirstOrDefault();
                }

                if (best is null) continue;

                var workHoursResult = CalculateWorkHours(att, best);

                results.Add(new AttendanceWithScheduleDto(
                    att.AttendanceId,
                    att.CheckIn,
                    att.CheckOut,
                    att.TotalHours,
                    att.Status,
                    att.IsLate ?? false,
                    best.ScheduleId,
                    best.WorkDate,
                    best.StartTime.ToTimeSpan(),
                    best.EndTime.ToTimeSpan(),
                    workHoursResult.WorkHours,
                    workHoursResult.EarlyMinutes,
                    workHoursResult.IsMissingCheckout,
                    best.WorkDate.ToString("dd/MM/yyyy")
                ));
            }

            return results;
        }

        public async Task<bool> HasAttendanceForDateAsync(int staffId, DateOnly date, CancellationToken ct = default)
        {
            return await _db.AttendanceRecords
                .AsNoTracking()
                .AnyAsync(a => a.StaffId == staffId && DateOnly.FromDateTime(a.CheckIn) == date, ct);
        }

        public async Task<UnclosedAttendanceListDto> GetUnclosedAsync(DateOnly? date = null, CancellationToken ct = default)
        {
            var targetDate = date ?? DateOnly.FromDateTime(DateTime.Now);

            var records = await _db.AttendanceRecords
                .AsNoTracking()
                .Include(a => a.Staff)
                .Where(a => a.CheckOut == null
                         && DateOnly.FromDateTime(a.CheckIn) == targetDate)
                .OrderBy(a => a.CheckIn)
                .ToListAsync(ct);

            if (records.Count == 0)
                return new UnclosedAttendanceListDto(0, []);

            var staffIds = records.Select(r => r.StaffId).Distinct().ToList();

            var schedules = await _db.WorkSchedules
                .AsNoTracking()
                .Where(s => s.StaffId.HasValue
                         && staffIds.Contains(s.StaffId.Value)
                         && s.WorkDate == targetDate)
                .ToListAsync(ct);

            var scheduleMap = schedules
                .GroupBy(s => s.StaffId!.Value)
                .ToDictionary(g => g.Key, g => g.OrderBy(s => s.StartTime).First());

            var data = records
                .Select(a =>
                {
                    scheduleMap.TryGetValue(a.StaffId, out var schedule);
                    return new UnclosedAttendanceDto(
                        a.AttendanceId,
                        a.StaffId,
                        a.Staff!.Name,
                        a.Staff.Position,
                        a.CheckIn,
                        schedule?.EndTime.ToTimeSpan(),
                        a.Status,
                        DateTime.Now - a.CheckIn
                    );
                })
                .ToList();

            return new UnclosedAttendanceListDto(data.Count, data);
        }

        // ── Giờ làm dịch vụ ───────────────────────────────────────────

        // ── private helpers ───────────────────────────────────────────

        private static bool TryPickShiftForToggle(
            IReadOnlyList<WorkSchedule> ordered,
            TimeOnly nowTime,
            out WorkSchedule shift)
        {
            shift = null!;
            if (ordered.Count == 0)
                return false;

            var active = FindShiftInWindow(ordered, nowTime);
            if (active is not null)
            {
                shift = active;
                return true;
            }

            return false;
        }

        private static WorkSchedule? PickShiftForOverview(IReadOnlyList<WorkSchedule> ordered, TimeOnly nowTime)
        {
            if (ordered.Count == 0)
                return null;

            var active = FindShiftInWindow(ordered, nowTime);
            if (active is not null)
                return active;

            if (nowTime < ordered[0].StartTime.AddMinutes(-15))
                return ordered[0];

            return null;
        }

        private static WorkSchedule? FindShiftInWindow(IReadOnlyList<WorkSchedule> ordered, TimeOnly nowTime)
        {
            foreach (var w in ordered)
            {
                var earlyAllowed = w.StartTime.AddMinutes(-15);
                if (nowTime >= earlyAllowed && nowTime <= w.EndTime)
                    return w;
            }
            return null;
        }

        private static string ClassifyShiftLabel(TimeOnly start, TimeOnly end)
        {
            // Ca tối: bắt đầu từ 19:00 trở đi — trực ca, không nhận đặt dịch vụ
            if (start >= new TimeOnly(19, 0, 0))
                return "Ca tối";
            // Ca chiều: bắt đầu từ 13:00 (sau khoảng nghỉ trưa 12:00–13:00)
            if (start >= new TimeOnly(13, 0, 0))
                return "Ca chiều";
            // Ca sáng: bắt đầu trước 12:00 (kết thúc trước 12:00 hoặc trùng giờ nghỉ trưa)
            return "Ca sáng";
        }

        private static AttendanceItemDto MapAttendance(AttendanceRecord x)
        {
            return new AttendanceItemDto(
                x.AttendanceId,
                x.CheckIn,
                x.CheckOut,
                x.TotalHours,
                x.Status,
                x.IsLate ?? false
            );
        }
    }
}