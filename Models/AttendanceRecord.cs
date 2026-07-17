using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class AttendanceRecord
    {
        public int AttendanceId { get; set; }

        public int StaffId { get; set; }

        public DateTime CheckIn { get; set; }

        public DateTime? CheckOut { get; set; }

        public double? TotalHours { get; set; }

        public string? Status { get; set; }

        public DateTime? CreatedAt { get; set; }

        public bool? IsLate { get; set; }

        public int? DoctorId { get; set; }

        public int? DoctorId1 { get; set; }

        public virtual Doctor? DoctorId1Navigation { get; set; }

        public virtual Staff Staff { get; set; } = null!;
    }
}
