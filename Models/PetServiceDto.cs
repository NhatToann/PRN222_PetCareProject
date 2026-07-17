namespace PetShop.Models
{
    public sealed record PetServiceDto(
        int ServiceId,
        string Name,
        string? Description,
        decimal Price,
        int Duration,
        string ServiceType,
        string? Status,
        DateTime? CreatedAt,
        DateTime? UpdatedAt
    );
}
