using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class OrderClient : IOrderClient
{
    private readonly HttpClient _httpClient;

    public OrderClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<FrontendApiResult<IReadOnlyList<FrontendOrderSummary>>> GetHistoryAsync(int customerId, CancellationToken cancellationToken = default) =>
        GetJsonAsync<IReadOnlyList<FrontendOrderSummary>>($"api/orders-temp/history?customerId={customerId}", Array.Empty<FrontendOrderSummary>(), cancellationToken);

    public Task<FrontendApiResult<FrontendOrderDetail>> GetDetailAsync(int orderId, int customerId, CancellationToken cancellationToken = default) =>
        GetJsonAsync<FrontendOrderDetail>($"api/orders-temp/{orderId}?customerId={customerId}", null, cancellationToken)!;

    public Task<FrontendApiResult<FrontendOrderSummary>> MarkDeliveredAsync(int orderId, int customerId, CancellationToken cancellationToken = default) =>
        SendJsonAsync<FrontendOrderSummary>(HttpMethod.Patch, $"api/orders-temp/{orderId}/delivered?customerId={customerId}", null, cancellationToken);

    private async Task<FrontendApiResult<T>> GetJsonAsync<T>(string uri, T? emptyValue, CancellationToken cancellationToken)
    {
        try
        {
            using var response = await _httpClient.GetAsync(uri, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<T>.Failure(await response.Content.ReadAsStringAsync(cancellationToken), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<T>(cancellationToken);
            return FrontendApiResult<T>.Success(data ?? emptyValue!);
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

    private async Task<FrontendApiResult<T>> SendJsonAsync<T>(
        HttpMethod method,
        string uri,
        object? payload,
        CancellationToken cancellationToken)
    {
        try
        {
            using var request = new HttpRequestMessage(method, uri);
            if (payload is not null)
            {
                request.Content = JsonContent.Create(payload);
            }

            using var response = await _httpClient.SendAsync(request, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<T>.Failure(await response.Content.ReadAsStringAsync(cancellationToken), (int)response.StatusCode);
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
}
