using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Repositories
{
    public sealed class ProductRepository_temp : IProductRepository_temp
    {
        private readonly ShopPetDatabaseContext _db;

        public ProductRepository_temp(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        public async Task<IReadOnlyList<ProductDto_temp>> GetAllAsync(string? keyword = null, int? categoryId = null, CancellationToken ct = default)
        {
            var query = BuildBaseQuery(keyword);

            if (categoryId.HasValue)
            {
                query = query.Where(p => p.CategoryId == categoryId.Value);
            }

            var products = await query
                .OrderBy(p => p.ProductId)
                .ToListAsync(ct);

            var productIds = products.Select(p => p.ProductId).ToList();
            var reviewStats = await _db.Reviews
                .AsNoTracking()
                .Where(r => r.ProductId != null && productIds.Contains(r.ProductId.Value))
                .GroupBy(r => r.ProductId!.Value)
                .Select(g => new
                {
                    ProductId = g.Key,
                    AvgRating = g.Average(x => (double)x.Rating),
                    ReviewCount = g.Count()
                })
                .ToListAsync(ct);

            var ratingMap = reviewStats.ToDictionary(
                x => x.ProductId,
                x => new { x.AvgRating, x.ReviewCount });

            return products
                .Select(p =>
                {
                    var hasRating = ratingMap.TryGetValue(p.ProductId, out var rs);
                    return new ProductDto_temp(
                        p.ProductId,
                        p.Name ?? string.Empty,
                        p.Price,
                        p.StockQuantity,
                        p.Description,
                        p.ImageUrl,
                        p.CategoryId,
                        p.Category?.Name,
                        p.SupplierId,
                        p.Supplier?.NameCompany,
                        hasRating ? Math.Round(rs!.AvgRating, 1) : 0d,
                        hasRating ? rs!.ReviewCount : 0
                    );
                })
                .ToList();
        }

        public async Task<IReadOnlyList<ProductCategoryFilterDto_temp>> GetCategoriesAsync(string? keyword = null, CancellationToken ct = default)
        {
            var query = BuildBaseQuery(keyword);

            var categoryRows = await query
                .Where(p => p.CategoryId.HasValue)
                .Select(p => new
                {
                    CategoryId = p.CategoryId,
                    CategoryName = p.Category != null ? p.Category.Name : null
                })
                .ToListAsync(ct);

            return categoryRows
                .Where(x => x.CategoryId.HasValue && !string.IsNullOrWhiteSpace(x.CategoryName))
                .GroupBy(x => new { CategoryId = x.CategoryId!.Value, CategoryName = x.CategoryName! })
                .Select(g => new ProductCategoryFilterDto_temp(
                    g.Key.CategoryId,
                    g.Key.CategoryName,
                    g.Count()
                ))
                .OrderBy(x => x.CategoryName)
                .ToList();
        }

        private IQueryable<Product> BuildBaseQuery(string? keyword)
        {
            var query = _db.Products
                .AsNoTracking()
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .AsQueryable();

            if (string.IsNullOrWhiteSpace(keyword))
            {
                return query;
            }

            var tokens = keyword
                .Trim()
                .Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Where(t => t.Length > 0)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToArray();

            foreach (var token in tokens)
            {
                var t = token;
                query = query.Where(p =>
                    EF.Functions.Like(EF.Functions.Collate(p.Name ?? string.Empty, "SQL_Latin1_General_CP1_CI_AI"), $"%{t}%") ||
                    EF.Functions.Like(EF.Functions.Collate(p.Description ?? string.Empty, "SQL_Latin1_General_CP1_CI_AI"), $"%{t}%") ||
                    EF.Functions.Like(EF.Functions.Collate(p.Category != null ? p.Category.Name : string.Empty, "SQL_Latin1_General_CP1_CI_AI"), $"%{t}%") ||
                    EF.Functions.Like(EF.Functions.Collate(p.Supplier != null ? p.Supplier.NameCompany ?? string.Empty : string.Empty, "SQL_Latin1_General_CP1_CI_AI"), $"%{t}%")
                );
            }

            return query;
        }

        public async Task<ProductDto_temp?> GetByIdAsync(int productId, CancellationToken ct = default)
        {
            var product = await _db.Products
                .AsNoTracking()
                .Where(p => p.ProductId == productId)
                .Select(p => new ProductDto_temp(
                    p.ProductId,
                    p.Name,
                    p.Price,
                    p.StockQuantity,
                    p.Description,
                    p.ImageUrl,
                    p.CategoryId,
                    p.Category != null ? p.Category.Name : null,
                    p.SupplierId,
                    p.Supplier != null ? p.Supplier.NameCompany : null,
                    0d,
                    0
                ))
                .FirstOrDefaultAsync(ct);

            if (product is null)
            {
                return null;
            }

            var stats = await _db.Reviews
                .AsNoTracking()
                .Where(r => r.ProductId == productId)
                .GroupBy(_ => 1)
                .Select(g => new
                {
                    AvgRating = g.Average(x => (double)x.Rating),
                    ReviewCount = g.Count()
                })
                .FirstOrDefaultAsync(ct);

            if (stats is null)
            {
                return product;
            }

            return product with
            {
                AvgRating = Math.Round(stats.AvgRating, 1),
                ReviewCount = stats.ReviewCount
            };
        }
    }
}
