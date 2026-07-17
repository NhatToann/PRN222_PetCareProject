using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/orders-temp")]
    public sealed class OrdersController_temp : ControllerBase
    {
        private readonly ShopPetDatabaseContext _db;

        public OrdersController_temp(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        private static IQueryable<OrderSummaryDto_temp> ProjectOrderSummary(IQueryable<Order> query) =>
            query.Select(o => new OrderSummaryDto_temp(
                o.OrderId,
                o.OrderDate,
                o.Status,
                o.PaymentStatus,
                o.PaymentMethod,
                o.TotalAmount,
                o.ShippingAddress,
                o.OrderDetails
                    .Where(od => od.ProductId != null)
                    .OrderBy(od => od.DetailId)
                    .Select(od => od.Product != null ? od.Product.Name : null)
                    .FirstOrDefault(),
                o.OrderDetails
                    .Where(od => od.ProductId != null)
                    .OrderBy(od => od.DetailId)
                    .Select(od => od.Product != null ? od.Product.ImageUrl : null)
                    .FirstOrDefault(),
                o.OrderDetails.Count(od => od.ProductId != null)));

        [HttpGet("history")]
        public async Task<ActionResult<IReadOnlyList<OrderSummaryDto_temp>>> History([FromQuery] int customerId, CancellationToken ct)
        {
            var orders = await ProjectOrderSummary(
                    _db.Orders
                        .AsNoTracking()
                        .Where(o => o.CustomerId == customerId)
                        .OrderByDescending(o => o.OrderDate))
                .ToListAsync(ct);

            return Ok(orders);
        }

        [HttpGet("{orderId:int}")]
        public async Task<ActionResult<OrderDetailDto_temp>> Detail(int orderId, [FromQuery] int customerId, CancellationToken ct)
        {
            var order = await _db.Orders
                .AsNoTracking()
                .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Product)
                .FirstOrDefaultAsync(o => o.OrderId == orderId && o.CustomerId == customerId, ct);

            if (order is null)
            {
                return NotFound(new { message = "Không tìm thấy đơn hàng." });
            }

            return Ok(new OrderDetailDto_temp(
                order.OrderId,
                order.OrderDate,
                order.Status,
                order.PaymentStatus,
                order.PaymentMethod,
                order.TotalAmount,
                order.ShippingAddress,
                order.OrderDetails.Select(od => new OrderDetailItemDto_temp(
                    od.ProductId ?? 0,
                    od.Product?.Name ?? "Sản phẩm",
                    od.Quantity ?? 0,
                    od.UnitPrice ?? 0m,
                    od.Product?.ImageUrl))
                .ToList()));
        }

        // Danh sách đơn chờ nhân viên xác nhận (COD).
        [HttpGet("staff/pending")]
        public async Task<ActionResult<IReadOnlyList<OrderSummaryDto_temp>>> StaffPending(CancellationToken ct)
        {
            var orders = await ProjectOrderSummary(
                    _db.Orders
                        .AsNoTracking()
                        .Where(o => o.Status == "Chờ xác nhận")
                        .OrderByDescending(o => o.OrderDate))
                .ToListAsync(ct);

            return Ok(orders);
        }

        // Staff xem đơn theo trạng thái (dùng cho UI tab).
        // status: "Chờ xác nhận" | "Chờ giao hàng" | "Hoàn thành"
        [HttpGet("staff")]
        public async Task<ActionResult<IReadOnlyList<OrderSummaryDto_temp>>> StaffByStatus([FromQuery] string? status, CancellationToken ct)
        {
            var query = _db.Orders
                .AsNoTracking();

            if (!string.IsNullOrWhiteSpace(status))
            {
                query = query.Where(o => o.Status != null && o.Status == status);
            }

            var orders = await ProjectOrderSummary(query.OrderByDescending(o => o.OrderDate))
                .ToListAsync(ct);

            return Ok(orders);
        }

        // Nhân viên xác nhận đơn -> chuyển sang "Chờ giao hàng" và trừ stock sản phẩm.
        [HttpPatch("staff/{orderId:int}/confirm")]
        public async Task<ActionResult<OrderSummaryDto_temp>> StaffConfirm(int orderId, CancellationToken ct)
        {
            var order = await _db.Orders
                .Include(o => o.OrderDetails)
                .FirstOrDefaultAsync(o => o.OrderId == orderId, ct);
            if (order is null)
            {
                return NotFound(new { message = "Không tìm thấy đơn hàng." });
            }

            if (!string.Equals(order.Status, "Chờ xác nhận", StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest(new { message = $"Không thể xác nhận đơn ở trạng thái: {order.Status}" });
            }

            // Trừ stock cho từng sản phẩm trong đơn hàng
            foreach (var detail in order.OrderDetails.Where(d => d.ProductId != null))
            {
                var product = await _db.Products.FirstOrDefaultAsync(p => p.ProductId == detail.ProductId, ct);
                if (product != null && product.StockQuantity > 0)
                {
                    var qty = detail.Quantity ?? 1;
                    product.StockQuantity = Math.Max(0, product.StockQuantity - qty);
                }
            }

            order.Status = "Chờ giao hàng";
            await _db.SaveChangesAsync(ct);

            var summary = await ProjectOrderSummary(
                    _db.Orders.AsNoTracking().Where(o => o.OrderId == orderId))
                .FirstAsync(ct);

            return Ok(summary);
        }

        // Khách hàng xác nhận đã nhận hàng -> "Hoàn thành".
        [HttpPatch("{orderId:int}/delivered")]
        public async Task<ActionResult<OrderSummaryDto_temp>> CustomerDelivered(
            int orderId,
            [FromQuery] int customerId,
            CancellationToken ct)
        {
            var order = await _db.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId && o.CustomerId == customerId, ct);
            if (order is null)
            {
                return NotFound(new { message = "Không tìm thấy đơn hàng." });
            }

            if (!string.Equals(order.Status, "Chờ giao hàng", StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest(new { message = $"Không thể xác nhận đã giao ở trạng thái: {order.Status}" });
            }

            order.Status = "Hoàn thành";
            await _db.SaveChangesAsync(ct);

            var summary = await ProjectOrderSummary(
                    _db.Orders.AsNoTracking().Where(o => o.OrderId == orderId))
                .FirstAsync(ct);

            return Ok(summary);
        }
    }

    public sealed record OrderSummaryDto_temp(
        int OrderId,
        DateTime OrderDate,
        string? Status,
        string? PaymentStatus,
        string? PaymentMethod,
        decimal TotalAmount,
        string? ShippingAddress,
        string? PrimaryProductName,
        string? PrimaryProductImageUrl,
        int ProductLineCount);

    public sealed record OrderDetailItemDto_temp(
        int ProductId,
        string ProductName,
        int Quantity,
        decimal UnitPrice,
        string? ImageUrl);

    public sealed record OrderDetailDto_temp(
        int OrderId,
        DateTime OrderDate,
        string? Status,
        string? PaymentStatus,
        string? PaymentMethod,
        decimal TotalAmount,
        string? ShippingAddress,
        IReadOnlyList<OrderDetailItemDto_temp> Items);

}
