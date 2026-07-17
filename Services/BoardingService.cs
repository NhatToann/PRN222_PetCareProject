using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services
{
    public sealed class BoardingService : IBoardingService
    {
        private readonly IBoardingRepository _repo;

        public BoardingService(IBoardingRepository repo)
        {
            _repo = repo;
        }

        public Task<IReadOnlyList<BoardingRoom>> GetAllRoomsAsync(CancellationToken ct = default)
        {
            return _repo.GetAllRoomsAsync(ct);
        }

        public Task<BoardingRoom?> GetRoomByIdAsync(int roomId, CancellationToken ct = default)
        {
            return _repo.GetRoomByIdAsync(roomId, ct);
        }

        public async Task<IReadOnlyList<BoardingBookingDto>> GetAllBookingsAsync(CancellationToken ct = default)
        {
            return await _repo.GetAllBookingsAsync(ct);
        }

        public async Task<bool> ConfirmCheckinAsync(int bookingId, CancellationToken ct = default)
        {
            return await _repo.ConfirmCheckinAsync(bookingId, ct);
        }

        public async Task<bool> ConfirmCheckoutAsync(int bookingId, CancellationToken ct = default)
        {
            return await _repo.ConfirmCheckoutAsync(bookingId, ct);
        }

        public async Task<IReadOnlyList<BoardingAvailabilityDto>> GetAvailabilityAsync(CancellationToken ct = default)
        {
            return await _repo.GetAvailabilityAsync(ct);
        }
    }
}
