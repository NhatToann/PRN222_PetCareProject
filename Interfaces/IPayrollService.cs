using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IPayrollService
    {
        Task<PayrollListResultDto> GeneratePayrollForStaffAsync(int staffId, DateOnly periodStart, DateOnly periodEnd, CancellationToken ct = default);
        Task<PayrollListResultDto> GenerateAllPayrollAsync(DateOnly periodStart, DateOnly periodEnd, CancellationToken ct = default);
        Task<IReadOnlyList<PayrollSummaryDto>> GetPayrollHistoryAsync(int? staffId, CancellationToken ct = default);
        Task<StaffPayrollDetailDto?> GetStaffPayrollDetailAsync(int staffId, DateOnly periodStart, DateOnly periodEnd, CancellationToken ct = default);
        Task<IReadOnlyList<StaffSalaryConfigDto>> GetAllSalaryConfigsAsync(CancellationToken ct = default);
        Task<PayrollConfigResultDto> UpdateSalaryConfigAsync(UpdateSalaryConfigDto dto, CancellationToken ct = default);
        Task<PayrollConfigResultDto> GetSalaryConfigAsync(int staffId, CancellationToken ct = default);
    }
}
