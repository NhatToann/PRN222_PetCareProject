using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IReviewRepository
    {
        Task<IReadOnlyList<ReviewDisplayDto>> GetServiceReviewsAsync(int serviceId, CancellationToken ct = default);
        Task<IReadOnlyList<ReviewDisplayDto>> GetProductReviewsAsync(int productId, CancellationToken ct = default);
        Task<ProductReviewUpsertResult> UpsertProductReviewAsync(int productId, int customerId, int orderId, int rating, string? comment, CancellationToken ct = default);
    }
}
