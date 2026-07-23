using System.Net.Http.Json;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services;

public sealed class ChatClient : IChatClient
{
    private readonly HttpClient _httpClient;

    public ChatClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<FrontendApiResult<ConversationDto>> GetConversationAsync(int customerId, CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.GetAsync($"api/chat/{customerId}", ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<ConversationDto>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            
            var data = await response.Content.ReadFromJsonAsync<ConversationDto>(ct);
            return data is null
                ? FrontendApiResult<ConversationDto>.Failure("API returned an empty response.")
                : FrontendApiResult<ConversationDto>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<ConversationDto>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<ChatMessageDto>> SendMessageAsync(int customerId, string message, CancellationToken ct = default)
    {
        try
        {
            var request = new SendMessageRequest(message);
            var response = await _httpClient.PostAsJsonAsync($"api/chat/{customerId}/send", request, ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<ChatMessageDto>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            
            var data = await response.Content.ReadFromJsonAsync<ChatMessageDto>(ct);
            return data is null
                ? FrontendApiResult<ChatMessageDto>.Failure("API returned an empty response.")
                : FrontendApiResult<ChatMessageDto>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<ChatMessageDto>.Failure(ex.Message);
        }
    }

    public async Task<FrontendApiResult<ChatMessageDto>> SendStaffReplyAsync(int customerId, int staffId, string message, CancellationToken ct = default)
    {
        try
        {
            var request = new SendMessageRequest(message);
            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, $"api/chat/{customerId}/reply");
            httpRequest.Content = JsonContent.Create(request);
            httpRequest.Headers.Add("X-Staff-Id", staffId.ToString());
            
            var response = await _httpClient.SendAsync(httpRequest, ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<ChatMessageDto>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            
            var data = await response.Content.ReadFromJsonAsync<ChatMessageDto>(ct);
            return data is null
                ? FrontendApiResult<ChatMessageDto>.Failure("API returned an empty response.")
                : FrontendApiResult<ChatMessageDto>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<ChatMessageDto>.Failure(ex.Message);
        }
    }

    public async Task MarkAsReadAsync(int customerId, CancellationToken ct = default)
    {
        await _httpClient.PostAsync($"api/chat/{customerId}/read", null, ct);
    }

    public async Task<FrontendApiResult<IReadOnlyList<ConversationSummaryDto>>> GetConversationsAsync(CancellationToken ct = default)
    {
        try
        {
            var response = await _httpClient.GetAsync("api/chat/conversations", ct);
            if (!response.IsSuccessStatusCode)
                return FrontendApiResult<IReadOnlyList<ConversationSummaryDto>>.Failure(await ReadErrorAsync(response, ct), (int)response.StatusCode);
            
            var data = await response.Content.ReadFromJsonAsync<List<ConversationSummaryDto>>(ct);
            return data is null
                ? FrontendApiResult<IReadOnlyList<ConversationSummaryDto>>.Failure("API returned an empty response.")
                : FrontendApiResult<IReadOnlyList<ConversationSummaryDto>>.Success(data);
        }
        catch (OperationCanceledException) { throw; }
        catch (Exception ex)
        {
            return FrontendApiResult<IReadOnlyList<ConversationSummaryDto>>.Failure(ex.Message);
        }
    }

    private static async Task<string> ReadErrorAsync(HttpResponseMessage response, CancellationToken ct)
    {
        var body = await response.Content.ReadAsStringAsync(ct);
        return string.IsNullOrWhiteSpace(body) ? $"API returned {(int)response.StatusCode}." : body;
    }
}
