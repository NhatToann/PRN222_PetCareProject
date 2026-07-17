using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Review
    {
        public int ReviewId { get; set; }

        public int Rating { get; set; }

        public string? Comment { get; set; }

        public DateTime CreatedAt { get; set; }

        public int? ServiceId { get; set; }

        public int? ProductId { get; set; }

        public int? CustomerId { get; set; }

        public int? BookingId { get; set; }

        public virtual BookingService? BookingService { get; set; }
    }
}
