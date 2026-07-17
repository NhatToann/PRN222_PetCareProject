using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class AuthClient : IAuthClient
{
    private readonly HttpClient _httpClient;

    public AuthClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public Task<FrontendApiResult<AuthResponseDto>> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default) =>
        PostJsonAsync<AuthResponseDto>("api/auth/login", request, cancellationToken);

    public Task<FrontendApiResult<AuthResponseDto>> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default) =>
        PostJsonAsync<AuthResponseDto>("api/auth/register", request, cancellationToken);

    public Task<FrontendApiResult<SimpleMessageDto>> SendOtpAsync(SendEmailOtpRequestDto request, CancellationToken cancellationToken = default) =>
        PostJsonAsync<SimpleMessageDto>("api/auth/send-otp", request, cancellationToken);

    public Task<FrontendApiResult<SimpleMessageDto>> VerifyOtpAsync(VerifyEmailOtpRequestDto request, CancellationToken cancellationToken = default) =>
        PostJsonAsync<SimpleMessageDto>("api/auth/verify-otp", request, cancellationToken);

    public Task<FrontendApiResult<SimpleMessageDto>> ResetPasswordAsync(ResetPasswordRequestDto request, CancellationToken cancellationToken = default) =>
        PostJsonAsync<SimpleMessageDto>("api/auth/reset-password", request, cancellationToken);

    public Task<FrontendApiResult<AuthResponseDto>> GoogleLoginAsync(GoogleLoginRequestDto request, CancellationToken cancellationToken = default) =>
        PostJsonAsync<AuthResponseDto>("api/auth/google-login", request, cancellationToken);

    public async Task<FrontendApiResult<SimpleMessageDto>> GetGoogleClientIdAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var response = await _httpClient.GetAsync("api/auth/google-client-id", cancellationToken);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<SimpleMessageDto>.Failure(await ReadErrorAsync(response, cancellationToken), (int)response.StatusCode);
            var data = await response.Content.ReadFromJsonAsync<System.Text.Json.JsonElement>(cancellationToken);
            var clientId = data.TryGetProperty("clientId", out var prop) ? prop.GetString() ?? "" : "";
            return FrontendApiResult<SimpleMessageDto>.Success(new SimpleMessageDto(clientId));
        }
        catch (Exception ex)
        {
            return FrontendApiResult<SimpleMessageDto>.Failure(ex.Message);
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

    private static async Task<string> ReadErrorAsync(HttpResponseMessage response, CancellationToken cancellationToken)
    {
        var body = await response.Content.ReadAsStringAsync(cancellationToken);
        return string.IsNullOrWhiteSpace(body) ? $"API returned {(int)response.StatusCode}." : body;
    }
}
