namespace PetShop.Models
{
    public sealed record VerifyNetworkDto(
        string Ip,
        bool IsCompanyNetwork,
        string CompanyPrefix,
        string? XClientIp,
        string? RealClientIp,
        string? XForwardedFor,
        string? RemoteIp,
        string? ResolvedFrom,
        string? XRealIp
    );

    public sealed record ShiftOptionDto(int ScheduleId, int? StaffId, string? StaffName, DateOnly WorkDate, int? ShiftId, TimeSpan StartTime, TimeSpan EndTime, string? Status);

    public sealed record StaffOptionDto(int StaffId, string Name);

    public sealed record CreatePassShiftRequestDto(
        int StaffId,
        DateOnly FromDate,
        int FromScheduleId,
        int ToStaffId,
        string? Reason
    );

    public sealed record CreateSwapShiftRequestDto(
        int StaffId,
        DateOnly FromDate,
        DateOnly ToDate,
        int FromScheduleId,
        int ToScheduleId,
        int ToStaffId,
        string? Reason
    );

    public sealed record ShiftExchangeActionResultDto(string Status, string Message);

    public sealed record PendingRequestDto(
        int RequestId,
        int? EmployeeId,
        string? EmployeeName,
        int? ToStaffId,
        string Type,
        DateOnly FromDate,
        DateOnly? ToDate,
        int? FromShiftId,
        int? ToShiftId,
        string Reason,
        string Status,
        DateTime CreatedAt
    );

    public sealed record MyRequestDto(
        int RequestId,
        int? ToStaffId,
        string? ToStaffName,
        string Type,
        DateOnly FromDate,
        DateOnly? ToDate,
        string Status,
        string Reason,
        DateTime CreatedAt,
        bool ApprovedByTo
    );
}
