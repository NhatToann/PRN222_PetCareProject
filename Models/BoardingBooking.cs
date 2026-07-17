using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class BoardingBooking
    {
        public int BookingId { get; set; }

        public int CustomerId { get; set; }

        public string RoomType { get; set; } = null!;

        public decimal PricePerDay { get; set; }

        public int BoardingDays { get; set; }

        public DateOnly CheckInDate { get; set; }

        public DateOnly CheckOutDate { get; set; }

        public string? CheckInTime { get; set; }

        public string? CheckOutTime { get; set; }

        public string? PetInfo { get; set; }

        public string? SpecialNotes { get; set; }

        public string EmergencyPhone1 { get; set; } = null!;

        public string? EmergencyPhone2 { get; set; }

        public string Status { get; set; } = null!;

        public DateTime? CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public decimal TotalPrice { get; set; }

        public virtual Customer Customer { get; set; } = null!;
    }
}
