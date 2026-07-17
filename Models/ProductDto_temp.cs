namespace PetShop.Models
{
    public sealed record ProductDto_temp(
        int ProductId,
        string Name,
        decimal Price,
        int StockQuantity,
        string? Description,
        string? ImageUrl,
        int? CategoryId,
        string? CategoryName,
        int? SupplierId,
        string? SupplierName,
        double AvgRating,
        int ReviewCount
    );

}
