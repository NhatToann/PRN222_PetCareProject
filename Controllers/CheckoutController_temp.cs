using Microsoft.AspNetCore.Mvc;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/checkout-temp")]
    public sealed class CheckoutController_temp : ControllerBase
    {
        private readonly ShopPetDatabaseContext _db;
        private readonly IPayOSService _payOsService;

        public CheckoutController_temp(ShopPetDatabaseContext db, IPayOSService payOsService)
        {
            _db = db;
            _payOsService = payOsService;
        }

        [HttpPost]
        public async Task<ActionResult<CheckoutResponse_temp>> CreateAsync(
            [FromBody] CheckoutRequest_temp request,
            CancellationToken ct)
        {
            Console.WriteLine($"[Checkout] Received request: Address='{request.Address}', PaymentMethod='{request.PaymentMethod}', Items count={request.Items?.Count ?? 0}");
            Console.WriteLine($"[Checkout] CustomerId={request.CustomerId}, Email={request.Email}");

            if (string.IsNullOrWhiteSpace(request.Address))
            {
                return BadRequest(new { message = "Vui lòng nhập địa chỉ giao hàng." });
            }

            if (request.Items is null || request.Items.Count == 0)
            {
                return BadRequest(new { message = "Giỏ hàng trống." });
            }

            foreach (var item in request.Items)
            {
                Console.WriteLine($"[Checkout] Item: ProductId={item.ProductId}, Name={item.ItemName}, Qty={item.Quantity}, Price={item.UnitPrice}");
            }

            var total = request.Items.Sum(i => (i.Quantity <= 0 ? 1 : i.Quantity) * i.UnitPrice);
            var orderCodeInt = (int)(DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() % int.MaxValue);
            var orderCode = orderCodeInt.ToString();
            var order = new Order
            {
                OrderDate = DateTime.Now,
                Status = string.Equals(request.PaymentMethod, "PayOS", StringComparison.OrdinalIgnoreCase)
                    ? "Chờ thanh toán"
                    : "Chờ xác nhận",
                TotalAmount = total,
                PaymentStatus = string.Equals(request.PaymentMethod, "PayOS", StringComparison.OrdinalIgnoreCase)
                    ? "pending"
                    : "COD",
                CustomerId = request.CustomerId,
                PaymentMethod = request.PaymentMethod,
                ShippingAddress = request.Address
            };

            _db.Orders.Add(order);
            await _db.SaveChangesAsync(ct);

            foreach (var item in request.Items)
            {
                _db.OrderDetails.Add(new OrderDetail
                {
                    OrderId = order.OrderId,
                    ProductId = item.ProductId,
                    Quantity = item.Quantity <= 0 ? 1 : item.Quantity,
                    UnitPrice = item.UnitPrice
                });
            }

            await _db.SaveChangesAsync(ct);

            if (string.Equals(request.PaymentMethod, "PayOS", StringComparison.OrdinalIgnoreCase))
            {
                // Tao Payment record de webhook co the tim thay va cap nhat trang thai
                var payment = new Payment
                {
                    PaymentType = "order",
                    ReferenceId = order.OrderId,
                    CustomerId = request.CustomerId ?? 0,
                    Amount = total,
                    PaymentStatus = "pending",
                    PaymentMethod = "PayOS",
                    PayosOrderCode = orderCodeInt,
                    Note = $"Thanh toan don hang #{order.OrderId}",
                    CreatedAt = DateTime.Now
                };
                _db.Payments.Add(payment);
                await _db.SaveChangesAsync(ct);

                var payRequest = new CreatePayOSPaymentRequest(
                    orderCodeInt,
                    total,
                    _payOsService.NormalizeDescription($"Thanh toan don hang #{order.OrderId}"),
                    request.ReturnUrl ?? $"{Request.Scheme}://{Request.Host}/checkout/result",
                    request.CancelUrl ?? $"{Request.Scheme}://{Request.Host}/checkout/result");

                Console.WriteLine($"[Checkout] Creating PayOS payment. Amount={total}, OrderCode={orderCodeInt}");
                var checkout = await _payOsService.CreatePaymentLinkAsync(payRequest, ct);
                if (checkout is null)
                {
                    var error = _payOsService.GetLastError();
                    var response = _payOsService.GetLastResponse();
                    Console.WriteLine($"[Checkout] PayOS failed. Error={error}, Response={response}");
                    return BadRequest(new
                    {
                        message = "Không tạo được link PayOS.",
                        error,
                        response
                    });
                }

                Console.WriteLine($"[Checkout] PayOS success. CheckoutUrl={checkout.CheckoutUrl}");
                return Ok(new CheckoutResponse_temp("PayOS", checkout.CheckoutUrl, orderCode, order.OrderId));
            }

            Console.WriteLine($"[Checkout] COD order created. OrderId={order.OrderId}, Total={total}");
            return Ok(new CheckoutResponse_temp("COD", null, orderCode, order.OrderId));
        }
    }

    public sealed record CheckoutItem_temp(int ProductId, string ItemName, int Quantity, decimal UnitPrice);

    public sealed record CheckoutRequest_temp(
        int? CustomerId,
        string? Email,
        string? CustomerName,
        string Address,
        string PaymentMethod,
        List<CheckoutItem_temp> Items,
        string? ReturnUrl,
        string? CancelUrl);

    public sealed record CheckoutResponse_temp(string PaymentMethod, string? RedirectUrl, string OrderCode, int OrderId);

}
