namespace PetShop.Models
{
    public sealed record CartItem(
        int ProductId,
        string Name,
        decimal Price,
        int Quantity,
        string? ImageUrl
    );
}
