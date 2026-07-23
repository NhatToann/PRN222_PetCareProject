using System.ComponentModel.DataAnnotations;

namespace PetShop.Models
{
    public sealed record BoardingCheckoutRequest(
        int RoomId,
        string RoomName,
        string RoomType,
        DateOnly CheckIn,
        DateOnly CheckOut,
        int Days,
        int Pets,
        string? Notes,
        decimal PricePerDay,
        decimal TotalPrice,
        int? CustomerId,
        string? CustomerName,
        string? CustomerEmail,
        string? CustomerPhone,
        string PaymentMethod
    );

    public sealed record BoardingCheckoutResponse(
        bool Success,
        string? Message,
        int? BookingId,
        string? OrderCode,
        string? RedirectUrl,
        string PaymentMethod
    );

    public sealed record BoardingBookingPaymentStatusResult(
        int BookingId,
        string BookingStatus,
        string PaymentStatus,
        int? OrderCode
    );

    public sealed record BoardingBookingDto(
        int BookingId,
        int CustomerId,
        string RoomType,
        decimal PricePerDay,
        int BoardingDays,
        DateOnly CheckInDate,
        DateOnly CheckOutDate,
        string? CheckInTime,
        string? CheckOutTime,
        string? PetInfo,
        string? SpecialNotes,
        string? EmergencyPhone1,
        string? EmergencyPhone2,
        string Status,
        DateTime? CreatedAt,
        DateTime? UpdatedAt,
        decimal TotalPrice,
        string? PaymentMethod,
        CustomerDto? Customer
    );

    public sealed record CustomerDto(
        int CustomerId,
        string? Name,
        string? Email,
        string? Phone
    );

    public sealed record BoardingAvailabilityDto(
        string RoomType,
        int TotalRooms,
        int ActiveBookings,
        int AvailableRooms
    );

    public sealed record BoardingCatalogDto(
        IReadOnlyList<BoardingRoom> Rooms,
        IReadOnlyList<BoardingAvailabilityDto> Availability
    );
}
