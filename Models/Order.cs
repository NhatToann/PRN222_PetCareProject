using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Order
    {
        public int OrderId { get; set; }

        public DateTime OrderDate { get; set; }

        public string? Status { get; set; }

        public decimal TotalAmount { get; set; }

        public string? PaymentStatus { get; set; }

        public int? CustomerId { get; set; }

        public int? AdminId { get; set; }

        public string? PaymentMethod { get; set; }

        public DateTime? PaidAt { get; set; }

        public string? ShippingAddress { get; set; }

        public double? Latitude { get; set; }

        public double? Longitude { get; set; }

        public virtual Admin? Admin { get; set; }

        public virtual ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();
    }
}
