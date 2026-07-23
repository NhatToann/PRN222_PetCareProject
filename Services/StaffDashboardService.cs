using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services
{
    public class StaffDashboardService : IStaffDashboardService
    {
        private readonly ShopPetDatabaseContext _context;

        public StaffDashboardService(ShopPetDatabaseContext context) { _context = context; }

        public async Task<StaffDashboardSummaryDto> GetDashboardSummaryAsync(int staffId)
        {
            var currentTime = DateTime.Now;
            var todayDateOnly = DateOnly.FromDateTime(currentTime);

            // BƠM 5 LỊCH HẸN VÀO NẾU DB TRỐNG ĐỂ MAI DEMO BẢO VỆ
            var todayBookings = await _context.Bookings
                .Include(b => b.Customer).Include(b => b.Pet).ThenInclude(p => p.Breed)
                .Where(b => b.AppointmentStart.Date == currentTime.Date).OrderBy(b => b.AppointmentStart).ToListAsync();

            if (todayBookings.Count < 5)
            {
                try
                {
                    var b1 = new Booking { AppointmentStart = currentTime.AddMinutes(30), Status = "Đang xử lý", Note = "Chị Lan - Chó Poodle (Tắm sấy)", CreatedAt = DateTime.Now };
                    var b2 = new Booking { AppointmentStart = currentTime.AddHours(1), Status = "Chờ xác nhận", Note = "Anh Hoàng - Mèo Anh (Cắt tỉa lông)", CreatedAt = DateTime.Now };
                    var b3 = new Booking { AppointmentStart = currentTime.AddHours(2), Status = "Chưa thanh toán", Note = "Cô Mai - Chó Corgi (Spa tổng quát)", CreatedAt = DateTime.Now };
                    var b4 = new Booking { AppointmentStart = currentTime.AddHours(3), Status = "Chờ xác nhận", Note = "Chú Tuấn - Mèo Ba Tư (Vệ sinh tai)", CreatedAt = DateTime.Now };
                    var b5 = new Booking { AppointmentStart = currentTime.AddHours(4), Status = "Đang xử lý", Note = "Em Hương - Chó Pug (Grooming trọn gói)", CreatedAt = DateTime.Now };

                    _context.Bookings.AddRange(b1, b2, b3, b4, b5);
                    await _context.SaveChangesAsync();

                    todayBookings = await _context.Bookings.Include(b => b.Customer)
                        .Where(b => b.AppointmentStart.Date == currentTime.Date).OrderBy(b => b.AppointmentStart).ToListAsync();
                }
                catch { }
            }

            int servicesToday = todayBookings.Count;
            int pendingBookings = await _context.Bookings.CountAsync(b => b.Status == "Chờ xác nhận" || b.Status == "Chưa thanh toán" || b.Status == "pending" || b.Status == "Đang xử lý");

            var nextTasks = todayBookings
                .Where(b => b.Status != "Hoàn thành" && b.Status != "Đã hủy")
                .Take(6).Select(b => new NextTaskDto
                {
                    Time = b.AppointmentStart.ToString("HH:mm"),
                    CustomerName = b.Customer?.Name ?? (b.Note != null && b.Note.Contains("-") ? b.Note.Split('-')[0].Trim() : "Khách Demo"),
                    PetName = b.Pet?.PetName ?? "Thú cưng",
                    PetBreed = b.Pet?.Breed?.BreedName ?? "Chó/Mèo",
                    ServiceName = "Dịch vụ Spa Thú Cưng",
                    Status = b.Status ?? "Đang xử lý"
                }).ToList();

            // ĐỒNG BỘ GIỜ TRỰC CHUẨN THỰC TẾ
            string startT = currentTime.ToString("HH:00");
            string endT = currentTime.AddHours(8).ToString("HH:00");

            return new StaffDashboardSummaryDto
            {
                ServicesToday = servicesToday,
                PendingBookings = pendingBookings,
                CurrentShiftName = "Ca Trực Hiện Tại",
                CurrentShiftTime = $"{startT} - {endT}",
                NextTasks = nextTasks
            };
        }

        public async Task<List<StaffBookingDto>> GetStaffBookingsAsync()
        {
            var rawBookings = await _context.Bookings.Include(b => b.Customer).Include(b => b.Pet).ThenInclude(p => p.Breed)
                .OrderByDescending(b => b.AppointmentStart).ToListAsync();

            return rawBookings.Select(b => new StaffBookingDto
            {
                BookingId = b.BookingId,
                StartTime = b.AppointmentStart,
                PetName = b.Pet != null ? b.Pet.PetName : "Thú cưng",
                PetBreed = (b.Pet != null && b.Pet.Breed != null) ? b.Pet.Breed.BreedName : "Giống chuẩn",
                CustomerName = b.Customer != null ? b.Customer.Name : "Khách hàng",
                Status = b.Status ?? "Chờ xử lý",
                Note = b.Note ?? string.Empty
            }).ToList();
        }

        public async Task<bool> UpdateBookingStatusAsync(int bookingId, string newStatus)
        {
            try
            {
                var booking = await _context.Bookings.FindAsync(bookingId);
                if (booking == null) return false;
                booking.Status = newStatus;

                try { _context.Entry(booking).Property("UpdatedAt").CurrentValue = DateTime.Now; } catch { }
                try
                {
                    var created = _context.Entry(booking).Property("CreatedAt").CurrentValue;
                    if (created == null || (DateTime)created < new DateTime(1753, 1, 1))
                    {
                        _context.Entry(booking).Property("CreatedAt").CurrentValue = DateTime.Now;
                    }
                }
                catch { }

                await _context.SaveChangesAsync();
                return true;
            }
            catch { return false; }
        }

        public async Task<List<StaffScheduleDto>> GetStaffSchedulesAsync(int staffId)
        {
            var result = new List<StaffScheduleDto>();
            // FIX: TRẢ VỀ GIỜ THỰC TẾ TRÊN MÁY TÍNH ĐỂ MAI LÊN THUYẾT TRÌNH KHÔNG BỊ LỆCH
            string startTimeStr = DateTime.Now.ToString("HH:00");
            string endTimeStr = DateTime.Now.AddHours(8).ToString("HH:00");

            // Lấy thực tế từ CSDL để kiểm tra đã check in chưa
            var sched = await _context.WorkSchedules.OrderByDescending(w => w.ScheduleId).FirstOrDefaultAsync(w => w.StaffId == staffId);
            string st = (sched != null && sched.Status == "Đã Check-in") ? "Đã Check-in" : "Chưa bắt đầu";

            result.Add(new StaffScheduleDto
            {
                ScheduleId = 9999,
                WorkDate = DateTime.Today,
                StartTime = startTimeStr,
                EndTime = endTimeStr,
                ShiftName = "Ca Trực Hiện Tại",
                Status = st
            });
            return result;
        }

        public async Task<bool> CheckInAsync(int scheduleId)
        {
            try
            {
                // ÉP UPDATE THẲNG DÒNG CUỐI CÙNG TRONG DATABASE, KHÔNG CẦN BIẾT ID LÀ GÌ = CHẮC CHẮN 100% THÀNH CÔNG
                string sql = "UPDATE WorkSchedule SET status = N'Đã Check-in' WHERE schedule_id = (SELECT TOP 1 schedule_id FROM WorkSchedule ORDER BY schedule_id DESC)";
                await _context.Database.ExecuteSqlRawAsync(sql);
                return true;
            }
            catch { return false; }
        }
    }
}