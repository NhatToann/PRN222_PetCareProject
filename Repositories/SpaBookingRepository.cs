using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Repositories
{
    public sealed class SpaBookingRepository : ISpaBookingRepository
    {
        // Trạng thái được tính là đang chiếm slot vận hành spa.
        private static bool IsOccupyingSlotStatus(string? status)
        {
            var s = (status ?? string.Empty).Trim().ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(s)) return false;

            return s.Contains("đã chấp nhận")
                || s.Contains("đã xác nhận")
                || s.Contains("đang xử lý")
                || s.Contains("hoàn thành")
                || s.Contains("đã thanh toán")
                || s.Contains("chờ thanh toán payos")
                || s == "accepted"
                || s == "confirmed"
                || s == "processing"
                || s == "completed"
                || s == "paid"
                || s == "payos_pending";
        }

        private readonly ShopPetDatabaseContext _db;

        public SpaBookingRepository(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        public async Task<IReadOnlyList<PetSummaryDto>> GetPetsByCustomerIdAsync(int customerId, CancellationToken ct = default)
        {
            return await _db.Pets
                .AsNoTracking()
                .Include(p => p.Breed)
                .ThenInclude(b => b!.Species)
                .Where(p => p.CustomerId == customerId)
                .OrderByDescending(p => p.UpdatedAt ?? p.CreatedAt)
                .Select(p => new PetSummaryDto(
                    p.Id,
                    p.PetName,
                    p.BreedId,
                    p.Breed != null ? p.Breed.BreedName : null,
                    p.Breed != null && p.Breed.Species != null ? p.Breed.Species.SpeciesName : null,
                    p.WeightKg
                ))
                .ToListAsync(ct);
        }

        public async Task<IReadOnlyList<SpaServiceDto>> GetActiveSpaServicesAsync(CancellationToken ct = default)
        {
            return await _db.PetServices
                .AsNoTracking()
                .Where(s => s.ServiceType == "spa" && (s.Status == null || s.Status == "active"))
                .OrderBy(s => s.ServiceType)
                .ThenBy(s => s.Name)
                .Select(s => new SpaServiceDto(
                    s.ServiceId,
                    s.Name,
                    s.Description,
                    s.Price,
                    s.Duration,
                    s.ServiceType,
                    s.Status
                ))
                .ToListAsync(ct);
        }

        public async Task<(decimal UnitPrice, int DurationMin, string ServiceName)?> GetServicePricingAsync(int serviceId, int? breedId, CancellationToken ct = default)
        {
            var service = await _db.PetServices
                .AsNoTracking()
                .Where(s => s.ServiceId == serviceId)
                .Select(s => new { s.Price, s.Duration, s.Name })
                .FirstOrDefaultAsync(ct);

            if (service == null)
            {
                return null;
            }

            decimal unitPrice = service.Price;

            if (breedId.HasValue)
            {
                var priceAdjustPercent = await _db.BreedPricings
                    .AsNoTracking()
                    .Where(bp => bp.BreedId == breedId.Value)
                    .Select(bp => (decimal?)bp.PriceAdjust)
                    .FirstOrDefaultAsync(ct);

                if (priceAdjustPercent.HasValue)
                {
                    // PriceAdjust là %: 80 = giảm 20%, 120 = tăng 20%, 100 = giá gốc
                    unitPrice = service.Price * priceAdjustPercent.Value / 100m;
                }
            }

            unitPrice = Math.Max(0m, unitPrice);

            return (unitPrice, service.Duration, service.Name);
        }

        public async Task<int> CountSpaBookingsInTimeSlotAsync(DateTime start, DateTime end, CancellationToken ct = default)
        {
            var scanStart = start.AddHours(-12);
            var scanEnd = end.AddHours(12);

            var candidates = await _db.Bookings
                .AsNoTracking()
                .Where(b => b.AppointmentStart < scanEnd && b.AppointmentStart > scanStart)
                .Where(b => b.BookingServices.Any(bs => bs.Service != null && bs.Service.ServiceType != null && bs.Service.ServiceType.ToLower() == "spa"))
                .Select(b => new { b.PetId, b.AppointmentStart, b.AppointmentEnd, b.Status })
                .ToListAsync(ct);

            var count = candidates
                .Where(b => IsOccupyingSlotStatus(b.Status))
                .Select(b =>
                {
                    var effectiveEnd = b.AppointmentEnd > b.AppointmentStart
                        ? b.AppointmentEnd
                        : b.AppointmentStart.AddMinutes(30);

                    return new
                    {
                        b.PetId,
                        Start = b.AppointmentStart,
                        End = effectiveEnd
                    };
                })
                .Where(b => b.Start < end && b.End > start)
                .Distinct()
                .Count();

            return count;
        }

        public async Task<int> CountAnySpaBookingsInTimeSlotAsync(DateTime start, DateTime end, CancellationToken ct = default)
        {
            // Lấy booking trong vùng thời gian liên quan rồi tính overlap ở memory để xử lý cả dữ liệu cũ có end <= start.
            var scanStart = start.AddHours(-12);
            var scanEnd = end.AddHours(12);

            var candidates = await _db.Bookings
                .AsNoTracking()
                .Where(b => b.AppointmentStart < scanEnd && b.AppointmentStart > scanStart)
                .Select(b => new { b.AppointmentStart, b.AppointmentEnd, b.Status })
                .ToListAsync(ct);

            var count = candidates.Count(b =>
            {
                if (!IsOccupyingSlotStatus(b.Status))
                {
                    return false;
                }

                var effectiveEnd = b.AppointmentEnd > b.AppointmentStart
                    ? b.AppointmentEnd
                    : b.AppointmentStart.AddMinutes(30);

                return b.AppointmentStart < end && effectiveEnd > start;
            });

            return count;
        }

        public async Task<int> CreateBookingAsync(Booking booking, CancellationToken ct = default)
        {
            _db.Bookings.Add(booking);
            await _db.SaveChangesAsync(ct);
            return booking.BookingId;
        }

        public async Task AddBookingServiceAsync(BookingService bookingService, CancellationToken ct = default)
        {
            _db.BookingServices.Add(bookingService);
            await _db.SaveChangesAsync(ct);
        }

        public async Task DeleteBookingsAsync(IReadOnlyList<int> bookingIds, CancellationToken ct = default)
        {
            if (bookingIds == null || bookingIds.Count == 0)
            {
                return;
            }

            var bookingServices = await _db.BookingServices
                .Where(bs => bookingIds.Contains(bs.BookingId))
                .ToListAsync(ct);

            if (bookingServices.Count > 0)
            {
                _db.BookingServices.RemoveRange(bookingServices);
            }

            var bookings = await _db.Bookings
                .Where(b => bookingIds.Contains(b.BookingId))
                .ToListAsync(ct);

            if (bookings.Count > 0)
            {
                _db.Bookings.RemoveRange(bookings);
            }

            await _db.SaveChangesAsync(ct);
        }

        public async Task<IReadOnlyList<SpaBookingDto>> GetSpaBookingsByCustomerIdAsync(int customerId, CancellationToken ct = default)
        {
            var bookings = await _db.Bookings
                .AsNoTracking()
                .Include(b => b.Customer)
                .Include(b => b.Pet)
                .ThenInclude(p => p.Breed)
                .ThenInclude(br => br!.Species)
                .Include(b => b.BookingServices)
                .ThenInclude(bs => bs.Service)
                .Where(b => b.CustomerId == customerId)
                .OrderByDescending(b => b.CreatedAt)
                .ThenByDescending(b => b.AppointmentStart)
                .ToListAsync(ct);

            var bookingIds = bookings.Select(b => b.BookingId).ToList();

            var payments = await _db.Payments
                .AsNoTracking()
                .Where(p => p.PaymentType == "spa" && p.ReferenceId != null && bookingIds.Contains(p.ReferenceId.Value))
                .ToListAsync(ct);

            var paymentsByBookingId = payments
                .GroupBy(p => p.ReferenceId!.Value)
                .ToDictionary(g => g.Key, g => g.First());

            return bookings
                .Where(b => b.BookingServices.Any(bs => bs.Service != null && bs.Service.ServiceType != null && bs.Service.ServiceType.ToLower() == "spa"))
                .Select(b =>
                {
                    paymentsByBookingId.TryGetValue(b.BookingId, out var payment);
                    return new SpaBookingDto(
                        b.BookingId,
                        b.PetId,
                        b.Pet?.PetName ?? string.Empty,
                        b.Pet?.Breed?.BreedName,
                        b.Pet?.Breed?.Species?.SpeciesName,
                        b.Customer?.Name,
                        b.Customer?.Phone,
                        b.AppointmentStart,
                        b.AppointmentEnd,
                        b.Status,
                        b.CreatedAt,
                        b.BookingServices.Select(bs => new SpaBookingItemDto(
                            bs.ServiceId,
                            bs.Service.Name,
                            bs.Quantity,
                            bs.UnitPrice ?? 0m,
                            bs.DurationMin ?? 0
                        )).ToList(),
                        b.BookingServices.Sum(bs => (bs.UnitPrice ?? 0m) * bs.Quantity),
                        payment?.PaymentMethod
                    );
                })
                .ToList();
        }

        public async Task<IReadOnlyList<SpaBookingDto>> GetAllSpaBookingsAsync(CancellationToken ct = default)
        {
            var bookings = await _db.Bookings
                .AsNoTracking()
                .Include(b => b.Customer)
                .Include(b => b.Pet)
                .ThenInclude(p => p.Breed)
                .ThenInclude(br => br!.Species)
                .Include(b => b.BookingServices)
                .ThenInclude(bs => bs.Service)
                .Where(b => b.BookingServices.Any(bs => bs.Service != null && bs.Service.ServiceType != null && bs.Service.ServiceType.ToLower() == "spa"))
                .OrderByDescending(b => b.CreatedAt)
                .ThenByDescending(b => b.AppointmentStart)
                .ToListAsync(ct);

            var bookingIds = bookings.Select(b => b.BookingId).ToList();

            var payments = await _db.Payments
                .AsNoTracking()
                .Where(p => p.PaymentType == "spa" && p.ReferenceId != null && bookingIds.Contains(p.ReferenceId.Value))
                .ToListAsync(ct);

            var paymentsByBookingId = payments
                .GroupBy(p => p.ReferenceId!.Value)
                .ToDictionary(g => g.Key, g => g.First());

            return bookings
                .Select(b =>
                {
                    paymentsByBookingId.TryGetValue(b.BookingId, out var payment);
                    return new SpaBookingDto(
                        b.BookingId,
                        b.PetId,
                        b.Pet?.PetName ?? string.Empty,
                        b.Pet?.Breed?.BreedName,
                        b.Pet?.Breed?.Species?.SpeciesName,
                        b.Customer?.Name,
                        b.Customer?.Phone,
                        b.AppointmentStart,
                        b.AppointmentEnd,
                        b.Status,
                        b.CreatedAt,
                        b.BookingServices
                            .Where(bs => bs.Service != null && bs.Service.ServiceType != null && bs.Service.ServiceType.ToLower() == "spa")
                            .Select(bs => new SpaBookingItemDto(
                                bs.ServiceId,
                                bs.Service != null ? bs.Service.Name : string.Empty,
                                bs.Quantity,
                                bs.UnitPrice ?? 0m,
                                bs.DurationMin ?? 0
                            )).ToList(),
                        b.BookingServices
                            .Where(bs => bs.Service != null && bs.Service.ServiceType != null && bs.Service.ServiceType.ToLower() == "spa")
                            .Sum(bs => (bs.UnitPrice ?? 0m) * bs.Quantity),
                        payment?.PaymentMethod
                    );
                })
                .ToList();
        }

        public async Task<SpaBookingInvoiceDto?> GetSpaBookingInvoiceAsync(int bookingId, CancellationToken ct = default)
        {
            var booking = await _db.Bookings
                .AsNoTracking()
                .Include(b => b.Customer)
                .Include(b => b.Pet)
                .Include(b => b.BookingServices)
                .ThenInclude(bs => bs.Service)
                .FirstOrDefaultAsync(b => b.BookingId == bookingId, ct);

            if (booking == null)
            {
                return null;
            }

            var items = booking.BookingServices
                .Where(bs => bs.Service != null)
                .Select(bs => new SpaBookingItemDto(
                    bs.ServiceId,
                    bs.Service.Name,
                    bs.Quantity,
                    bs.UnitPrice ?? 0m,
                    bs.DurationMin ?? 0
                ))
                .ToList();

            if (items.Count == 0)
            {
                return null;
            }

            var total = items.Sum(item => item.UnitPrice * item.Quantity);

            var payment = await _db.Payments
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.PaymentType == "spa" && p.ReferenceId == bookingId, ct);

            return new SpaBookingInvoiceDto(
                booking.BookingId,
                booking.Customer?.Name ?? string.Empty,
                booking.Customer?.Email ?? string.Empty,
                booking.PetId,
                booking.Pet?.PetName ?? string.Empty,
                booking.AppointmentStart,
                booking.AppointmentEnd,
                booking.Status,
                booking.CreatedAt,
                items,
                total,
                payment?.PaymentMethod
            );
        }

        public async Task<bool> UpdateBookingStatusAsync(int bookingId, string status, CancellationToken ct = default)
        {
            var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.BookingId == bookingId, ct);
            if (booking == null)
            {
                return false;
            }

            booking.Status = status;
            await _db.SaveChangesAsync(ct);
            return true;
        }

        public async Task<bool> HasCompletedBookingAsync(int customerId, int bookingId, int serviceId, CancellationToken ct = default)
        {
            return await _db.Bookings
                .AsNoTracking()
                .Where(b => b.BookingId == bookingId && b.CustomerId == customerId)
                .Where(b => b.Status == "Hoàn thành" || b.Status == "completed" || b.Status == "Đã thanh toán" || b.Status == "Chờ xác nhận" || b.Status == "Đã xác nhận")
                .AnyAsync(b => b.BookingServices.Any(bs => bs.ServiceId == serviceId), ct);
        }

        public async Task<int?> GetReviewIdAsync(int customerId, int bookingId, int serviceId, CancellationToken ct = default)
        {
            return await _db.Reviews
                .AsNoTracking()
                .Where(r => r.CustomerId == customerId && r.BookingId == bookingId && r.ServiceId == serviceId)
                .Select(r => (int?)r.ReviewId)
                .FirstOrDefaultAsync(ct);
        }

        public async Task AddReviewAsync(Review review, CancellationToken ct = default)
        {
            _db.Reviews.Add(review);
            await _db.SaveChangesAsync(ct);
        }

        public async Task UpdateReviewAsync(Review review, CancellationToken ct = default)
        {
            _db.Reviews.Update(review);
            await _db.SaveChangesAsync(ct);
        }
    }
}
