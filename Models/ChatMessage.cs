using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class ChatMessage
    {
        public int MessageId { get; set; }

        public int CustomerId { get; set; }

        public int? StaffId { get; set; }

        public string SenderType { get; set; } = null!;

        public string Message { get; set; } = null!;

        public DateTime? SentAt { get; set; }

        public bool? IsRead { get; set; }

        public virtual Customer Customer { get; set; } = null!;

        public virtual Admin? Staff { get; set; }
    }
}
