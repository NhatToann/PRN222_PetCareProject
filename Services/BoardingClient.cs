using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class BoardingClient : IBoardingClient
{
    private readonly HttpClient _httpClient;

    public BoardingClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<FrontendApiResult<IReadOnlyList<BoardingRoom>>> GetRoomsAsync(CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.GetAsync("api/boarding-rooms", ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<IReadOnlyList<BoardingRoom>>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            
            var data = await response.Content.ReadFromJsonAsync<List<BoardingRoom>>(ct);
            return data is null
                ? FrontendApiResult<IReadOnlyList<BoardingRoom>>.Failure("API returned an empty response.")
                : FrontendApiResult<IReadOnlyList<BoardingRoom>>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<BoardingRoom>>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<BoardingRoom>> GetRoomByIdAsync(int roomId, CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.GetAsync($"api/boarding-rooms/{roomId}", ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<BoardingRoom>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            
            var data = await response.Content.ReadFromJsonAsync<BoardingRoom>(ct);
            return data is null
                ? FrontendApiResult<BoardingRoom>.Failure("Room not found.")
                : FrontendApiResult<BoardingRoom>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<BoardingRoom>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<IReadOnlyList<BoardingAvailabilityDto>>> GetAvailabilityAsync(CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.GetAsync("api/boarding-rooms/availability", ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<IReadOnlyList<BoardingAvailabilityDto>>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            
            var data = await response.Content.ReadFromJsonAsync<List<BoardingAvailabilityDto>>(ct);
            return data is null
                ? FrontendApiResult<IReadOnlyList<BoardingAvailabilityDto>>.Failure("API returned an empty response.")
                : FrontendApiResult<IReadOnlyList<BoardingAvailabilityDto>>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<BoardingAvailabilityDto>>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<BoardingCatalogDto>> GetCatalogAsync(CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.GetAsync("api/boarding-rooms/catalog", ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<BoardingCatalogDto>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);

            var data = await response.Content.ReadFromJsonAsync<BoardingCatalogDto>(ct);
            return data is null
                ? FrontendApiResult<BoardingCatalogDto>.Failure("API returned an empty response.")
                : FrontendApiResult<BoardingCatalogDto>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<BoardingCatalogDto>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<BoardingCheckoutResponse>> CheckoutAsync(BoardingCheckoutRequest request, CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync("api/boarding-rooms/checkout", request, ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<BoardingCheckoutResponse>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);

            var data = await response.Content.ReadFromJsonAsync<BoardingCheckoutResponse>(ct);
            return data is null
                ? FrontendApiResult<BoardingCheckoutResponse>.Failure("Checkout failed.")
                : FrontendApiResult<BoardingCheckoutResponse>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<BoardingCheckoutResponse>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<IReadOnlyList<BoardingBookingDto>>> GetAllBookingsAsync(CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.GetAsync("api/boarding-rooms/bookings", ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<IReadOnlyList<BoardingBookingDto>>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);

            var data = await response.Content.ReadFromJsonAsync<List<BoardingBookingDto>>(ct);
            return data is null
                ? FrontendApiResult<IReadOnlyList<BoardingBookingDto>>.Failure("API returned an empty response.")
                : FrontendApiResult<IReadOnlyList<BoardingBookingDto>>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<BoardingBookingDto>>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<bool>> ConfirmCheckinAsync(int bookingId, CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.PatchAsync($"api/boarding-rooms/bookings/{bookingId}/checkin", null, ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<bool>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            return FrontendApiResult<bool>.Success(true);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<bool>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<bool>> ConfirmCheckoutAsync(int bookingId, CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.PatchAsync($"api/boarding-rooms/bookings/{bookingId}/checkout", null, ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<bool>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            return FrontendApiResult<bool>.Success(true);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<bool>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<bool>> RejectBookingAsync(int bookingId, string reason, CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.PatchAsync(
                $"api/boarding-rooms/bookings/{bookingId}/reject?reason={Uri.EscapeDataString(reason)}",
                null, ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<bool>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            return FrontendApiResult<bool>.Success(true);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<bool>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<BoardingBookingPaymentStatusResult>> GetBookingPaymentStatusAsync(int bookingId, CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.GetAsync($"api/boarding-rooms/bookings/{bookingId}/payment-status", ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<BoardingBookingPaymentStatusResult>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);

            var data = await response.Content.ReadFromJsonAsync<BoardingBookingPaymentStatusResult>(ct);
            return data is null
                ? FrontendApiResult<BoardingBookingPaymentStatusResult>.Failure("API returned empty response.")
                : FrontendApiResult<BoardingBookingPaymentStatusResult>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<BoardingBookingPaymentStatusResult>.Failure(ex.Message);
        }
    }

    private static async Task<string> ReadErrorAsync(HttpResponseMessage response, CancellationToken ct)
    {
        var body = await response.Content.ReadAsStringAsync(ct);
        return string.IsNullOrWhiteSpace(body) ? $"API returned {(int)response.StatusCode}." : body;
    }
}
