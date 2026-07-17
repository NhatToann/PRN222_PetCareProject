using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Breed
    {
        public int BreedId { get; set; }

        public int SpeciesId { get; set; }

        public string BreedName { get; set; } = null!;

        public DateTime? CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public virtual ICollection<BreedPricing> BreedPricings { get; set; } = new List<BreedPricing>();

        public virtual ICollection<Pet> Pets { get; set; } = new List<Pet>();

        public virtual Species Species { get; set; } = null!;
    }
}
