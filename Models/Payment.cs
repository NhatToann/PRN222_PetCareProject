using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Payment
    {
        public int PaymentId { get; set; }

        public string PaymentType { get; set; } = null!;

        public int? ReferenceId { get; set; }

        public int CustomerId { get; set; }

        public decimal Amount { get; set; }

        public string? PaymentMethod { get; set; }

        public string? PaymentStatus { get; set; }

        public int? PayosOrderCode { get; set; }

        public string? TransactionCode { get; set; }

        public string? TransactionRef { get; set; }

        public DateTime? CreatedAt { get; set; }

        public DateTime? PaidAt { get; set; }

        public string? Note { get; set; }
    }
}
