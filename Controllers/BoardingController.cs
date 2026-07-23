using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/boarding-rooms")]
    public sealed class BoardingController : ControllerBase
    {
        /// <summary>Must match CHECK constraint CK_boarding_bookings_Status in SQL Server.</summary>
        private const string BoardingStatusChoXacNhan = "Chờ xác nhận";
        private const string BoardingStatusDaThanhToan = "Đã thanh toán";
        private const string BoardingStatusBiTuChoi = "Bị từ chối";

        private readonly IBoardingService _service;
        private readonly ShopPetDatabaseContext _db;
        private readonly IPayOSService _payOS;
        private readonly IEmailService _email;

        public BoardingController(IBoardingService service, ShopPetDatabaseContext db, IPayOSService payOS, IEmailService email)
        {
            _service = service;
            _db = db;
            _payOS = payOS;
            _email = email;
        }

        [HttpGet]
        public async Task<ActionResult<IReadOnlyList<BoardingRoom>>> GetAll(CancellationToken ct)
        {
            var rooms = await _service.GetAllRoomsAsync(ct);
            return Ok(rooms);
        }

        [HttpGet("{roomId:int}")]
        public async Task<ActionResult<BoardingRoom>> GetById(int roomId, CancellationToken ct)
        {
            var room = await _service.GetRoomByIdAsync(roomId, ct);
            return room is null ? NotFound() : Ok(room);
        }

        [HttpGet("bookings")]
        public async Task<ActionResult<IReadOnlyList<BoardingBookingDto>>> GetAllBookings(CancellationToken ct)
        {
            var bookings = await _service.GetAllBookingsAsync(ct);
            return Ok(bookings);
        }

        [HttpPatch("bookings/{bookingId:int}/checkin")]
        public async Task<ActionResult> ConfirmCheckin(int bookingId, CancellationToken ct)
        {
            var ok = await _service.ConfirmCheckinAsync(bookingId, ct);
            return ok ? Ok(new { message = "Đã xác nhận nhận phòng." }) : NotFound(new { message = "Không tìm thấy booking." });
        }

        [HttpPatch("bookings/{bookingId:int}/checkout")]
        public async Task<ActionResult> ConfirmCheckout(int bookingId, CancellationToken ct)
        {
            var ok = await _service.ConfirmCheckoutAsync(bookingId, ct);
            return ok ? Ok(new { message = "Đã xác nhận trả phòng." }) : NotFound(new { message = "Không tìm thấy booking." });
        }

        [HttpPatch("bookings/{bookingId:int}/reject")]
        public async Task<ActionResult> RejectBooking(int bookingId, [FromQuery] string? reason, CancellationToken ct)
        {
            var ok = await _service.RejectBookingAsync(bookingId, reason ?? "Không có lý do", ct);
            return ok ? Ok(new { message = "Đã từ chối booking." }) : NotFound(new { message = "Không tìm thấy booking." });
        }

        [HttpGet("availability")]
        public async Task<ActionResult<IReadOnlyList<BoardingAvailabilityDto>>> GetAvailability(CancellationToken ct)
        {
            var availability = await _service.GetAvailabilityAsync(ct);
            return Ok(availability);
        }

        [HttpGet("bookings/{bookingId:int}/payment-status")]
        public async Task<ActionResult> GetBookingPaymentStatus(int bookingId, CancellationToken ct)
        {
            var booking = await _db.BoardingBookings
                .AsNoTracking()
                .Include(b => b.Customer)
                .FirstOrDefaultAsync(b => b.BookingId == bookingId, ct);

            if (booking is null)
                return NotFound(new { message = "Booking not found." });

            // If booking is already confirmed/active/done, no need to check PayOS
            if (booking.Status is "Đã thanh toán" or "Đang sử dụng" or "Đã trả phòng")
                return Ok(new { bookingId, bookingStatus = booking.Status, paymentStatus = "already_processed" });

            // Find the pending payment for this boarding booking
            var payment = await _db.Payments
                .AsNoTracking()
                .FirstOrDefaultAsync(p =>
                    p.PaymentType == "boarding" &&
                    p.ReferenceId == bookingId &&
                    p.PaymentStatus == "pending", ct);

            if (payment is null)
                return Ok(new { bookingId, bookingStatus = booking.Status, paymentStatus = "no_pending_payment" });

            if (payment.PayosOrderCode is null or 0)
                return Ok(new { bookingId, bookingStatus = booking.Status, paymentStatus = "no_payos_payment" });

            // Check actual PayOS status
            var status = await _payOS.GetPaymentStatusAsync(payment.PayosOrderCode.Value, ct);
            if (status is null)
                return Ok(new { bookingId, bookingStatus = booking.Status, paymentStatus = "payos_unreachable", orderCode = payment.PayosOrderCode });

            if (status.IsPaid)
            {
                // Update payment to paid
                payment.PaymentStatus = "paid";
                payment.PaidAt = DateTime.Now;
                // Update booking status
                booking.Status = "Đã thanh toán";
                booking.UpdatedAt = DateTime.Now;
                await _db.SaveChangesAsync(ct);

                await _email.SendBoardingInvoiceEmailAsync(
                    booking.Customer?.Email ?? "",
                    booking.Customer?.Name ?? "Khach hang",
                    $"BR-{booking.BookingId:D4}",
                    booking.RoomType,
                    booking.CheckInDate,
                    booking.CheckOutDate,
                    booking.BoardingDays,
                    1,
                    booking.SpecialNotes,
                    booking.PricePerDay,
                    booking.TotalPrice,
                    "Thanh toán trực tuyến (PayOS)",
                    "Đã thanh toán",
                    ct);

                return Ok(new
                {
                    bookingId,
                    bookingStatus = "Đã thanh toán",
                    paymentStatus = "paid",
                    orderCode = payment.PayosOrderCode
                });
            }

            return Ok(new
            {
                bookingId,
                bookingStatus = booking.Status,
                paymentStatus = status.Status ?? "unknown",
                orderCode = payment.PayosOrderCode
            });
        }

        [HttpGet("catalog")]
        public async Task<ActionResult<BoardingCatalogDto>> GetCatalog(CancellationToken ct)
        {
            var catalog = await _service.GetCatalogAsync(ct);
            return Ok(catalog);
        }

        [HttpPost("checkout")]
        public async Task<ActionResult<BoardingCheckoutResponse>> Checkout(
            [FromBody] BoardingCheckoutRequest request,
            CancellationToken ct)
        {
            try
            {
                if (request.CustomerId is null or 0)
                    return BadRequest(new BoardingCheckoutResponse(false, "Vui lòng đăng nhập để đặt phòng.", null, null, null, request.PaymentMethod));

                if (request.RoomId <= 0)
                    return BadRequest(new BoardingCheckoutResponse(false, "Phòng không hợp lệ.", null, null, null, request.PaymentMethod));

                if (request.Days <= 0)
                    return BadRequest(new BoardingCheckoutResponse(false, "Số ngày không hợp lệ.", null, null, null, request.PaymentMethod));

                if (request.TotalPrice <= 0)
                    return BadRequest(new BoardingCheckoutResponse(false, "Tổng tiền không hợp lệ.", null, null, null, request.PaymentMethod));

                var customer = await _db.Customers
                    .AsNoTracking()
                    .FirstOrDefaultAsync(c => c.CustomerId == request.CustomerId, ct);

                if (customer is null)
                    return BadRequest(new BoardingCheckoutResponse(false, $"Không tìm thấy khách hàng với ID: {request.CustomerId}. Vui lòng đăng nhập lại.", null, null, null, request.PaymentMethod));

                var room = await _db.BoardingRooms
                    .AsNoTracking()
                    .FirstOrDefaultAsync(r => r.RoomId == request.RoomId, ct);

                var booking = new BoardingBooking
                {
                    CustomerId = request.CustomerId.Value,
                    RoomType = request.RoomType ?? "",
                    PricePerDay = request.PricePerDay,
                    BoardingDays = request.Days,
                    CheckInDate = request.CheckIn,
                    CheckOutDate = request.CheckOut,
                    PetInfo = $"Số thú cưng: {request.Pets}",
                    SpecialNotes = request.Notes,
                    EmergencyPhone1 = request.CustomerPhone ?? "",
                    Status = request.PaymentMethod == "PayOS" ? BoardingStatusChoXacNhan : BoardingStatusChoXacNhan,
                    TotalPrice = request.TotalPrice,
                    PaymentMethod = request.PaymentMethod,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                };

                _db.BoardingBookings.Add(booking);
                await _db.SaveChangesAsync(ct);

                var payment = new Payment
                {
                    PaymentType = "boarding",
                    ReferenceId = booking.BookingId,
                    CustomerId = request.CustomerId.Value,
                    Amount = request.TotalPrice,
                    PaymentStatus = request.PaymentMethod == "PayOS" ? "pending" : "completed",
                    PaymentMethod = request.PaymentMethod,
                    Note = $"Đặt phòng Boarding #{booking.BookingId}",
                    CreatedAt = DateTime.Now
                };

                if (request.PaymentMethod == "PayOS")
                {
                    var orderCode = GenerateOrderCode(0);
                    payment.PayosOrderCode = orderCode;

                    var description = _payOS.NormalizeDescription($"Thanh toan phong #{request.RoomId} - {request.Days} ngay");

                    var returnUrl = $"{Request.Scheme}://{Request.Host}/boarding-checkout/success?bookingId={booking.BookingId}";
                    var cancelUrl = $"{Request.Scheme}://{Request.Host}/boarding-checkout/cancel";

                    _db.Payments.Add(payment);
                    await _db.SaveChangesAsync(ct);

                    var checkout = await _payOS.CreatePaymentLinkAsync(new CreatePayOSPaymentRequest(
                        orderCode,
                        request.TotalPrice,
                        description,
                        returnUrl,
                        cancelUrl
                    ), ct);

                    if (checkout is null)
                    {
                        return BadRequest(new BoardingCheckoutResponse(false, "Không tạo được link PayOS: " + _payOS.GetLastError(), null, null, null, "PayOS"));
                    }

                    return Ok(new BoardingCheckoutResponse(true, "Tạo thanh toán PayOS thành công.", booking.BookingId, orderCode.ToString(), checkout.CheckoutUrl, "PayOS"));
                }

                _db.Payments.Add(payment);
                await _db.SaveChangesAsync(ct);

                await SendBoardingConfirmationEmailAsync(customer, booking, request, room, ct);

                return Ok(new BoardingCheckoutResponse(true, "Đặt phòng thành công!", booking.BookingId, null, null, "COD"));
            }
            catch (DbUpdateException ex)
            {
                Console.WriteLine($"[BoardingController] DbUpdateException: {ex.Message}");
                Console.WriteLine($"[BoardingController] Inner: {ex.InnerException?.Message}");
                return StatusCode(500, new BoardingCheckoutResponse(false, "Lỗi cơ sở dữ liệu khi lưu đặt phòng: " + ex.InnerException?.Message, null, null, null, request.PaymentMethod));
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[BoardingController] Exception: {ex.Message}");
                return StatusCode(500, new BoardingCheckoutResponse(false, "Lỗi khi xử lý đặt phòng: " + ex.Message, null, null, null, request.PaymentMethod));
            }
        }

        private static int GenerateOrderCode(int seed)
        {
            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            var code = (int)((timestamp % 1_000_000_000) * 1000 + (seed % 1000));
            return Math.Abs(code);
        }

        private async Task SendBoardingConfirmationEmailAsync(
            Customer customer,
            BoardingBooking booking,
            BoardingCheckoutRequest request,
            BoardingRoom? room,
            CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(customer.Email))
            {
                Console.WriteLine($"[BoardingController] Customer {customer.CustomerId} has no email — skipping email.");
                return;
            }

            var roomDisplay = !string.IsNullOrWhiteSpace(room?.RoomName)
                ? room!.RoomName.Trim()
                : (!string.IsNullOrWhiteSpace(request.RoomName) ? request.RoomName.Trim() : booking.RoomType);

            try
            {
                await _email.SendBoardingInvoiceEmailAsync(
                    customer.Email,
                    customer.Name,
                    $"BR-{booking.BookingId:D4}",
                    roomDisplay,
                    booking.CheckInDate,
                    booking.CheckOutDate,
                    booking.BoardingDays,
                    ParsePetCount(booking.PetInfo),
                    booking.SpecialNotes,
                    booking.PricePerDay,
                    booking.TotalPrice,
                    "Thanh toán khi nhận phòng (COD)",
                    "Chưa thanh toán",
                    ct
                );
                Console.WriteLine($"[BoardingController] Confirmation email sent to {customer.Email} for booking #{booking.BookingId}.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[BoardingController] Failed to send boarding email: {ex.Message}");
            }
        }

        private static int ParsePetCount(string? petInfo)
        {
            if (string.IsNullOrWhiteSpace(petInfo))
                return 1;

            var match = System.Text.RegularExpressions.Regex.Match(petInfo, @"\d+");
            return match.Success ? int.Parse(match.Value) : 1;
        }
    }
}
