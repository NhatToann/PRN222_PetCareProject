using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services
{
    public sealed class ProductService_temp : IProductService_temp
    {
        private readonly IProductRepository_temp _repo;

        public ProductService_temp(IProductRepository_temp repo)
        {
            _repo = repo;
        }

        public Task<IReadOnlyList<ProductDto_temp>> GetAllAsync(string? keyword = null, int? categoryId = null, CancellationToken ct = default)
        {
            return _repo.GetAllAsync(keyword, categoryId, ct);
        }

        public Task<IReadOnlyList<ProductCategoryFilterDto_temp>> GetCategoriesAsync(string? keyword = null, CancellationToken ct = default)
        {
            return _repo.GetCategoriesAsync(keyword, ct);
        }

        public Task<ProductDto_temp?> GetByIdAsync(int productId, CancellationToken ct = default)
        {
            return _repo.GetByIdAsync(productId, ct);
        }
    }

}
