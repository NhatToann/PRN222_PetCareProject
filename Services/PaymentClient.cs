using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class PaymentClient : IPaymentClient
{
    private readonly HttpClient _httpClient;

    public PaymentClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<FrontendApiResult<PayOSPaymentStatusResult>> GetPayOSStatusAsync(int orderCode, CancellationToken cancellationToken = default)
    {
        try
        {
            using var response = await _httpClient.GetAsync($"api/payos/status/{orderCode}", cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return FrontendApiResult<PayOSPaymentStatusResult>.Failure(await response.Content.ReadAsStringAsync(cancellationToken), (int)response.StatusCode);
            }

            var data = await response.Content.ReadFromJsonAsync<PayOSPaymentStatusResult>(cancellationToken);
            return data is null
                ? FrontendApiResult<PayOSPaymentStatusResult>.Failure("Payment status API returned an empty response.")
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
}
