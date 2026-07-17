using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class Species
    {
        public int SpeciesId { get; set; }

        public string SpeciesName { get; set; } = null!;

        public DateTime? CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public virtual ICollection<Breed> Breeds { get; set; } = new List<Breed>();
    }
}
