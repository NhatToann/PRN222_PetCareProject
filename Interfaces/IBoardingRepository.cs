using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IBoardingRepository
    {
        Task<IReadOnlyList<BoardingRoom>> GetAllRoomsAsync(CancellationToken ct = default);
        Task<BoardingRoom?> GetRoomByIdAsync(int roomId, CancellationToken ct = default);
        Task<IReadOnlyList<BoardingBookingDto>> GetAllBookingsAsync(CancellationToken ct = default);
        Task<bool> ConfirmCheckinAsync(int bookingId, CancellationToken ct = default);
        Task<bool> ConfirmCheckoutAsync(int bookingId, CancellationToken ct = default);
        Task<bool> RejectBookingAsync(int bookingId, string reason, CancellationToken ct = default);
        Task<IReadOnlyList<BoardingAvailabilityDto>> GetAvailabilityAsync(CancellationToken ct = default);
    }
}
