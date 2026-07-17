namespace PetShop.Models
{
    public sealed record AttendanceItemDto(
        int AttendanceId,
        DateTime CheckIn,
        DateTime? CheckOut,
        double? TotalHours,
        string? Status,
        bool IsLate
    );

    /// <summary>Thông tin chi tiết một ca làm việc.</summary>
    public sealed record ShiftDetailDto(
        int ScheduleId,
        TimeSpan StartTime,
        TimeSpan EndTime,
        string Label
    );

    /// <summary>Kết quả tính công theo luật Pets4Care.</summary>
    /// <param name="workHours">Số giờ làm việc thực tế (tính bằng giờ, làm tròn 2 chữ số).</param>
    /// <param name="earlyMinutes">Số phút về sớm so với giờ kết thúc ca (chỉ khi có checkout, ngược lại = 0).</param>
    /// <param name="isMissingCheckout">True khi nhân viên không bấm checkout trước khi ca kết thúc.</param>
    public sealed record WorkHoursResult(double WorkHours, double EarlyMinutes, bool IsMissingCheckout);

    /// <summary>Bản ghi chấm công kèm thông tin ca để tính công / xem lịch sử.</summary>
    public sealed record AttendanceWithScheduleDto(
        int AttendanceId,
        DateTime CheckIn,
        DateTime? CheckOut,
        double? TotalHours,
        string? Status,
        bool IsLate,
        int ScheduleId,
        DateOnly WorkDate,
        TimeSpan StartTime,
        TimeSpan EndTime,
        double WorkHours,
        double EarlyMinutes,
        bool IsMissingCheckout,
        string WorkDateDisplay
    );

    public sealed record AttendanceOverviewDto(
        int StaffId,
        DateTime ServerTime,
        bool HasShiftToday,
        IReadOnlyList<ShiftDetailDto> TodayShifts,
        bool IsCheckedIn,
        bool IsCompletedToday,
        bool CanToggle,
        AttendanceItemDto? TodayRecord,
        IReadOnlyList<AttendanceItemDto> History
    );

    public sealed record AttendanceToggleResponseDto(
        string Status,
        string Message,
        AttendanceOverviewDto Overview
    );

    /// <summary>Danh sách nhân viên chưa checkout – dùng cho Admin dashboard.</summary>
    public sealed record UnclosedAttendanceDto(
        int AttendanceId,
        int StaffId,
        string Name,
        string? Position,
        DateTime CheckIn,
        TimeSpan? ShiftEnd,
        string? Status,
        TimeSpan Elapsed   // thời gian đã làm: now - CheckIn
    );

    public sealed record UnclosedAttendanceListDto(
        int Count,
        IReadOnlyList<UnclosedAttendanceDto> Data
    );
}
