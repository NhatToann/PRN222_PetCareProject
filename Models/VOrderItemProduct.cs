using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VOrderItemProduct
    {
        public int ItemId { get; set; }

        public int? OrderId { get; set; }

        public int? ProductId { get; set; }

        public decimal? UnitPrice { get; set; }

        public int? Quantity { get; set; }

        public int? CreatedAt { get; set; }
    }
}
