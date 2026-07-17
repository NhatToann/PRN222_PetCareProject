using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Doctor
    {
        public int DoctorId { get; set; }

        public string Name { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string? Phone { get; set; }

        public string? Password { get; set; }

        public string? Specialization { get; set; }

        public string? ScheduleNote { get; set; }

        public virtual ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();

        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();

        public virtual ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();

        public virtual ICollection<PayrollRecord> PayrollRecords { get; set; } = new List<PayrollRecord>();

        public virtual ICollection<ShiftRequest> ShiftRequests { get; set; } = new List<ShiftRequest>();

        public virtual ICollection<StaffSalary> StaffSalaries { get; set; } = new List<StaffSalary>();

        public virtual ICollection<WorkSchedule> WorkSchedules { get; set; } = new List<WorkSchedule>();
    }
}
