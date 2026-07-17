using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class PetsClient : IPetsClient
{
    private readonly HttpClient _httpClient;
    private readonly UserSessionService _userSession;

    public PetsClient(HttpClient httpClient, UserSessionService userSession)
    {
        _httpClient = httpClient;
        _userSession = userSession;
    }

    public async Task<FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>> GetByCustomerAsync(
        int customerId, CancellationToken ct = default)
    {
        if (customerId <= 0)
        {
            return FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Failure("Thiếu customerId.");
        }

        try
        {
            using var response = await _httpClient.GetAsync($"api/pets/customer/{customerId}", ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Failure(
                    await ReadErrorAsync(response, ct),
                    (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<IReadOnlyList<PetWithBreedPriceDto>>(ct);
            return FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Success(data ?? Array.Empty<PetWithBreedPriceDto>());
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>> GetWithPricingAsync(
        int customerId, int serviceId, CancellationToken ct = default)
    {
        if (customerId <= 0 || serviceId <= 0)
        {
            return FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Failure("Thiếu customerId hoặc serviceId.");
        }

        try
        {
            var url = $"api/pets/customer/{customerId}/service/{serviceId}/pricing";
            using var response = await _httpClient.GetAsync(url, ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Failure(
                    await ReadErrorAsync(response, ct),
                    (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<IReadOnlyList<PetWithBreedPriceDto>>(ct);
            return data is null
                ? FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Failure("Pets pricing API returned an empty response.")
                : FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<IReadOnlyList<PetManageDto>>> GetManageAsync(int customerId, CancellationToken ct = default)
    {
        if (customerId <= 0)
        {
            return FrontendApiResult<IReadOnlyList<PetManageDto>>.Failure("Thiếu customerId.");
        }

        try
        {
            using var request = CreateAuthedRequest(HttpMethod.Get, $"api/pets/customer/{customerId}/manage");
            using var response = await _httpClient.SendAsync(request, ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<IReadOnlyList<PetManageDto>>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<IReadOnlyList<PetManageDto>>(ct);
            return FrontendApiResult<IReadOnlyList<PetManageDto>>.Success(data ?? Array.Empty<PetManageDto>());
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<PetManageDto>>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<IReadOnlyList<SpeciesOptionDto>>> GetSpeciesAsync(CancellationToken ct = default)
    {
        try
        {
            using var response = await _httpClient.GetAsync("api/pets/meta/species", ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<IReadOnlyList<SpeciesOptionDto>>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<IReadOnlyList<SpeciesOptionDto>>(ct);
            return FrontendApiResult<IReadOnlyList<SpeciesOptionDto>>.Success(data ?? Array.Empty<SpeciesOptionDto>());
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<SpeciesOptionDto>>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<IReadOnlyList<BreedOptionDto>>> GetBreedsAsync(int? speciesId = null, CancellationToken ct = default)
    {
        try
        {
            var url = speciesId.HasValue
                ? $"api/pets/meta/breeds?speciesId={speciesId.Value}"
                : "api/pets/meta/breeds";
            using var response = await _httpClient.GetAsync(url, ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<IReadOnlyList<BreedOptionDto>>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<IReadOnlyList<BreedOptionDto>>(ct);
            return FrontendApiResult<IReadOnlyList<BreedOptionDto>>.Success(data ?? Array.Empty<BreedOptionDto>());
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<BreedOptionDto>>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<PetManageDto>> CreateAsync(UpsertPetRequestDto request, CancellationToken ct = default)
    {
        try
        {
            using var httpRequest = CreateAuthedRequest(HttpMethod.Post, "api/pets");
            httpRequest.Content = JsonContent.Create(request);
            using var response = await _httpClient.SendAsync(httpRequest, ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<PetManageDto>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<PetManageDto>(ct);
            return data is null
                ? FrontendApiResult<PetManageDto>.Failure("API returned an empty response.", (int)response.StatusCode)
                : FrontendApiResult<PetManageDto>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<PetManageDto>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<PetManageDto>> UpdateAsync(int petId, UpsertPetRequestDto request, CancellationToken ct = default)
    {
        try
        {
            using var httpRequest = CreateAuthedRequest(HttpMethod.Put, $"api/pets/{petId}");
            httpRequest.Content = JsonContent.Create(request);
            using var response = await _httpClient.SendAsync(httpRequest, ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<PetManageDto>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<PetManageDto>(ct);
            return data is null
                ? FrontendApiResult<PetManageDto>.Failure("API returned an empty response.", (int)response.StatusCode)
                : FrontendApiResult<PetManageDto>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<PetManageDto>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<bool>> DeleteAsync(int petId, int customerId, CancellationToken ct = default)
    {
        try
        {
            using var request = CreateAuthedRequest(HttpMethod.Delete, $"api/pets/{petId}?customerId={customerId}");
            using var response = await _httpClient.SendAsync(request, ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<bool>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            }

            return FrontendApiResult<bool>.Success(true);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<bool>.Failure(ex.Message);
        }
    }

    private static async Task<string> ReadErrorAsync(HttpResponseMessage response, CancellationToken ct)
    {
        var body = await response.Content.ReadAsStringAsync(ct);
        return string.IsNullOrWhiteSpace(body)
            ? $"API returned {(int)response.StatusCode} {response.ReasonPhrase}."
            : body;
    }

    private HttpRequestMessage CreateAuthedRequest(HttpMethod method, string uri)
    {
        var request = new HttpRequestMessage(method, uri);
        var user = _userSession.CurrentUser;
        if (user is not null)
        {
            request.Headers.TryAddWithoutValidation("X-User-Id", user.UserId.ToString(System.Globalization.CultureInfo.InvariantCulture));
            request.Headers.TryAddWithoutValidation("X-Customer-Id", user.UserId.ToString(System.Globalization.CultureInfo.InvariantCulture));
            request.Headers.TryAddWithoutValidation("X-User-Role", user.Role);
        }

        return request;
    }
}
