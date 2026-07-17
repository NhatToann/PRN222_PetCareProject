using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class BoardingRoom
    {
        public int RoomId { get; set; }

        public string RoomName { get; set; } = null!;

        public string RoomType { get; set; } = null!;

        public int Rooms { get; set; }

        public decimal PricePerDay { get; set; }

        public string? Description { get; set; }

        public DateTime? CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }
    }
}
