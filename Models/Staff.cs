using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Staff
    {
        public int StaffId { get; set; }

        public string Name { get; set; } = null!;

        public string? Phone { get; set; }

        public string? Email { get; set; }

        public string? Password { get; set; }

        public string? Position { get; set; }

        public virtual ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();

        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();

        public virtual ICollection<ShiftRequest> ShiftRequests { get; set; } = new List<ShiftRequest>();

        public virtual StaffSalary? StaffSalary { get; set; }

        public virtual ICollection<WorkSchedule> WorkSchedules { get; set; } = new List<WorkSchedule>();
    }
}
