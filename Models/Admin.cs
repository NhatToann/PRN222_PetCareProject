using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Admin
    {
        public int AdminId { get; set; }

        public string Username { get; set; } = null!;

        public string? Name { get; set; }

        public string? Address { get; set; }

        public string? Phone { get; set; }

        public string? Email { get; set; }

        public string? Password { get; set; }

        public virtual ICollection<ChatMessage> ChatMessages { get; set; } = new List<ChatMessage>();

        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

        public virtual ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
