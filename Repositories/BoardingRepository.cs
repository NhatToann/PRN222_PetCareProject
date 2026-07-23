using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Repositories
{
    public sealed class BoardingRepository : IBoardingRepository
    {
        private readonly IDbContextFactory<ShopPetDatabaseContext> _dbFactory;

        public BoardingRepository(IDbContextFactory<ShopPetDatabaseContext> dbFactory)
        {
            _dbFactory = dbFactory;
        }

        private ShopPetDatabaseContext NewContext() => _dbFactory.CreateDbContext();

        public async Task<IReadOnlyList<BoardingRoom>> GetAllRoomsAsync(CancellationToken ct = default)
        {
            await using var db = NewContext();
            return await db.BoardingRooms
                .AsNoTracking()
                .OrderBy(r => r.RoomId)
                .ToListAsync(ct);
        }

        public async Task<BoardingRoom?> GetRoomByIdAsync(int roomId, CancellationToken ct = default)
        {
            await using var db = NewContext();
            return await db.BoardingRooms
                .AsNoTracking()
                .FirstOrDefaultAsync(r => r.RoomId == roomId, ct);
        }

        public async Task<IReadOnlyList<BoardingBookingDto>> GetAllBookingsAsync(CancellationToken ct = default)
        {
            await using var db = NewContext();
            var bookings = await db.BoardingBookings
                .AsNoTracking()
                .Include(b => b.Customer)
                .OrderByDescending(b => b.CreatedAt)
                .ToListAsync(ct);

            return bookings.Select(b => new BoardingBookingDto(
                b.BookingId,
                b.CustomerId,
                b.RoomType,
                b.PricePerDay,
                b.BoardingDays,
                b.CheckInDate,
                b.CheckOutDate,
                b.CheckInTime,
                b.CheckOutTime,
                b.PetInfo,
                b.SpecialNotes,
                b.EmergencyPhone1,
                b.EmergencyPhone2,
                b.Status,
                b.CreatedAt,
                b.UpdatedAt,
                b.TotalPrice,
                b.PaymentMethod,
                new CustomerDto(
                    b.Customer.CustomerId,
                    b.Customer.Name,
                    b.Customer.Email,
                    b.Customer.Phone
                )
            )).ToList();
        }

        public async Task<bool> ConfirmCheckinAsync(int bookingId, CancellationToken ct = default)
        {
            await using var db = NewContext();
            var booking = await db.BoardingBookings.FirstOrDefaultAsync(b => b.BookingId == bookingId, ct);
            if (booking is null) return false;

            booking.Status = "Đang sử dụng";
            booking.UpdatedAt = DateTime.Now;
            await db.SaveChangesAsync(ct);
            return true;
        }

        public async Task<bool> ConfirmCheckoutAsync(int bookingId, CancellationToken ct = default)
        {
            await using var db = NewContext();
            var booking = await db.BoardingBookings.FirstOrDefaultAsync(b => b.BookingId == bookingId, ct);
            if (booking is null) return false;

            booking.Status = "Đã trả phòng";
            booking.UpdatedAt = DateTime.Now;
            await db.SaveChangesAsync(ct);
            return true;
        }

        public async Task<bool> RejectBookingAsync(int bookingId, string reason, CancellationToken ct = default)
        {
            await using var db = NewContext();
            var booking = await db.BoardingBookings.FirstOrDefaultAsync(b => b.BookingId == bookingId, ct);
            if (booking is null) return false;

            booking.Status = $"Bị từ chối ({reason})";
            booking.UpdatedAt = DateTime.Now;
            await db.SaveChangesAsync(ct);
            return true;
        }

        public async Task<IReadOnlyList<BoardingAvailabilityDto>> GetAvailabilityAsync(CancellationToken ct = default)
        {
            await using var db = NewContext();
            var today = DateOnly.FromDateTime(DateTime.Today);

            var activeByType = await db.BoardingBookings
                .AsNoTracking()
                .Where(b => b.Status == "Đang sử dụng"
                    && b.CheckInDate <= today
                    && b.CheckOutDate >= today)
                .GroupBy(b => b.RoomType)
                .Select(g => new { RoomType = g.Key, Count = g.Count() })
                .ToListAsync(ct);

            var allRooms = await db.BoardingRooms
                .AsNoTracking()
                .ToListAsync(ct);

            return allRooms.Select(room =>
            {
                var active = activeByType.FirstOrDefault(x => x.RoomType == room.RoomType);
                return new BoardingAvailabilityDto(
                    room.RoomType,
                    room.Rooms,
                    active?.Count ?? 0,
                    room.Rooms - (active?.Count ?? 0)
                );
            }).ToList();
        }
    }
}
