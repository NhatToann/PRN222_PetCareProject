using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VServiceReview
    {
        public int ReviewId { get; set; }

        public int Rating { get; set; }

        public string? Comment { get; set; }

        public DateTime CreatedAt { get; set; }

        public int? ServiceId { get; set; }

        public string? ServiceName { get; set; }

        public int? CustomerId { get; set; }

        public int? CustomerUserId { get; set; }

        public string? CustomerName { get; set; }
    }
}
