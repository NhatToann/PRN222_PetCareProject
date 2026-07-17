using PetShop.Models;

namespace PetShop.Interfaces;

public interface IOrderClient
{
    Task<FrontendApiResult<IReadOnlyList<FrontendOrderSummary>>> GetHistoryAsync(int customerId, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<FrontendOrderDetail>> GetDetailAsync(int orderId, int customerId, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<FrontendOrderSummary>> MarkDeliveredAsync(int orderId, int customerId, CancellationToken cancellationToken = default);
}
