using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema; // FIX: Phải gọi thư viện Schema

namespace PetShop.Models
{
    public partial class Product
    {
        public int ProductId { get; set; }

        public string Name { get; set; } = null!;

        public decimal Price { get; set; }

        public int StockQuantity { get; set; }

        public string? Description { get; set; }

        public int? SupplierId { get; set; }

        public int? CategoryId { get; set; }

        public int? AdminId { get; set; }

        public string? ImageUrl { get; set; }

        [Column("is_deleted")]
        public bool IsDeleted { get; set; }

        public virtual Admin? Admin { get; set; }

        public virtual ProductCategory? Category { get; set; }

        public virtual ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();

        public virtual Supplier? Supplier { get; set; }
    }
}