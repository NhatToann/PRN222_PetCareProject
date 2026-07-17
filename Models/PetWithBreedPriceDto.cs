namespace PetShop.Models
{
    public sealed record PetWithBreedPriceDto(
        int PetId,
        string PetName,
        int? BreedId,
        string? BreedName,
        decimal? PriceAdjustPercent,
        decimal? FinalPrice
    );
}
