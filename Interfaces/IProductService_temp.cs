using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IProductService_temp
    {
        Task<IReadOnlyList<ProductDto_temp>> GetAllAsync(string? keyword = null, int? categoryId = null, CancellationToken ct = default);
        Task<IReadOnlyList<ProductCategoryFilterDto_temp>> GetCategoriesAsync(string? keyword = null, CancellationToken ct = default);
        Task<ProductDto_temp?> GetByIdAsync(int productId, CancellationToken ct = default);
    }

}
