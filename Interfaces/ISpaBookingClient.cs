using PetShop.Models;

namespace PetShop.Interfaces;

public interface ISpaBookingClient
{
    Task<FrontendApiResult<IReadOnlyList<PetSummaryDto>>> GetPetsAsync(int currentCustomerId, CancellationToken ct = default);

    Task<FrontendApiResult<IReadOnlyList<SpaServiceDto>>> GetSpaServicesAsync(CancellationToken ct = default);

    Task<FrontendApiResult<SpaAvailabilityResponse>> CheckAvailabilityAsync(DateTime start, int durationMin, int quantity, CancellationToken ct = default);

    Task<FrontendApiResult<SpaBookingEstimateDto>> EstimateAsync(int currentCustomerId, SpaBookingEstimateRequest req, CancellationToken ct = default);

    Task<FrontendApiResult<SpaBookingDto>> CreateAsync(int currentCustomerId, CreateSpaBookingRequest req, CancellationToken ct = default);

    Task<FrontendApiResult<IReadOnlyList<SpaBookingDto>>> GetHistoryAsync(int currentCustomerId, CancellationToken ct = default);

    Task<FrontendApiResult<SpaBookingInvoiceDto?>> GetInvoiceAsync(int bookingId, int currentCustomerId, CancellationToken ct = default);

    Task<FrontendApiResult<object>> UpdateStatusAsync(int bookingId, int currentCustomerId, string status, CancellationToken ct = default);

    Task<FrontendApiResult<object>> SubmitReviewAsync(int currentCustomerId, CreateSpaReviewRequest req, CancellationToken ct = default);

    Task<FrontendApiResult<PayOSCheckoutResult>> CreateSpaPayOSPaymentAsync(int bookingId, IReadOnlyList<int>? bookingIds, string returnUrl, string cancelUrl, CancellationToken ct = default);

    Task<FrontendApiResult<PayOSPaymentStatusResult>> GetPayOSStatusAsync(int orderCode, CancellationToken ct = default);
}