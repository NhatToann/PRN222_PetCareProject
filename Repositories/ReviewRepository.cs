using System;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Repositories
{
    public sealed class ReviewRepository : IReviewRepository
    {
        private readonly ShopPetDatabaseContext _db;

        public ReviewRepository(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        public async Task<IReadOnlyList<ReviewDisplayDto>> GetServiceReviewsAsync(int serviceId, CancellationToken ct = default)
        {
            return await _db.VServiceReviews
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
        }

        public async Task<IReadOnlyList<ReviewDisplayDto>> GetProductReviewsAsync(int productId, CancellationToken ct = default)
        {
            // Lấy trực tiếp từ bảng Review theo product_id (đúng với yêu cầu SQL).
            // Join Customer để có customer_name hiển thị lên UI.
            return await (
                from r in _db.Reviews.AsNoTracking()
                where r.ProductId == productId
                join c in _db.Customers.AsNoTracking()
                    on r.CustomerId equals c.CustomerId
                    into cJoin
                from c in cJoin.DefaultIfEmpty()
                orderby r.CreatedAt descending
                select new ReviewDisplayDto(
                    r.ReviewId,
                    r.ServiceId ?? 0,
                    r.Rating,
                    r.Comment,
                    r.BookingId,
                    r.CustomerId,
                    c.Name,
                    r.CreatedAt
                )
            ).ToListAsync(ct);
        }

        public async Task<ProductReviewUpsertResult> UpsertProductReviewAsync(
            int productId,
            int customerId,
            int orderId,
            int rating,
            string? comment,
            CancellationToken ct = default)
        {
            var order = await _db.Orders
                .AsNoTracking()
                .FirstOrDefaultAsync(o => o.OrderId == orderId && o.CustomerId == customerId, ct);

            if (order is null)
            {
                return new ProductReviewUpsertResult(false, "Không tìm thấy đơn hàng hợp lệ.");
            }

            if (!string.Equals(order.Status, "Hoàn thành", StringComparison.OrdinalIgnoreCase))
            {
                return new ProductReviewUpsertResult(false, "Chỉ có thể đánh giá khi đơn hàng đã hoàn thành.");
            }

            var isProductInOrder = await _db.OrderDetails
                .AsNoTracking()
                .AnyAsync(od => od.OrderId == orderId && od.ProductId == productId, ct);

            if (!isProductInOrder)
            {
                return new ProductReviewUpsertResult(false, "Sản phẩm không thuộc đơn hàng này.");
            }

            if (rating < 1 || rating > 5)
            {
                return new ProductReviewUpsertResult(false, "Số sao không hợp lệ (1-5).");
            }

            var trimmedComment = string.IsNullOrWhiteSpace(comment) ? null : comment.Trim();
            if (!string.IsNullOrWhiteSpace(trimmedComment) && trimmedComment.Length > 1000)
            {
                trimmedComment = trimmedComment[..1000];
            }

            var existing = await _db.Reviews
                .FirstOrDefaultAsync(r =>
                    r.ProductId == productId &&
                    r.CustomerId == customerId &&
                    r.ServiceId == null &&
                    r.BookingId == null, ct);

            if (existing is null)
            {
                var review = new Review
                {
                    Rating = rating,
                    Comment = trimmedComment,
                    CreatedAt = DateTime.Now,
                    ProductId = productId,
                    CustomerId = customerId,
                    ServiceId = null,
                    BookingId = null
                };

                _db.Reviews.Add(review);
            }
            else
            {
                existing.Rating = rating;
                existing.Comment = trimmedComment;
                existing.CreatedAt = DateTime.Now;

                _db.Reviews.Update(existing);
            }

            await _db.SaveChangesAsync(ct);
            return new ProductReviewUpsertResult(true, "Đã ghi nhận đánh giá.");
        }
    }
}
