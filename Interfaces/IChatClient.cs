using PetShop.Models;

namespace PetShop.Interfaces;

public interface IChatClient
{
    Task<FrontendApiResult<ConversationDto>> GetConversationAsync(int customerId, CancellationToken ct = default);
    Task<FrontendApiResult<ChatMessageDto>> SendMessageAsync(int customerId, string message, CancellationToken ct = default);
    Task<FrontendApiResult<ChatMessageDto>> SendStaffReplyAsync(int customerId, int staffId, string message, CancellationToken ct = default);
    Task<FrontendApiResult<IReadOnlyList<ConversationSummaryDto>>> GetConversationsAsync(CancellationToken ct = default);
    Task MarkAsReadAsync(int customerId, CancellationToken ct = default);
}
