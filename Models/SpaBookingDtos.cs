using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace PetShop.Models
{
    public sealed record PetSummaryDto(
        int PetId,
        string PetName,
        int? BreedId,
        string? BreedName,
        string? SpeciesName,
        decimal? WeightKg
    );

    public sealed record SpaServiceDto(
        int ServiceId,
        string Name,
        string? Description,
        decimal Price,
        int Duration,
        string ServiceType,
        string? Status
    );

    public sealed record SpaCartItemRequest(
        int ServiceId,
        int Quantity
    );

    public sealed record SpaBookingEstimateRequest(
        IReadOnlyList<int> PetIds,
        IReadOnlyList<SpaCartItemRequest> Items
    );

    public sealed record SpaBookingEstimateItemDto(
        int PetId,
        string PetName,
        int ServiceId,
        string ServiceName,
        int Quantity,
        decimal UnitPrice,
        int DurationMin
    );

    public sealed record SpaBookingEstimateDto(
        IReadOnlyList<SpaBookingEstimateItemDto> Items,
        int PerPetDurationMin,
        int TotalDurationMin,
        int PetCount,
        decimal TotalPrice
    );

    public sealed record CreateSpaBookingRequest(
        IReadOnlyList<int> PetIds,
        DateTime AppointmentStart,
        string? Note,
        IReadOnlyList<SpaCartItemRequest> Items,
        string? PaymentMethod
    );

    public sealed record SpaBookingItemDto(
        int ServiceId,
        string ServiceName,
        int Quantity,
        decimal UnitPrice,
        int DurationMin
    );

    public sealed record SpaBookingDto(
        int BookingId,
        int PetId,
        string PetName,
        string? BreedName,
        string? SpeciesName,
        string? CustomerName,
        string? CustomerPhone,
        DateTime AppointmentStart,
        DateTime AppointmentEnd,
        string? Status,
        DateTime? CreatedAt,
        IReadOnlyList<SpaBookingItemDto> Items,
        decimal TotalPrice,
        string? PaymentMethod
    )
    {
        [JsonIgnore]
        public IReadOnlyList<int>? BookingIds { get; init; }
    }

    public sealed record SpaBookingInvoiceDto(
        int BookingId,
        string CustomerName,
        string CustomerEmail,
        int PetId,
        string PetName,
        DateTime AppointmentStart,
        DateTime AppointmentEnd,
        string? Status,
        DateTime? CreatedAt,
        IReadOnlyList<SpaBookingItemDto> Items,
        decimal TotalPrice,
        string? PaymentMethod
    );

    public sealed record SpaAvailabilityResponse(
        bool IsAvailable,
        int ExistingBookings,
        int MaxCapacity,
        DateTime? SuggestedStart,
        string? Message
    );

    /// <summary>
    /// Validate giờ đặt dịch vụ SPA có nằm trong ca làm việc của nhân viên hay không.
    /// </summary>
    public sealed record BookingSlotValidationRequest(
        DateTime AppointmentStart,
        int DurationMinutes
    );

    public sealed record BookingSlotShiftDto(
        int ScheduleId,
        TimeOnly StartTime,
        TimeOnly EndTime,
        string ShiftLabel
    );

    public sealed record BookingSlotValidationResult(
        bool IsValid,
        DateTime AppointmentStart,
        DateTime AppointmentEnd,
        int DurationMinutes,
        string? Message,
        IReadOnlyList<BookingSlotShiftDto> AvailableShifts,
        IReadOnlyList<BookingSlotShiftDto> ConflictingShifts
    );

    public sealed record CreateSpaReviewRequest(
        int BookingId,
        int ServiceId,
        int Rating,
        string? Comment
    );
}
