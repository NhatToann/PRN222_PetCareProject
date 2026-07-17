using PetShop.Models;

namespace PetShop.Interfaces;

public interface ICheckoutClient
{
    Task<FrontendApiResult<FrontendCheckoutResponse>> CheckoutAsync(FrontendCheckoutRequest request, CancellationToken cancellationToken = default);
}
