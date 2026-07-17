using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class VwPetWithBreedPricing
    {
        public int Id { get; set; }

        public string PetName { get; set; } = null!;

        public string Species { get; set; } = null!;

        public string Breed { get; set; } = null!;

        public decimal? BathPrice { get; set; }

        public decimal? GroomPrice { get; set; }
    }
}
