using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class WorkSchedule
    {
        public int ScheduleId { get; set; }

        public int? DoctorId { get; set; }

        public int? StaffId { get; set; }

        public DateOnly WorkDate { get; set; }

        public TimeOnly StartTime { get; set; }

        public TimeOnly EndTime { get; set; }

        public string Status { get; set; } = null!;

        public string? Note { get; set; }

        public int? ShiftId { get; set; }

        public virtual Doctor? Doctor { get; set; }

        public virtual Staff? Staff { get; set; }
    }
}
