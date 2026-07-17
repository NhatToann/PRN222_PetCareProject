using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class SpaBookingClient : ISpaBookingClient
{
    private readonly HttpClient _httpClient;

    public SpaBookingClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<FrontendApiResult<IReadOnlyList<PetSummaryDto>>> GetPetsAsync(int currentCustomerId, CancellationToken ct = default)
    {
        if (currentCustomerId <= 0)
        {
            return FrontendApiResult<IReadOnlyList<PetSummaryDto>>.Success(Array.Empty<PetSummaryDto>());
        }

        try
        {
            using var response = await _httpClient.GetAsync($"api/spa-booking/pets?customerId={currentCustomerId}", ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<IReadOnlyList<PetSummaryDto>>.Failure(
                    await ReadErrorAsync(response, ct),
                    (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<IReadOnlyList<PetSummaryDto>>(ct);
            return data is null
                ? FrontendApiResult<IReadOnlyList<PetSummaryDto>>.Failure("Spa pets API returned an empty response.")
                : FrontendApiResult<IReadOnlyList<PetSummaryDto>>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<PetSummaryDto>>.Failure(ex.Message);
        }
    }

    public Task<FrontendApiResult<IReadOnlyList<SpaServiceDto>>> GetSpaServicesAsync(CancellationToken ct = default)
    {
        return GetJsonAsync<IReadOnlyList<SpaServiceDto>>("api/spa-booking/services", Array.Empty<SpaServiceDto>(), ct);
    }

    public async Task<FrontendApiResult<SpaAvailabilityResponse>> CheckAvailabilityAsync(
        DateTime start, int durationMin, int quantity, CancellationToken ct = default)
    {
        var payload = new { start, durationMin, quantity };

        try
        {
            using var response = await _httpClient.PostAsJsonAsync("api/spa-booking/availability", payload, ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<SpaAvailabilityResponse>.Failure(
                    await ReadErrorAsync(response, ct),
                    (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<SpaAvailabilityResponse>(ct);
            return data is null
                ? FrontendApiResult<SpaAvailabilityResponse>.Failure("Availability API returned an empty response.")
                : FrontendApiResult<SpaAvailabilityResponse>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<SpaAvailabilityResponse>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<SpaBookingEstimateDto>> EstimateAsync(
        int currentCustomerId, SpaBookingEstimateRequest req, CancellationToken ct = default)
    {
        if (currentCustomerId <= 0)
        {
            return FrontendApiResult<SpaBookingEstimateDto>.Failure("Thiếu thông tin khách hàng.");
        }

        return await PostJsonAsync<SpaBookingEstimateDto>($"api/spa-booking/estimate?customerId={currentCustomerId}", req, ct);
    }

    public async Task<FrontendApiResult<SpaBookingDto>> CreateAsync(
        int currentCustomerId, CreateSpaBookingRequest req, CancellationToken ct = default)
    {
        if (currentCustomerId <= 0)
        {
            return FrontendApiResult<SpaBookingDto>.Failure("Thiếu thông tin khách hàng.");
        }

        return await PostJsonAsync<SpaBookingDto>($"api/spa-booking?customerId={currentCustomerId}", req, ct);
    }

    public Task<FrontendApiResult<IReadOnlyList<SpaBookingDto>>> GetHistoryAsync(int currentCustomerId, CancellationToken ct = default)
    {
        if (currentCustomerId <= 0)
        {
            return Task.FromResult(FrontendApiResult<IReadOnlyList<SpaBookingDto>>.Success(Array.Empty<SpaBookingDto>()));
        }

        return GetJsonAsync<IReadOnlyList<SpaBookingDto>>($"api/spa-booking/history?customerId={currentCustomerId}", Array.Empty<SpaBookingDto>(), ct);
    }

    public async Task<FrontendApiResult<SpaBookingInvoiceDto?>> GetInvoiceAsync(int bookingId, int currentCustomerId, CancellationToken ct = default)
    {
        if (bookingId <= 0)
        {
            return FrontendApiResult<SpaBookingInvoiceDto?>.Failure("Booking id is invalid.");
        }

        try
        {
            using var response = await _httpClient.GetAsync($"api/spa-booking/{bookingId}/invoice", ct);
            if (response.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                return FrontendApiResult<SpaBookingInvoiceDto?>.Success(null);
            }

            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<SpaBookingInvoiceDto?>.Failure(
                    await ReadErrorAsync(response, ct),
                    (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<SpaBookingInvoiceDto>(ct);
            return data is null
                ? FrontendApiResult<SpaBookingInvoiceDto?>.Failure("Invoice API returned an empty response.")
                : FrontendApiResult<SpaBookingInvoiceDto?>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<SpaBookingInvoiceDto?>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<object>> UpdateStatusAsync(
        int bookingId, int currentCustomerId, string status, CancellationToken ct = default)
    {
        if (bookingId <= 0)
        {
            return FrontendApiResult<object>.Failure("Booking id is invalid.");
        }

        var payload = new { status };
        return await PatchJsonAsync<object>($"api/spa-booking/{bookingId}/status", payload, ct);
    }

    public async Task<FrontendApiResult<object>> SubmitReviewAsync(
        int currentCustomerId, CreateSpaReviewRequest req, CancellationToken ct = default)
    {
        if (currentCustomerId <= 0)
        {
            return FrontendApiResult<object>.Failure("Thiếu thông tin khách hàng.");
        }

        return await PostJsonAsync<object>($"api/spa-booking/review?customerId={currentCustomerId}", req, ct);
    }

    public async Task<FrontendApiResult<PayOSCheckoutResult>> CreateSpaPayOSPaymentAsync(
        int bookingId, IReadOnlyList<int>? bookingIds, string returnUrl, string cancelUrl, CancellationToken ct = default)
    {
        var payload = new
        {
            bookingId,
            bookingIds,
            returnUrl,
            cancelUrl
        };

        try
        {
            using var response = await _httpClient.PostAsJsonAsync("api/payos/spa/create", payload, ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<PayOSCheckoutResult>.Failure(
                    await ReadErrorAsync(response, ct),
                    (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<PayOSCheckoutResult>(ct);
            return data is null
                ? FrontendApiResult<PayOSCheckoutResult>.Failure("PayOS spa create returned an empty response.")
                : FrontendApiResult<PayOSCheckoutResult>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<PayOSCheckoutResult>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<PayOSPaymentStatusResult>> GetPayOSStatusAsync(int orderCode, CancellationToken ct = default)
    {
        try
        {
            using var response = await _httpClient.GetAsync($"api/payos/status/{orderCode}", ct);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<PayOSPaymentStatusResult>.Failure(
                    await ReadErrorAsync(response, ct),
                    (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<PayOSPaymentStatusResult>(ct);
            return data is null
                ? FrontendApiResult<PayOSPaymentStatusResult>.Failure("PayOS status returned an empty response.")
                : FrontendApiResult<PayOSPaymentStatusResult>.Success(data);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            return FrontendApiResult<PayOSPaymentStatusResult>.Failure(ex.Message);
        }
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
                ? FrontendApiResult<T>.Failure("API returned an empty response.")
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

    private async Task<FrontendApiResult<T>> PostJsonAsync<T>(string uri, object request, CancellationToken cancellationToken)
    {
        try
        {
            using var response = await _httpClient.PostAsJsonAsync(uri, request, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<T>.Failure(await ReadErrorAsync(response, cancellationToken), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<T>(cancellationToken);
            return data is null
                ? FrontendApiResult<T>.Failure("API returned an empty response.")
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

    private async Task<FrontendApiResult<T>> PatchJsonAsync<T>(string uri, object request, CancellationToken cancellationToken)
    {
        try
        {
            var json = System.Text.Json.JsonSerializer.Serialize(request);
            using var requestMessage = new HttpRequestMessage(HttpMethod.Patch, uri)
            {
                Content = new StringContent(json, System.Text.Encoding.UTF8, "application/json")
            };
            using var response = await _httpClient.SendAsync(requestMessage, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<T>.Failure(await ReadErrorAsync(response, cancellationToken), (int)response.StatusCode);
            }

            if (response.Content.Headers.ContentLength is 0)
            {
                return FrontendApiResult<T>.Success(default!);
            }

            var data = await response.Content.ReadFromJsonAsync<T>(cancellationToken);
            return data is null
                ? FrontendApiResult<T>.Failure("API returned an empty response.")
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
