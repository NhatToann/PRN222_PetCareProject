using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface ISpaBookingService
    {
        Task<IReadOnlyList<PetSummaryDto>> GetPetsAsync(int customerId, CancellationToken ct = default);
        Task<IReadOnlyList<SpaServiceDto>> GetSpaServicesAsync(CancellationToken ct = default);
        Task<SpaAvailabilityResponse> CheckAvailabilityAsync(DateTime start, int durationMin, int quantity, CancellationToken ct = default);
        Task<BookingSlotValidationResult> ValidateBookingSlotAsync(BookingSlotValidationRequest request, CancellationToken ct = default);
        Task<SpaBookingEstimateDto> EstimateAsync(int customerId, SpaBookingEstimateRequest request, CancellationToken ct = default);
        Task<SpaBookingDto> CreateBookingAsync(int customerId, CreateSpaBookingRequest request, CancellationToken ct = default);
        Task<IReadOnlyList<SpaBookingDto>> GetHistoryAsync(int customerId, CancellationToken ct = default);
        Task<IReadOnlyList<SpaBookingDto>> GetAllHistoryAsync(CancellationToken ct = default);
        Task<SpaBookingInvoiceDto?> GetInvoiceAsync(int bookingId, CancellationToken ct = default);
        Task UpdateStatusAsync(int bookingId, string status, CancellationToken ct = default);
        Task<int> UpsertReviewAsync(int customerId, CreateSpaReviewRequest request, CancellationToken ct = default);
    }
}
