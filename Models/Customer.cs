using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Customer
    {
        public int CustomerId { get; set; }

        public string? Name { get; set; }

        public string? Phone { get; set; }

        public string? Email { get; set; }

        public string? Password { get; set; }

        public string? GoogleId { get; set; }

        public string? AddressCustomer { get; set; }

        public string? Status { get; set; }

        public string? OtpCode { get; set; }

        public DateTime? OtpExpiry { get; set; }

        public string? ResetToken { get; set; }

        public DateTime? ResetTokenExpiry { get; set; }

        public string Role { get; set; } = null!;

        public virtual ICollection<BoardingBooking> BoardingBookings { get; set; } = new List<BoardingBooking>();

        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();

        public virtual ICollection<ChatMessage> ChatMessages { get; set; } = new List<ChatMessage>();

        public virtual ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();
    }
}
