using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class MedicalRecord
    {
        public int RecordId { get; set; }

        public int BookingId { get; set; }

        public int PetId { get; set; }

        public int DoctorId { get; set; }

        public int CustomerId { get; set; }

        public DateTime ExaminationDate { get; set; }

        public string? Symptoms { get; set; }

        public string? Diagnosis { get; set; }

        public string? Treatment { get; set; }

        public string? Prescription { get; set; }

        public decimal? Weight { get; set; }

        public decimal? Temperature { get; set; }

        public int? HeartRate { get; set; }

        public string? BloodPressure { get; set; }

        public string? Notes { get; set; }

        public DateOnly? FollowUpDate { get; set; }

        public string? FollowUpNotes { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        public virtual Booking Booking { get; set; } = null!;

        public virtual Customer Customer { get; set; } = null!;

        public virtual Doctor Doctor { get; set; } = null!;

        public virtual Pet Pet { get; set; } = null!;
    }
}
