using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class PetService
    {
        public int ServiceId { get; set; }

        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public decimal Price { get; set; }

        public int Duration { get; set; }

        public string ServiceType { get; set; } = null!;

        public string? Status { get; set; }

        public DateTime? CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public virtual ICollection<BookingService> BookingServices { get; set; } = new List<BookingService>();
    }
}
