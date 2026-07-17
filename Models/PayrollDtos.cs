namespace PetShop.Models
{
    public sealed record PayrollSummaryDto(
        int PayrollId,
        int? StaffId,
        string? StaffName,
        DateOnly PeriodStart,
        DateOnly PeriodEnd,
        double? TotalHours,
        decimal? HourlyRate,
        decimal? BaseSalary,
        int? ActualShifts,
        int? StandardShifts,
        decimal? TotalSalary,
        DateTime? CreatedAt
    );

    public sealed record GeneratePayrollDto(
        int StaffId,
        DateOnly PeriodStart,
        DateOnly PeriodEnd
    );

    public sealed record GenerateAllPayrollDto(
        DateOnly PeriodStart,
        DateOnly PeriodEnd
    );

    public sealed record StaffSalaryConfigDto(
        int SalaryId,
        int StaffId,
        string? StaffName,
        decimal? HourlyRate,
        decimal? MonthlyBaseSalary,
        int? StandardShifts,
        DateTime? UpdatedAt
    );

    public sealed record UpdateSalaryConfigDto(
        int StaffId,
        decimal? MonthlyBaseSalary,
        int? StandardShifts,
        decimal? HourlyRate
    );

    public sealed record PayrollResultDto(
        string Status,
        string Message,
        PayrollSummaryDto? Record
    );

    public sealed record PayrollListResultDto(
        string Status,
        string Message,
        IReadOnlyList<PayrollSummaryDto> Records
    );

    public sealed record PayrollConfigResultDto(
        string Status,
        string Message,
        StaffSalaryConfigDto? Config
    );

    public sealed record PayrollAttendanceDetailDto(
        DateOnly Date,
        double? TotalHours,
        string? Status
    );

    public sealed record StaffPayrollDetailDto(
        int StaffId,
        string? StaffName,
        DateOnly PeriodStart,
        DateOnly PeriodEnd,
        int ActualShifts,
        int StandardShifts,
        decimal MonthlyBaseSalary,
        decimal TotalSalary,
        IReadOnlyList<PayrollAttendanceDetailDto> AttendanceDetails
    );
}
