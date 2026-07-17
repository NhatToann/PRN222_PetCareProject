using System;
using System.Collections.Generic;

namespace PetShop.Models
{
    public partial class ShiftRequest
    {
        public int RequestId { get; set; }

        public int? EmployeeId { get; set; }

        public string? Type { get; set; }

        public DateOnly TargetDate { get; set; }

        public int? FromShiftId { get; set; }

        public int? ToShiftId { get; set; }

        public string? Reason { get; set; }

        public string? Status { get; set; }

        public int? ApprovedBy { get; set; }

        public DateTime? CreatedAt { get; set; }

        public DateOnly? FromDate { get; set; }

        public DateOnly? ToDate { get; set; }

        public int? ToStaffId { get; set; }

        public bool? ToNotified { get; set; }

        public bool? AdminNotified { get; set; }

        public bool? ApprovedByTo { get; set; }

        public int? DoctorId { get; set; }

        public virtual Doctor? Doctor { get; set; }

        public virtual Staff? Employee { get; set; }
    }
}
