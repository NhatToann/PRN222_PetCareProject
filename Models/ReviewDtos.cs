using System;

namespace PetShop.Models
{
    public sealed record ReviewDisplayDto(
        int ReviewId,
        int ServiceId,
        int Rating,
        string? Comment,
        int? BookingId,
        int? CustomerId,
        string? CustomerName,
        DateTime CreatedAt
    );

    public sealed record CreateProductReviewRequestDto(
        int OrderId,
        int Rating,
        string? Comment
    );

    public sealed record ProductReviewUpsertResult(
        bool Success,
        string Message
    );
}
