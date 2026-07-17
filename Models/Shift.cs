using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Shift
    {
        public int ShiftId { get; set; }

        public string ShiftCode { get; set; } = null!;

        public string? ShiftName { get; set; }

        public TimeOnly StartTime { get; set; }

        public TimeOnly EndTime { get; set; }

        public int? BreakMinutes { get; set; }

        public string? Location { get; set; }
    }
}
