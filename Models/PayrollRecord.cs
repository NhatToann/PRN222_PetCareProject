using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class PayrollRecord
    {
        public int PayrollId { get; set; }

        public int? StaffId { get; set; }

        public DateOnly PeriodStart { get; set; }

        public DateOnly PeriodEnd { get; set; }

        public double? TotalHours { get; set; }

        public decimal? HourlyRate { get; set; }

        public decimal? TotalSalary { get; set; }

        public DateTime? CreatedAt { get; set; }

        public decimal? BaseSalary { get; set; }

        public int? ActualShifts { get; set; }

        public int? DoctorId { get; set; }

        public virtual Doctor? Doctor { get; set; }
    }
}
