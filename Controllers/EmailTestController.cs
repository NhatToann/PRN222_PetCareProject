using Microsoft.AspNetCore.Mvc;
using PetShop.Interfaces;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/test/email")]
    public sealed class EmailTestController : ControllerBase
    {
        private readonly IEmailService _email;
        private readonly ILogger<EmailTestController> _logger;

        public EmailTestController(IEmailService email, ILogger<EmailTestController> logger)
        {
            _email = email;
            _logger = logger;
        }

        [HttpPost("spa")]
        public async Task<IActionResult> TestSpaEmail([FromBody] TestSpaEmailRequest request, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(request.ToEmail))
            {
                return BadRequest(new { message = "ToEmail is required." });
            }

            try
            {
                var items = request.Items ?? new List<TestEmailItem>();
                if (items.Count == 0)
                {
                    items = new List<TestEmailItem>
                    {
                        new("Tam tam", 1, 150000m),
                        new("Cat toc", 1, 200000m),
                    };
                }

                await _email.SendSpaInvoiceEmailAsync(
                    request.ToEmail,
                    request.CustomerName ?? "Test Customer",
                    request.BookingCode ?? "SPA-TEST001",
                    items.Select(i => (i.ItemName, i.Quantity, i.UnitPrice)),
                    items.Sum(i => i.Quantity * i.UnitPrice),
                    request.PaymentStatus ?? "Đã thanh toán",
                    ct);

                _logger.LogInformation("[TestEmail] Spa email sent to {Email} with status '{Status}'",
                    request.ToEmail, request.PaymentStatus);

                return Ok(new
                {
                    message = $"Email spa ({request.PaymentStatus}) đã được gửi đến {request.ToEmail}",
                    toEmail = request.ToEmail,
                    subject = $"PetShop - " + (request.PaymentStatus == "Đã hủy"
                        ? $"Thong bao huy dich vu spa {request.BookingCode ?? "SPA-TEST001"}"
                        : $"Hoa don spa {request.BookingCode ?? "SPA-TEST001"}")
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[TestEmail] Failed to send spa email to {Email}", request.ToEmail);
                return StatusCode(500, new { message = "Gửi email thất bại: " + ex.Message });
            }
        }

        [HttpPost("spa/cancelled")]
        public async Task<IActionResult> TestSpaCancelledEmail([FromBody] TestSpaEmailRequest request, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(request.ToEmail))
            {
                return BadRequest(new { message = "ToEmail is required." });
            }

            var items = request.Items ?? new List<TestEmailItem>();
            if (items.Count == 0)
            {
                items = new List<TestEmailItem>
                {
                    new("Tam tam", 1, 150000m),
                    new("Cat toc", 1, 200000m),
                };
            }

            try
            {
                await _email.SendSpaInvoiceEmailAsync(
                    request.ToEmail,
                    request.CustomerName ?? "Test Customer",
                    request.BookingCode ?? "SPA-TEST001",
                    items.Select(i => (i.ItemName, i.Quantity, i.UnitPrice)),
                    items.Sum(i => i.Quantity * i.UnitPrice),
                    "Đã hủy",
                    ct);

                _logger.LogInformation("[TestEmail] Spa cancellation email sent to {Email}", request.ToEmail);

                return Ok(new
                {
                    message = $"Email thông báo hủy spa đã được gửi đến {request.ToEmail}",
                    toEmail = request.ToEmail,
                    subject = $"PetShop - Thong bao huy dich vu spa {request.BookingCode ?? "SPA-TEST001"}"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[TestEmail] Failed to send spa cancellation email to {Email}", request.ToEmail);
                return StatusCode(500, new { message = "Gửi email thất bại: " + ex.Message });
            }
        }

        [HttpPost("boarding")]
        public async Task<IActionResult> TestBoardingEmail([FromBody] TestBoardingEmailRequest request, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(request.ToEmail))
            {
                return BadRequest(new { message = "ToEmail is required." });
            }

            try
            {
                await _email.SendBoardingInvoiceEmailAsync(
                    request.ToEmail,
                    request.CustomerName ?? "Test Customer",
                    request.BookingCode ?? "BR-TEST001",
                    request.RoomName ?? "Phòng VIP",
                    request.CheckIn ?? DateOnly.FromDateTime(DateTime.Today.AddDays(1)),
                    request.CheckOut ?? DateOnly.FromDateTime(DateTime.Today.AddDays(3)),
                    request.Days ?? 2,
                    request.Pets ?? 1,
                    request.Notes,
                    request.PricePerDay ?? 300000m,
                    request.TotalPrice ?? 600000m,
                    request.PaymentMethod ?? "Thanh toán trực tuyến (PayOS)",
                    request.PaymentStatus ?? "Đã thanh toán",
                    ct);

                _logger.LogInformation("[TestEmail] Boarding email sent to {Email}", request.ToEmail);

                return Ok(new
                {
                    message = $"Email boarding đã được gửi đến {request.ToEmail}",
                    toEmail = request.ToEmail,
                    subject = $"PetShop - Xac nhan dat phong boarding {request.BookingCode ?? "BR-TEST001"}"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[TestEmail] Failed to send boarding email to {Email}", request.ToEmail);
                return StatusCode(500, new { message = "Gửi email thất bại: " + ex.Message });
            }
        }
    }

    public sealed record TestSpaEmailRequest(
        string ToEmail,
        string? CustomerName,
        string? BookingCode,
        string? PaymentStatus,
        List<TestEmailItem>? Items);

    public sealed record TestEmailItem(string ItemName, int Quantity, decimal UnitPrice);

    public sealed record TestBoardingEmailRequest(
        string ToEmail,
        string? CustomerName,
        string? BookingCode,
        string? RoomName,
        DateOnly? CheckIn,
        DateOnly? CheckOut,
        int? Days,
        int? Pets,
        string? Notes,
        decimal? PricePerDay,
        decimal? TotalPrice,
        string? PaymentMethod,
        string? PaymentStatus);
}
