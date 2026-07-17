using System.Net;
using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class ProductCatalogClient : IProductCatalogClient
{
    private readonly HttpClient _httpClient;

    public ProductCatalogClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<ProductCatalogResult<IReadOnlyList<ProductDto_temp>>> GetProductsAsync(string? keyword = null, int? categoryId = null, CancellationToken cancellationToken = default)
    {
        var query = BuildQuery(("keyword", Normalize(keyword)), ("categoryId", categoryId?.ToString()));
        return GetJsonAsync<IReadOnlyList<ProductDto_temp>>($"api/products-temp{query}", Array.Empty<ProductDto_temp>(), cancellationToken);
    }

    public Task<ProductCatalogResult<IReadOnlyList<ProductCategoryFilterDto_temp>>> GetCategoriesAsync(string? keyword = null, CancellationToken cancellationToken = default)
    {
        var query = BuildQuery(("keyword", Normalize(keyword)));
        return GetJsonAsync<IReadOnlyList<ProductCategoryFilterDto_temp>>($"api/products-temp/categories{query}", Array.Empty<ProductCategoryFilterDto_temp>(), cancellationToken);
    }

    public async Task<ProductCatalogResult<ProductDto_temp?>> GetProductAsync(int productId, CancellationToken cancellationToken = default)
    {
        if (productId <= 0)
        {
            return ProductCatalogResult<ProductDto_temp?>.Failure("Product id is invalid.");
        }

        try
        {
            using var response = await _httpClient.GetAsync($"api/products-temp/{productId}", cancellationToken);
            if (response.StatusCode == HttpStatusCode.NotFound)
            {
                return ProductCatalogResult<ProductDto_temp?>.Success(null);
            }

            if (!response.IsSuccessStatusCode)
            {
                return ProductCatalogResult<ProductDto_temp?>.Failure(await ReadErrorAsync(response, cancellationToken), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<ProductDto_temp>(cancellationToken);
            return ProductCatalogResult<ProductDto_temp?>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return ProductCatalogResult<ProductDto_temp?>.Failure(ex.Message);
        }
    }

    private async Task<ProductCatalogResult<T>> GetJsonAsync<T>(string uri, T emptyValue, CancellationToken cancellationToken)
    {
        try
        {
            using var response = await _httpClient.GetAsync(uri, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return ProductCatalogResult<T>.Failure(await ReadErrorAsync(response, cancellationToken), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<T>(cancellationToken);
            return ProductCatalogResult<T>.Success(data ?? emptyValue);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return ProductCatalogResult<T>.Failure(ex.Message);
        }
    }

    private static string BuildQuery(params (string Name, string? Value)[] values)
    {
        var query = values
            .Where(value => !string.IsNullOrWhiteSpace(value.Value))
            .Select(value => $"{Uri.EscapeDataString(value.Name)}={Uri.EscapeDataString(value.Value!)}");
        var joined = string.Join('&', query);
        return string.IsNullOrWhiteSpace(joined) ? string.Empty : $"?{joined}";
    }

    private static string? Normalize(string? value)
    {
        var trimmed = value?.Trim();
        return string.IsNullOrWhiteSpace(trimmed) ? null : trimmed;
    }

    private static async Task<string> ReadErrorAsync(HttpResponseMessage response, CancellationToken cancellationToken)
    {
        var body = await response.Content.ReadAsStringAsync(cancellationToken);
        return string.IsNullOrWhiteSpace(body)
            ? $"API returned {(int)response.StatusCode} {response.ReasonPhrase}."
            : body;
    }
}
