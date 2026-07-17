namespace PetShop.Models;

public sealed record ProductCatalogResult<T>(T? Data, string? Error, int? StatusCode)
{
    public bool IsSuccess => Error is null;

    public static ProductCatalogResult<T> Success(T data) => new(data, null, null);

    public static ProductCatalogResult<T> Failure(string error, int? statusCode = null) => new(default, error, statusCode);
}
