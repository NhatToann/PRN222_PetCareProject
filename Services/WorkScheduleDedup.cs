using PetShop.Models;

namespace PetShop.Services
{
    /// <summary>
    /// Gom các dòng WorkSchedule trùng (cùng nhân viên, ngày, khung giờ) — giữ bản ghi có schedule_id nhỏ nhất.
    /// </summary>
    public static class WorkScheduleDedup
    {
        public static List<WorkSchedule> ByStaffDateTimeSlot(IEnumerable<WorkSchedule> rows)
        {
            return rows
                .GroupBy(w => (StaffKey: w.StaffId ?? 0, w.WorkDate, w.StartTime, w.EndTime))
                .Select(g => g.OrderBy(w => w.ScheduleId).First())
                .OrderBy(w => w.StartTime)
                .ToList();
        }

        public static List<WorkSchedule> ByTimeSlot(IEnumerable<WorkSchedule> rows)
        {
            return rows
                .GroupBy(w => (w.WorkDate, w.StartTime, w.EndTime))
                .Select(g => g.OrderBy(w => w.ScheduleId).First())
                .OrderBy(w => w.StartTime)
                .ToList();
        }

        public static List<ShiftOptionDto> ShiftOptions(IEnumerable<ShiftOptionDto> rows)
        {
            return rows
                .GroupBy(x => (StaffKey: x.StaffId ?? 0, x.WorkDate, x.StartTime, x.EndTime))
                .Select(g => g.OrderBy(x => x.ScheduleId).First())
                .OrderBy(x => x.WorkDate)
                .ThenBy(x => x.StartTime)
                .ToList();
        }
    }
}
