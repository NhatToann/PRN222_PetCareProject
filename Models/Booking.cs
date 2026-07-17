using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Booking
    {
        public int BookingId { get; set; }

        public int CustomerId { get; set; }

        public int PetId { get; set; }

        public DateTime AppointmentStart { get; set; }

        public DateTime AppointmentEnd { get; set; }

        public string? Status { get; set; }

        public string? Note { get; set; }

        public DateTime? CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public int? DoctorId { get; set; }

        public int? StaffId { get; set; }

        public int? OrderId { get; set; }

        public virtual ICollection<BookingService> BookingServices { get; set; } = new List<BookingService>();

        public virtual Customer Customer { get; set; } = null!;

        public virtual Doctor? Doctor { get; set; }

        public virtual ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();

        public virtual Pet Pet { get; set; } = null!;

        public virtual Staff? Staff { get; set; }
    }
}
