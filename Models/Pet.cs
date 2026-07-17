using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Pet
    {
        public int Id { get; set; }

        public int CustomerId { get; set; }

        public string PetName { get; set; } = null!;

        public int Age { get; set; }

        public string Gender { get; set; } = null!;

        public string? Description { get; set; }

        public string? HealthStatus { get; set; }

        public string? ImagePath { get; set; }

        public DateTime? CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public DateTime? DeletedAt { get; set; }

        public decimal? WeightKg { get; set; }

        public int? BreedId { get; set; }

        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();

        public virtual Breed? Breed { get; set; }

        public virtual ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();
    }
}
