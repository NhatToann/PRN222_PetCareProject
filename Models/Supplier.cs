using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Supplier
    {
        public int SupplierId { get; set; }

        public string? Address { get; set; }

        public string? Phone { get; set; }

        public string? NameCompany { get; set; }

        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
