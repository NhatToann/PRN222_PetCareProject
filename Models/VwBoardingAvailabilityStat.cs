using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VwBoardingAvailabilityStat
    {
        public string RoomType { get; set; } = null!;

        public int? TotalBookings { get; set; }

        public int? ActiveBookings { get; set; }

        public DateOnly? EarliestCheckin { get; set; }

        public DateOnly? LatestCheckout { get; set; }

        public int? TotalBoardingDays { get; set; }

        public decimal? AvgBoardingDays { get; set; }

        public decimal? TotalRevenue { get; set; }
    }
}
