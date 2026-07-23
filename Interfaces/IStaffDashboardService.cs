using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IStaffDashboardService
    {
        Task<StaffDashboardSummaryDto> GetDashboardSummaryAsync(int staffId);
        Task<List<StaffBookingDto>> GetStaffBookingsAsync();
        Task<bool> UpdateBookingStatusAsync(int bookingId, string newStatus);
        Task<List<StaffScheduleDto>> GetStaffSchedulesAsync(int staffId);
        Task<bool> CheckInAsync(int scheduleId);
    }
}