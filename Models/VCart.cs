using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VCart
    {
        public int ItemId { get; set; }

        public int? OrderId { get; set; }

        public int? CustomerId { get; set; }

        public int? CustomerUserId { get; set; }

        public string ItemType { get; set; } = null!;

        public int? ItemRefId { get; set; }

        public decimal? UnitPrice { get; set; }

        public int? Quantity { get; set; }
    }
}
