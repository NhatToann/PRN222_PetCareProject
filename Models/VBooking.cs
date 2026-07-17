using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VBooking
    {
        public int BookingId { get; set; }

        public int CustomerId { get; set; }

        public int CustomerUserId { get; set; }

        public int PetId { get; set; }

        public DateTime AppointmentStart { get; set; }

        public DateTime AppointmentEnd { get; set; }

        public string? Status { get; set; }

        public string? Note { get; set; }

        public DateTime? CreatedAt { get; set; }

        public int? DoctorId { get; set; }

        public int? StaffId { get; set; }

        public int? AssignedUserId { get; set; }

        public int? ServiceId { get; set; }
    }
}
