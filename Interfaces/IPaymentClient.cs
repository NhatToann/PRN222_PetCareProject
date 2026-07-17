using PetShop.Models;

namespace PetShop.Interfaces;

public interface IPaymentClient
{
    Task<FrontendApiResult<PayOSPaymentStatusResult>> GetPayOSStatusAsync(int orderCode, CancellationToken cancellationToken = default);
}
