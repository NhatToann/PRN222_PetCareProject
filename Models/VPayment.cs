using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VPayment
    {
        public int PaymentId { get; set; }

        public int? OrderId { get; set; }

        public decimal Amount { get; set; }

        public string? Method { get; set; }

        public string? PaymentStatusCode { get; set; }

        public int? DisplayName { get; set; }

        public string? TransactionCode { get; set; }

        public DateTime? CreatedAt { get; set; }

        public DateTime? PaidAt { get; set; }

        public string? TransactionRef { get; set; }
    }
}
