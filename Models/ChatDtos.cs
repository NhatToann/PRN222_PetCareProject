namespace PetShop.Models
{
    public sealed record ChatMessageDto(
        int MessageId,
        int CustomerId,
        string? CustomerName,
        int? StaffId,
        string? StaffName,
        string SenderType,
        string Message,
        DateTime SentAt,
        bool IsRead
    );

    public sealed record SendMessageRequest(
        string Message
    );

    public sealed record MarkReadRequest(
        List<int> MessageIds
    );

    public sealed record ConversationDto(
        int CustomerId,
        string? CustomerName,
        string? CustomerEmail,
        DateTime? LastMessageAt,
        string? LastMessage,
        int UnreadCount,
        List<ChatMessageDto> Messages
    );

    public sealed record ConversationSummaryDto(
        int CustomerId,
        string? CustomerName,
        string? CustomerEmail,
        DateTime? LastMessageAt,
        string LastMessage,
        int UnreadCount
    );

    public sealed record ChatStatusDto(
        int CustomerId,
        int UnreadCount,
        DateTime? LastActivity
    );
}
