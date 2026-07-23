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

        public Task<IReadOnlyList<BoardingBookingDto>> GetAllBookingsAsync(CancellationToken ct = default)
        {
            return _repo.GetAllBookingsAsync(ct);
        }

        public Task<bool> ConfirmCheckinAsync(int bookingId, CancellationToken ct = default)
        {
            return _repo.ConfirmCheckinAsync(bookingId, ct);
        }

        public Task<bool> ConfirmCheckoutAsync(int bookingId, CancellationToken ct = default)
        {
            return _repo.ConfirmCheckoutAsync(bookingId, ct);
        }

        public Task<bool> RejectBookingAsync(int bookingId, string reason, CancellationToken ct = default)
        {
            return _repo.RejectBookingAsync(bookingId, reason, ct);
        }

        public async Task<BoardingCatalogDto> GetCatalogAsync(CancellationToken ct = default)
        {
            // Each repository call creates its own DbContext via the factory,
            // so the two queries are safe to run concurrently.
            var roomsTask = _repo.GetAllRoomsAsync(ct);
            var availTask = _repo.GetAvailabilityAsync(ct);
            await Task.WhenAll(roomsTask, availTask);
            return new BoardingCatalogDto(roomsTask.Result, availTask.Result);
        }

        public Task<IReadOnlyList<BoardingAvailabilityDto>> GetAvailabilityAsync(CancellationToken ct = default)
        {
            return _repo.GetAvailabilityAsync(ct);
        }
    }
}
