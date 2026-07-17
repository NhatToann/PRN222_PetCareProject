using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class PetServiceClient : IPetServiceClient
{
    private readonly HttpClient _httpClient;

    public PetServiceClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<FrontendApiResult<IReadOnlyList<PetServiceDto>>> GetAllAsync(string? keyword = null, CancellationToken ct = default)
    {
        var query = BuildQuery(("keyword", Normalize(keyword)));
        return GetJsonAsync<IReadOnlyList<PetServiceDto>>($"api/pet-services{query}", Array.Empty<PetServiceDto>(), ct);
    }

    public async Task<FrontendApiResult<PetServiceDetailDto>> GetDetailAsync(int serviceId, CancellationToken ct = default)
    {
        if (serviceId <= 0)
        {
            return FrontendApiResult<PetServiceDetailDto>.Failure("Service id is invalid.");
        }

        try
        {
            using var response = await _httpClient.GetAsync($"api/pet-services/{serviceId}", ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<PetServiceDetailDto>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<PetServiceDetailDto>(ct);
            return data is null
                ? FrontendApiResult<PetServiceDetailDto>.Failure("Pet service API returned an empty response.")
                : FrontendApiResult<PetServiceDetailDto>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<PetServiceDetailDto>.Failure(ex.Message);
        }
    }

    public Task<FrontendApiResult<PetServiceGroupedDto>> GetGroupedAsync(CancellationToken ct = default)
    {
        return GetJsonAsync<PetServiceGroupedDto>("api/pet-services/grouped", null!, ct);
    }

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
            return data is null
                ? FrontendApiResult<T>.Failure("Pet service API returned an empty response.")
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