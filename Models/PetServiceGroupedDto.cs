namespace PetShop.Models
{
    public sealed record PetServiceGroupedDto(
        IReadOnlyList<PetServiceDto> SpaServices,
        IReadOnlyList<PetServiceDto> HealthCheckServices,
        string SeparatorText
    );
}
