using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class StaffSalary
    {
        public int SalaryId { get; set; }

        public int StaffId { get; set; }

        public decimal? HourlyRate { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public double? MonthlyBaseSalary { get; set; }

        public int? StandardShifts { get; set; }

        public int? DoctorId { get; set; }

        public virtual Doctor? Doctor { get; set; }

        public virtual Staff Staff { get; set; } = null!;
    }
}
