namespace PetShop.Models
{
    public sealed record PetManageDto(
        int Id,
        int CustomerId,
        string PetName,
        int Age,
        string Gender,
        decimal? WeightKg,
        string? Description,
        string? HealthStatus,
        string? ImagePath,
        int? BreedId,
        string? BreedName,
        int? SpeciesId,
        string? SpeciesName
    );

    public sealed record UpsertPetRequestDto(
        int CustomerId,
        string PetName,
        int Age,
        string Gender,
        decimal? WeightKg,
        string? Description,
        string? HealthStatus,
        string? ImagePath,
        int? BreedId
    );

    public sealed record SpeciesOptionDto(
        int SpeciesId,
        string SpeciesName
    );

    public sealed record BreedOptionDto(
        int BreedId,
        string BreedName,
        int SpeciesId
    );
}
