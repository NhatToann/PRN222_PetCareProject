using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class BookingService
    {
        public int BookingId { get; set; }

        public int ServiceId { get; set; }

        public int Quantity { get; set; }

        public decimal? UnitPrice { get; set; }

        public int? DurationMin { get; set; }

        public DateTime CreatedAt { get; set; }

        public string? Note { get; set; }

        public int BookingServiceId { get; set; }

        public virtual Booking Booking { get; set; } = null!;

        public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

        public virtual PetService Service { get; set; } = null!;
    }
}
