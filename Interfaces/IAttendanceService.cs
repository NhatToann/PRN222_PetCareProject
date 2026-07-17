using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IAttendanceService
    {
        /// <summary>
        /// Tính công theo luật Pets4Care:
        /// - Có checkout: workTime = checkout - checkIn, earlyMinutes = shiftEnd - checkout (cắt checkout về shiftEnd nếu checkout > shiftEnd)
        /// - Không checkout: workTime = shiftEnd - checkIn, isMissingCheckout = true
        /// </summary>
        WorkHoursResult CalculateWorkHours(AttendanceRecord attendance, WorkSchedule schedule);

        /// <summary>Trả về overview cho nhân viên (dùng cho frontend tab Chấm công).</summary>
        Task<AttendanceOverviewDto> GetOverviewAsync(int staffId, CancellationToken ct = default);

        /// <summary>
        /// Toggle check-in / check-out cho nhân viên.
        /// Check-in: tạo AttendanceRecord mới.
        /// Check-out: cập nhật CheckOut, TotalHours, Status.
        /// </summary>
        Task<AttendanceToggleResponseDto> ToggleAsync(int staffId, CancellationToken ct = default);

        /// <summary>
        /// Lấy tất cả bản ghi chấm công gần đây của nhân viên (dùng để xem lịch sử / tính lương).
        /// </summary>
        Task<IReadOnlyList<AttendanceWithScheduleDto>> GetAttendanceWithScheduleAsync(
            int staffId,
            DateOnly? from = null,
            DateOnly? to = null,
            CancellationToken ct = default);

        /// <summary>Kiểm tra nhân viên đã chấm công ngày nào chưa.</summary>
        Task<bool> HasAttendanceForDateAsync(int staffId, DateOnly date, CancellationToken ct = default);

        /// <summary>Lấy danh sách nhân viên chưa checkout (Admin dashboard).</summary>
        Task<UnclosedAttendanceListDto> GetUnclosedAsync(DateOnly? date = null, CancellationToken ct = default);

    }
}
