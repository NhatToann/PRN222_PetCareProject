namespace PetShop.Models
{
    public sealed record PetServiceDetailDto(
        PetServiceDto Service,
        double AvgRating,
        int ReviewCount,
        IReadOnlyList<ReviewDisplayDto> Reviews
    );
}
