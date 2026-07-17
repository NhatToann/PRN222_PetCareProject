using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VProductReview
    {
        public int ReviewId { get; set; }

        public int Rating { get; set; }

        public string? Comment { get; set; }

        public DateTime CreatedAt { get; set; }

        public int? ProductId { get; set; }

        public string? ProductName { get; set; }

        public int? CustomerId { get; set; }

        public int? CustomerUserId { get; set; }

        public string? CustomerName { get; set; }
    }
}
