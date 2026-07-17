using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VSalesOrder
    {
        public int OrderId { get; set; }

        public DateTime OrderDate { get; set; }

        public int? CustomerId { get; set; }

        public int? CustomerUserId { get; set; }

        public string? Status { get; set; }

        public decimal TotalAmount { get; set; }

        public string? PaymentStatus { get; set; }

        public string? ShippingAddress { get; set; }
    }
}
