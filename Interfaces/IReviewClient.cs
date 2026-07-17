using PetShop.Models;

namespace PetShop.Interfaces;

public interface IReviewClient
{
    Task<FrontendApiResult<IReadOnlyList<ReviewDisplayDto>>> GetProductReviewsAsync(int productId, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<ProductReviewUpsertResult>> UpsertProductReviewAsync(
        int productId,
        int customerId,
        CreateProductReviewRequestDto request,
        CancellationToken cancellationToken = default);
}
