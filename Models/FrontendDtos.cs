using PetShop.Models;

namespace PetShop.Models;

public sealed record FrontendCartItem(
    int ProductId,
    string Name,
    decimal Price,
    int Quantity,
    string? ImageUrl,
    int StockQuantity);

public sealed record FrontendApiResult<T>(T? Data, string? Error, int? StatusCode)
{
    public bool IsSuccess => string.IsNullOrWhiteSpace(Error);

    public static FrontendApiResult<T> Success(T data) => new(data, null, null);

    public static FrontendApiResult<T> Failure(string error, int? statusCode = null) => new(default, error, statusCode);
}

public sealed record FrontendCheckoutItem(int ProductId, string ItemName, int Quantity, decimal UnitPrice);

public sealed record FrontendCheckoutRequest(
    int? CustomerId,
    string? Email,
    string? CustomerName,
    string Address,
    string PaymentMethod,
    List<FrontendCheckoutItem> Items,
    string? ReturnUrl,
    string? CancelUrl);

public sealed record FrontendCheckoutResponse(string PaymentMethod, string? RedirectUrl, string OrderCode, int OrderId);

public sealed record FrontendOrderSummary(
    int OrderId,
    DateTime OrderDate,
    string? Status,
    string? PaymentStatus,
    string? PaymentMethod,
    decimal TotalAmount,
    string? ShippingAddress,
    string? PrimaryProductName,
    string? PrimaryProductImageUrl,
    int ProductLineCount);

public sealed record FrontendOrderDetailItem(int ProductId, string ProductName, int Quantity, decimal UnitPrice, string? ImageUrl);

public sealed record FrontendOrderDetail(
    int OrderId,
    DateTime OrderDate,
    string? Status,
    string? PaymentStatus,
    string? PaymentMethod,
    decimal TotalAmount,
    string? ShippingAddress,
    IReadOnlyList<FrontendOrderDetailItem> Items);
