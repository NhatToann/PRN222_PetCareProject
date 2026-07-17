using PetShop.Models;

namespace PetShop.Interfaces;

public interface IProductCatalogClient
{
    Task<ProductCatalogResult<IReadOnlyList<ProductDto_temp>>> GetProductsAsync(string? keyword = null, int? categoryId = null, CancellationToken cancellationToken = default);

    Task<ProductCatalogResult<IReadOnlyList<ProductCategoryFilterDto_temp>>> GetCategoriesAsync(string? keyword = null, CancellationToken cancellationToken = default);

    Task<ProductCatalogResult<ProductDto_temp?>> GetProductAsync(int productId, CancellationToken cancellationToken = default);
}
