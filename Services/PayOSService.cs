using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services
{
    public sealed class PayOSService : IPayOSService
    {
        private readonly HttpClient _httpClient;
        private readonly PayOSOptions _options;
        private readonly ShopPetDatabaseContext _db;
        private readonly IEmailService _emailService;
        private string? _lastError;
        private string? _lastResponse;

        public PayOSService(HttpClient httpClient, IOptions<PayOSOptions> options, ShopPetDatabaseContext db, IEmailService emailService)
        {
            _httpClient = httpClient;
            _options = options.Value;
            _db = db;
            _emailService = emailService;
        }

        public async Task<PayOSCheckoutResult?> CreatePaymentLinkAsync(CreatePayOSPaymentRequest request, CancellationToken ct = default)
        {
            _lastError = null;
            _lastResponse = null;

            var payload = BuildPaymentPayload(request);
            if (payload is null)
            {
                _lastError = "Invalid payload";
                return null;
            }

            var json = JsonSerializer.Serialize(payload, JsonSerializerOptionsFactory());
            var baseUri = _options.BaseUrl.TrimEnd('/') + "/";
            var fullUrl = new Uri(new Uri(baseUri), "payment-requests").ToString();
            Console.WriteLine($"[PayOS] Calling URL: {fullUrl}");
            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, fullUrl);
            httpRequest.Content = new StringContent(json, Encoding.UTF8, "application/json");
            httpRequest.Headers.Add("x-client-id", _options.ClientId);
            httpRequest.Headers.Add("x-api-key", _options.ApiKey);

            try
            {
                using var response = await _httpClient.SendAsync(httpRequest, ct);
                var responseText = await response.Content.ReadAsStringAsync(ct);
                _lastResponse = responseText;

                if (!response.IsSuccessStatusCode)
                {
                    _lastError = $"HTTP {(int)response.StatusCode}";
                    return null;
                }

                var root = JsonSerializer.Deserialize<PayOSApiResponse>(responseText, JsonSerializerOptionsFactory());
                if (root?.Code is not ("00" or "200") || root.Data?.CheckoutUrl is null)
                {
                    _lastError = root?.Desc ?? "Missing checkoutUrl";
                    return null;
                }

                return new PayOSCheckoutResult(root.Data.CheckoutUrl, request.OrderCode, request.Amount, request.Description);
            }
            catch (HttpRequestException ex)
            {
                _lastError = ex.Message;
                return null;
            }
        }

        public bool VerifyWebhook(string rawData, string? signature)
        {
            if (string.IsNullOrWhiteSpace(rawData) || string.IsNullOrWhiteSpace(signature))
            {
                return false;
            }

            var computed = ComputeHmac(rawData, _options.ChecksumKey);
            return string.Equals(computed, signature, StringComparison.OrdinalIgnoreCase);
        }

        public async Task<PayOSPaymentStatusResult?> GetPaymentStatusAsync(int orderCode, CancellationToken ct = default)
        {
            _lastError = null;
            _lastResponse = null;

            var baseUri = _options.BaseUrl.TrimEnd('/') + "/";
            var fullUrl = new Uri(new Uri(baseUri), $"payment-requests/{orderCode}").ToString();

            using var httpRequest = new HttpRequestMessage(HttpMethod.Get, fullUrl);
            httpRequest.Headers.Add("x-client-id", _options.ClientId);
            httpRequest.Headers.Add("x-api-key", _options.ApiKey);

            try
            {
                using var response = await _httpClient.SendAsync(httpRequest, ct);
                var responseText = await response.Content.ReadAsStringAsync(ct);
                _lastResponse = responseText;

                if (!response.IsSuccessStatusCode)
                {
                    _lastError = $"HTTP {(int)response.StatusCode}";
                    return null;
                }

                var root = JsonSerializer.Deserialize<PayOSApiResponse>(responseText, JsonSerializerOptionsFactory());
                if (root?.Data is null)
                {
                    _lastError = "No data in response";
                    return null;
                }

                var status = root.Data.Status ?? "unknown";
                var isPaid = string.Equals(status, "PAID", StringComparison.OrdinalIgnoreCase)
                    || string.Equals(status, "00", StringComparison.OrdinalIgnoreCase);

                return new PayOSPaymentStatusResult(
                    orderCode,
                    status,
                    isPaid,
                    root.Data.Amount,
                    root.Data.CheckoutUrl);
            }
            catch (HttpRequestException ex)
            {
                _lastError = ex.Message;
                return null;
            }
        }

        public async Task<PayOSWebhookResult> HandleWebhookAsync(string rawData, CancellationToken ct = default)
        {
            if (string.IsNullOrWhiteSpace(rawData))
            {
                return new PayOSWebhookResult(false, "Empty payload");
            }

            PayOSWebhookPayload? payload;
            try
            {
                payload = JsonSerializer.Deserialize<PayOSWebhookPayload>(rawData, JsonSerializerOptionsFactory());
            }
            catch
            {
                return new PayOSWebhookResult(false, "Invalid payload");
            }

            var data = payload?.Data;
            if (data is null)
            {
                return new PayOSWebhookResult(false, "Missing data");
            }

            // Lay status tu Data.Status hoac fallback sang root Code
            var status = data.Status ?? payload?.Code;
            var isPaid = payload?.Success == true
                || string.Equals(status, "PAID", StringComparison.OrdinalIgnoreCase)
                || string.Equals(status, "00", StringComparison.OrdinalIgnoreCase)
                || string.Equals(status, "success", StringComparison.OrdinalIgnoreCase);

            Console.WriteLine($"[PayOS] Webhook received. orderCode: {data.OrderCode}, status: {status ?? "(null)"}, success: {payload?.Success}");

            var payment = await _db.Payments.FirstOrDefaultAsync(p => p.PayosOrderCode == data.OrderCode, ct);
            if (payment is null)
            {
                Console.WriteLine("[PayOS] Payment not found in DB.");
                return new PayOSWebhookResult(false, "Payment not found");
            }

            Console.WriteLine($"[PayOS] Payment found. Type: {payment.PaymentType}, Status: {payment.PaymentStatus}, RefId: {payment.ReferenceId}");

            // Khi khach hang huy QR hoac het han, Cap nhat Payment & Order
            if (!isPaid)
            {
                Console.WriteLine($"[PayOS] Payment cancelled/expired. Status: {status}. Updating to cancelled.");
                payment.PaymentStatus = "cancelled";
                await _db.SaveChangesAsync(ct);

                if (string.Equals(payment.PaymentType, "order", StringComparison.OrdinalIgnoreCase))
                {
                    await CancelOrderAsync(payment.ReferenceId, ct);
                }
                else if (string.Equals(payment.PaymentType, "spa", StringComparison.OrdinalIgnoreCase))
                {
                    await UpdateSpaBookingStatusAsync(payment.ReferenceId, "Đã hủy", ct);
                    await SendSpaInvoiceEmailAsync(payment.ReferenceId, "Đã hủy", ct);
                    Console.WriteLine("[PayOS] Spa cancellation email sent.");
                }
                else if (string.Equals(payment.PaymentType, "boarding", StringComparison.OrdinalIgnoreCase))
                {
                    await UpdateBoardingBookingStatusAsync(payment.ReferenceId, "Đã hủy", ct);
                }

                return new PayOSWebhookResult(true, "Cancelled");
            }

            var wasPending = string.Equals(payment.PaymentStatus, "pending", StringComparison.OrdinalIgnoreCase);
            if (wasPending)
            {
                payment.PaymentStatus = "paid";
                payment.PaidAt = DateTime.Now;
                await _db.SaveChangesAsync(ct);
                Console.WriteLine("[PayOS] Payment updated to paid.");
            }

            if (string.Equals(payment.PaymentType, "spa", StringComparison.OrdinalIgnoreCase))
            {
                await UpdateSpaBookingStatusAsync(payment.ReferenceId, "Đã thanh toán", ct);
                Console.WriteLine("[PayOS] Spa booking status updated.");
                if (wasPending)
                {
                    await SendSpaInvoiceEmailAsync(payment.ReferenceId, "Đã thanh toán", ct);
                    Console.WriteLine("[PayOS] Spa invoice email sent.");
                }
            }
            else if (string.Equals(payment.PaymentType, "order", StringComparison.OrdinalIgnoreCase))
            {
                await UpdateOrderStatusAsync(payment.ReferenceId, ct);
                Console.WriteLine("[PayOS] Order status updated.");
            }
            else if (string.Equals(payment.PaymentType, "boarding", StringComparison.OrdinalIgnoreCase))
            {
                await UpdateBoardingBookingStatusAsync(payment.ReferenceId, "Đã thanh toán", ct);
                Console.WriteLine("[PayOS] Boarding booking status updated.");
            }

            return new PayOSWebhookResult(true, "OK");
        }

        public async Task<PayOSWebhookResult> HandleWebhookForStatusAsync(int orderCode, PayOSPaymentStatusResult status, CancellationToken ct = default)
        {
            if (!status.IsPaid)
            {
                return new PayOSWebhookResult(true, "No action for non-paid status");
            }

            var payment = await _db.Payments.FirstOrDefaultAsync(p => p.PayosOrderCode == orderCode, ct);
            if (payment is null)
            {
                return new PayOSWebhookResult(false, "Payment not found");
            }

            var wasPending = string.Equals(payment.PaymentStatus, "pending", StringComparison.OrdinalIgnoreCase);
            if (wasPending)
            {
                payment.PaymentStatus = "paid";
                payment.PaidAt = DateTime.Now;
                await _db.SaveChangesAsync(ct);
            }

            if (string.Equals(payment.PaymentType, "spa", StringComparison.OrdinalIgnoreCase))
            {
                await UpdateSpaBookingStatusAsync(payment.ReferenceId, "Đã thanh toán", ct);
                if (wasPending)
                {
                    await SendSpaInvoiceEmailAsync(payment.ReferenceId, "Đã thanh toán", ct);
                }
            }
            else if (string.Equals(payment.PaymentType, "order", StringComparison.OrdinalIgnoreCase))
            {
                await UpdateOrderStatusAsync(payment.ReferenceId, ct);
            }
            else if (string.Equals(payment.PaymentType, "boarding", StringComparison.OrdinalIgnoreCase))
            {
                await UpdateBoardingBookingStatusAsync(payment.ReferenceId, "Đã thanh toán", ct);
            }

            return new PayOSWebhookResult(true, "OK");
        }

        public string NormalizeDescription(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return string.Empty;
            }

            var step1 = text.Replace('đ', 'd').Replace('Đ', 'D');
            var normalized = step1.Normalize(NormalizationForm.FormD);
            var sb = new StringBuilder();
            foreach (var c in normalized)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(c) != System.Globalization.UnicodeCategory.NonSpacingMark)
                {
                    sb.Append(c);
                }
            }

            var cleaned = Regex.Replace(sb.ToString(), "[^a-zA-Z0-9 #]", string.Empty);
            cleaned = cleaned.Trim();
            if (cleaned.Length > 25)
            {
                cleaned = cleaned[..25].Trim();
            }

            return cleaned;
        }

        private PayOSPaymentRequest? BuildPaymentPayload(CreatePayOSPaymentRequest request)
        {
            if (request.Amount <= 0)
            {
                return null;
            }

            var amount = Convert.ToInt32(Math.Round(request.Amount));
            var description = NormalizeDescription(request.Description);

            var payload = new PayOSPaymentRequest
            {
                Amount = amount,
                CancelUrl = request.CancelUrl,
                Description = description,
                Items = Array.Empty<object>(),
                OrderCode = request.OrderCode,
                ReturnUrl = request.ReturnUrl
            };

            var signature = GenerateSignature(payload);
            if (string.IsNullOrWhiteSpace(signature))
            {
                return null;
            }

            payload.Signature = signature;
            return payload;
        }

        private string GenerateSignature(PayOSPaymentRequest payload)
        {
            var sorted = new SortedDictionary<string, string>
            {
                ["amount"] = payload.Amount.ToString(),
                ["cancelUrl"] = payload.CancelUrl,
                ["description"] = payload.Description,
                ["orderCode"] = payload.OrderCode.ToString(),
                ["returnUrl"] = payload.ReturnUrl
            };

            var data = string.Join("&", sorted.Select(kv => $"{kv.Key}={kv.Value}"));
            return ComputeHmac(data, _options.ChecksumKey);
        }

        private static string ComputeHmac(string data, string key)
        {
            var keyBytes = Encoding.UTF8.GetBytes(key);
            using var hmac = new HMACSHA256(keyBytes);
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(data));
            return ConvertToHex(hash);
        }

        private static string ConvertToHex(byte[] hash)
        {
            var sb = new StringBuilder(hash.Length * 2);
            foreach (var b in hash)
            {
                sb.Append(b.ToString("x2"));
            }
            return sb.ToString();
        }

        private async Task UpdateSpaBookingStatusAsync(int? bookingId, string status, CancellationToken ct)
        {
            if (!bookingId.HasValue)
            {
                return;
            }

            var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.BookingId == bookingId.Value, ct);
            if (booking is null)
            {
                return;
            }

            booking.Status = status;
            booking.UpdatedAt = DateTime.Now;
            await _db.SaveChangesAsync(ct);
        }

        private async Task UpdateBoardingBookingStatusAsync(int? bookingId, string status, CancellationToken ct)
        {
            if (!bookingId.HasValue)
            {
                return;
            }

            var booking = await _db.BoardingBookings.FirstOrDefaultAsync(b => b.BookingId == bookingId.Value, ct);
            if (booking is null)
            {
                return;
            }

            booking.Status = status;
            booking.UpdatedAt = DateTime.Now;
            await _db.SaveChangesAsync(ct);

            await SendBoardingInvoiceEmailAsync(booking.BookingId, ct);
        }

        private async Task SendBoardingInvoiceEmailAsync(int bookingId, CancellationToken ct)
        {
            try
            {
                var booking = await _db.BoardingBookings
                    .Include(b => b.Customer)
                    .AsNoTracking()
                    .FirstOrDefaultAsync(b => b.BookingId == bookingId, ct);

                if (booking?.Customer is null || string.IsNullOrWhiteSpace(booking.Customer.Email))
                {
                    return;
                }

                var room = await _db.BoardingRooms
                    .AsNoTracking()
                    .FirstOrDefaultAsync(r => r.RoomType == booking.RoomType, ct);

                var petCount = ParsePetCount(booking.PetInfo);

                var roomDisplay = !string.IsNullOrWhiteSpace(room?.RoomName)
                    ? room!.RoomName.Trim()
                    : booking.RoomType;

                await _emailService.SendBoardingInvoiceEmailAsync(
                    booking.Customer.Email,
                    booking.Customer.Name,
                    $"BR-{booking.BookingId:D4}",
                    roomDisplay,
                    booking.CheckInDate,
                    booking.CheckOutDate,
                    booking.BoardingDays,
                    petCount,
                    booking.SpecialNotes,
                    booking.PricePerDay,
                    booking.TotalPrice,
                    "Thanh toán trực tuyến (PayOS)",
                    "Đã thanh toán",
                    ct
                );
                Console.WriteLine($"[PayOS] Boarding invoice email sent for booking #{bookingId}.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[PayOS] Failed to send boarding invoice email: {ex.Message}");
            }
        }

        private static int ParsePetCount(string? petInfo)
        {
            if (string.IsNullOrWhiteSpace(petInfo))
                return 1;

            var match = System.Text.RegularExpressions.Regex.Match(petInfo, @"\d+");
            return match.Success ? int.Parse(match.Value) : 1;
        }

        private async Task UpdateOrderStatusAsync(int? orderId, CancellationToken ct)
        {
            if (!orderId.HasValue)
            {
                return;
            }

            var order = await _db.Orders
                .Include(o => o.OrderDetails)
                .FirstOrDefaultAsync(o => o.OrderId == orderId.Value, ct);
            if (order is null)
            {
                Console.WriteLine($"[PayOS] Order #{orderId} not found.");
                return;
            }

            // Cap nhat payment status
            order.PaymentStatus = "Đã thanh toán";
            // Chuyen tu "Cho thanh toan" sang "Cho xac nhan" sau khi quet QR thanh cong
            if (string.Equals(order.Status, "Chờ thanh toán", StringComparison.OrdinalIgnoreCase))
            {
                order.Status = "Chờ xác nhận";
            }
            order.PaidAt = DateTime.Now;

            // Tru stock cho tung san pham trong don hang
            foreach (var detail in order.OrderDetails.Where(d => d.ProductId != null))
            {
                var product = await _db.Products.FirstOrDefaultAsync(p => p.ProductId == detail.ProductId, ct);
                if (product != null && product.StockQuantity > 0)
                {
                    var qty = detail.Quantity ?? 1;
                    product.StockQuantity = Math.Max(0, product.StockQuantity - qty);
                }
            }

            await _db.SaveChangesAsync(ct);
            Console.WriteLine($"[PayOS] Order #{orderId} updated. Status -> Chờ xác nhận, PaymentStatus -> Đã thanh toán.");
        }

        private async Task CancelOrderAsync(int? orderId, CancellationToken ct)
        {
            if (!orderId.HasValue)
            {
                return;
            }

            var order = await _db.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId.Value, ct);
            if (order is null)
            {
                Console.WriteLine($"[PayOS] CancelOrder: Order #{orderId} not found.");
                return;
            }

            // Chi huy neu dang o trang thai "Cho thanh toan"
            if (string.Equals(order.Status, "Chờ thanh toán", StringComparison.OrdinalIgnoreCase))
            {
                order.Status = "Đã hủy";
                order.PaymentStatus = "cancelled";
                await _db.SaveChangesAsync(ct);
                Console.WriteLine($"[PayOS] Order #{orderId} cancelled.");
            }
            else
            {
                Console.WriteLine($"[PayOS] Order #{orderId} has status '{order.Status}', not cancelling.");
            }
        }

        private async Task SendSpaInvoiceEmailAsync(int? bookingId, string paymentStatusLabel, CancellationToken ct)
        {
            if (!bookingId.HasValue)
            {
                return;
            }

            var booking = await _db.Bookings
                .AsNoTracking()
                .Include(b => b.Customer)
                .Include(b => b.BookingServices)
                .ThenInclude(bs => bs.Service)
                .FirstOrDefaultAsync(b => b.BookingId == bookingId.Value, ct);

            if (booking?.Customer?.Email is null)
            {
                return;
            }

            var items = booking.BookingServices
                .Select(bs => (
                    ItemName: bs.Service?.Name ?? "Dich vu spa",
                    Quantity: bs.Quantity,
                    UnitPrice: bs.UnitPrice ?? 0m
                ))
                .ToList();

            var total = items.Sum(item => item.UnitPrice * item.Quantity);
            if (total <= 0)
            {
                total = booking.BookingServices.Sum(bs => (bs.UnitPrice ?? 0m) * bs.Quantity);
            }

            await _emailService.SendSpaInvoiceEmailAsync(
                booking.Customer.Email,
                booking.Customer.Name,
                $"SPA-{booking.BookingId}",
                items,
                total,
                paymentStatusLabel,
                ct);
        }

        private static JsonSerializerOptions JsonSerializerOptionsFactory()
        {
            return new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
            };
        }

        public string? GetLastError() => _lastError;

        public string? GetLastResponse() => _lastResponse;

        private sealed class PayOSApiResponse
        {
            public string? Code { get; set; }
            public string? Desc { get; set; }
            public PayOSApiData? Data { get; set; }
        }

        private sealed class PayOSApiData
        {
            public string? CheckoutUrl { get; set; }
            public string? Status { get; set; }
            public int Amount { get; set; }
        }

        private sealed class PayOSPaymentRequest
        {
            [JsonPropertyName("amount")]
            public int Amount { get; set; }

            [JsonPropertyName("cancelUrl")]
            public string CancelUrl { get; set; } = string.Empty;

            [JsonPropertyName("description")]
            public string Description { get; set; } = string.Empty;

            [JsonPropertyName("items")]
            public object[] Items { get; set; } = Array.Empty<object>();

            [JsonPropertyName("orderCode")]
            public int OrderCode { get; set; }

            [JsonPropertyName("returnUrl")]
            public string ReturnUrl { get; set; } = string.Empty;

            [JsonPropertyName("signature")]
            public string? Signature { get; set; }
        }
    }
}
