using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class ReviewClient : IReviewClient
{
    private readonly HttpClient _httpClient;

    public ReviewClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<FrontendApiResult<IReadOnlyList<ReviewDisplayDto>>> GetProductReviewsAsync(
        int productId,
        CancellationToken cancellationToken = default) =>
        GetJsonAsync<IReadOnlyList<ReviewDisplayDto>>(
            $"api/reviews/products/{productId}",
            Array.Empty<ReviewDisplayDto>(),
            cancellationToken);

    public Task<FrontendApiResult<ProductReviewUpsertResult>> UpsertProductReviewAsync(
        int productId,
        int customerId,
        CreateProductReviewRequestDto request,
        CancellationToken cancellationToken = default) =>
        SendJsonAsync<ProductReviewUpsertResult>(
            $"api/reviews/products/{productId}?customerId={customerId}",
            request,
            cancellationToken);

    private async Task<FrontendApiResult<T>> GetJsonAsync<T>(string uri, T emptyValue, CancellationToken cancellationToken)
    {
        try
        {
            using var response = await _httpClient.GetAsync(uri, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<T>.Failure(await ReadErrorAsync(response, cancellationToken), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<T>(cancellationToken);
            return FrontendApiResult<T>.Success(data ?? emptyValue);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<T>.Failure(ex.Message);
        }
    }

    private async Task<FrontendApiResult<T>> SendJsonAsync<T>(string uri, object payload, CancellationToken cancellationToken)
    {
        try
        {
            using var response = await _httpClient.PostAsJsonAsync(uri, payload, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<T>.Failure(await ReadErrorAsync(response, cancellationToken), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<T>(cancellationToken);
            return data is null
                ? FrontendApiResult<T>.Failure("API returned an empty response.", (int)response.StatusCode)
                : FrontendApiResult<T>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<T>.Failure(ex.Message);
        }
    }

    private static async Task<string> ReadErrorAsync(HttpResponseMessage response, CancellationToken cancellationToken)
    {
        var body = await response.Content.ReadAsStringAsync(cancellationToken);
        return string.IsNullOrWhiteSpace(body)
            ? $"API returned {(int)response.StatusCode} {response.ReasonPhrase}."
            : body;
    }
}
