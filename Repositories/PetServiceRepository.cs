using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Repositories
{
    public sealed class PetServiceRepository : IPetServiceRepository
    {
        private readonly ShopPetDatabaseContext _db;

        public PetServiceRepository(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        public async Task<IReadOnlyList<PetServiceDto>> GetAllAsync(CancellationToken ct = default)
        {
            return await _db.PetServices
                .AsNoTracking()
                .OrderBy(s => s.ServiceType)
                .ThenBy(s => s.Name)
                .Select(s => new PetServiceDto(
                    s.ServiceId,
                    s.Name,
                    s.Description,
                    s.Price,
                    s.Duration,
                    s.ServiceType,
                    s.Status,
                    s.CreatedAt,
                    s.UpdatedAt
                ))
                .ToListAsync(ct);
        }

        public async Task<PetServiceDetailDto?> GetDetailAsync(int serviceId, CancellationToken ct = default)
        {
            var service = await _db.PetServices
                .AsNoTracking()
                .Where(s => s.ServiceId == serviceId)
                .Select(s => new PetServiceDto(
                    s.ServiceId,
                    s.Name,
                    s.Description,
                    s.Price,
                    s.Duration,
                    s.ServiceType,
                    s.Status,
                    s.CreatedAt,
                    s.UpdatedAt
                ))
                .FirstOrDefaultAsync(ct);

            if (service == null)
            {
                return null;
            }

            var reviews = await _db.VServiceReviews
                .AsNoTracking()
                .Where(r => r.ServiceId == serviceId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new ReviewDisplayDto(
                    r.ReviewId,
                    r.ServiceId ?? 0,
                    r.Rating,
                    r.Comment,
                    null,
                    r.CustomerId,
                    r.CustomerName,
                    r.CreatedAt
                ))
                .ToListAsync(ct);

            var ratingSum = reviews.Where(r => r.Rating > 0).Sum(r => r.Rating);
            var ratingCount = reviews.Count(r => r.Rating > 0);
            var avgRating = ratingCount > 0 ? (double)ratingSum / ratingCount : 0d;

            return new PetServiceDetailDto(
                service,
                avgRating,
                reviews.Count,
                reviews
            );
        }
    }
}
