namespace PetShop.Models
{
    public sealed record BreedPricingDto(
        int BreedPricingId,
        int BreedId,
        string BreedName,
        string? SpeciesName,
        decimal PriceAdjustPercent
    );

    public sealed record CreateBreedPricingRequest(
        int BreedId,
        decimal PriceAdjustPercent
    );

    public sealed record UpdateBreedPricingRequest(
        decimal PriceAdjustPercent
    );
}
