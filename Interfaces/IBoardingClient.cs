using PetShop.Models;

namespace PetShop.Interfaces;

public interface IBoardingClient
{
    Task<FrontendApiResult<IReadOnlyList<BoardingRoom>>> GetRoomsAsync(CancellationToken ct = default);
    Task<FrontendApiResult<BoardingRoom>> GetRoomByIdAsync(int roomId, CancellationToken ct = default);
    Task<FrontendApiResult<IReadOnlyList<BoardingAvailabilityDto>>> GetAvailabilityAsync(CancellationToken ct = default);
    Task<FrontendApiResult<BoardingCatalogDto>> GetCatalogAsync(CancellationToken ct = default);
    Task<FrontendApiResult<BoardingCheckoutResponse>> CheckoutAsync(BoardingCheckoutRequest request, CancellationToken ct = default);

    Task<FrontendApiResult<IReadOnlyList<BoardingBookingDto>>> GetAllBookingsAsync(CancellationToken ct = default);
    Task<FrontendApiResult<bool>> ConfirmCheckinAsync(int bookingId, CancellationToken ct = default);
    Task<FrontendApiResult<bool>> ConfirmCheckoutAsync(int bookingId, CancellationToken ct = default);
    Task<FrontendApiResult<bool>> RejectBookingAsync(int bookingId, string reason, CancellationToken ct = default);

    Task<FrontendApiResult<BoardingBookingPaymentStatusResult>> GetBookingPaymentStatusAsync(int bookingId, CancellationToken ct = default);
}
