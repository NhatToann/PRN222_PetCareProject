using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface ISpaBookingRepository
    {
        Task<IReadOnlyList<PetSummaryDto>> GetPetsByCustomerIdAsync(int customerId, CancellationToken ct = default);
        Task<IReadOnlyList<SpaServiceDto>> GetActiveSpaServicesAsync(CancellationToken ct = default);
        Task<(decimal UnitPrice, int DurationMin, string ServiceName)?> GetServicePricingAsync(int serviceId, int? breedId, CancellationToken ct = default);
        Task<int> CountSpaBookingsInTimeSlotAsync(DateTime start, DateTime end, CancellationToken ct = default);
        Task<int> CountAnySpaBookingsInTimeSlotAsync(DateTime start, DateTime end, CancellationToken ct = default);
        Task<int> CreateBookingAsync(Booking booking, CancellationToken ct = default);
        Task AddBookingServiceAsync(BookingService bookingService, CancellationToken ct = default);
        Task DeleteBookingsAsync(IReadOnlyList<int> bookingIds, CancellationToken ct = default);
        Task<IReadOnlyList<SpaBookingDto>> GetSpaBookingsByCustomerIdAsync(int customerId, CancellationToken ct = default);
        Task<IReadOnlyList<SpaBookingDto>> GetAllSpaBookingsAsync(CancellationToken ct = default);
        Task<SpaBookingInvoiceDto?> GetSpaBookingInvoiceAsync(int bookingId, CancellationToken ct = default);
        Task<bool> UpdateBookingStatusAsync(int bookingId, string status, CancellationToken ct = default);
        Task<bool> HasCompletedBookingAsync(int customerId, int bookingId, int serviceId, CancellationToken ct = default);
        Task<int?> GetReviewIdAsync(int customerId, int bookingId, int serviceId, CancellationToken ct = default);
        Task AddReviewAsync(Review review, CancellationToken ct = default);
        Task UpdateReviewAsync(Review review, CancellationToken ct = default);
    }
}
