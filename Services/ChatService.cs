using PetShop.Models;
using PetShop.Repositories;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace PetShop.Services
{
    public interface IChatService
    {
        Task<ChatMessageDto> SendMessageAsync(int customerId, string message, CancellationToken ct = default);
        Task<ChatMessageDto> SendStaffReplyAsync(int customerId, int staffId, string message, CancellationToken ct = default);
        Task<ConversationDto?> GetConversationAsync(int customerId, CancellationToken ct = default);
        Task<IReadOnlyList<ConversationSummaryDto>> GetAllConversationsAsync(CancellationToken ct = default);
        Task MarkAsReadAsync(int customerId, CancellationToken ct = default);
        Task<int> GetUnreadCountAsync(int customerId, CancellationToken ct = default);
    }

    public class ChatService : IChatService
    {
        private readonly IChatRepository _chatRepository;

        public ChatService(IChatRepository chatRepository)
        {
            _chatRepository = chatRepository;
        }

        public async Task<ChatMessageDto> SendMessageAsync(int customerId, string message, CancellationToken ct = default)
        {
            var chatMessage = new ChatMessage
            {
                CustomerId = customerId,
                SenderType = "Customer",
                Message = message.Trim(),
                SentAt = DateTime.UtcNow,
                IsRead = false
            };

            var savedMessage = await _chatRepository.SaveMessageAsync(chatMessage, ct);

            return new ChatMessageDto(
                savedMessage.MessageId,
                savedMessage.CustomerId,
                null,
                savedMessage.StaffId,
                null,
                savedMessage.SenderType,
                savedMessage.Message,
                savedMessage.SentAt ?? DateTime.UtcNow,
                savedMessage.IsRead ?? false
            );
        }

        public async Task<ChatMessageDto> SendStaffReplyAsync(int customerId, int staffId, string message, CancellationToken ct = default)
        {
            var chatMessage = new ChatMessage
            {
                CustomerId = customerId,
                StaffId = staffId,
                SenderType = "Staff",
                Message = message.Trim(),
                SentAt = DateTime.UtcNow,
                IsRead = false
            };

            var savedMessage = await _chatRepository.SaveMessageAsync(chatMessage, ct);

            return new ChatMessageDto(
                savedMessage.MessageId,
                savedMessage.CustomerId,
                null,
                savedMessage.StaffId,
                null,
                savedMessage.SenderType,
                savedMessage.Message,
                savedMessage.SentAt ?? DateTime.UtcNow,
                savedMessage.IsRead ?? false
            );
        }

        public async Task<ConversationDto?> GetConversationAsync(int customerId, CancellationToken ct = default)
        {
            var conversation = await _chatRepository.GetFullConversationAsync(customerId, ct);
            return conversation;
        }

        public async Task<IReadOnlyList<ConversationSummaryDto>> GetAllConversationsAsync(CancellationToken ct = default)
        {
            return await _chatRepository.GetAllConversationsAsync(ct);
        }

        public async Task MarkAsReadAsync(int customerId, CancellationToken ct = default)
        {
            await _chatRepository.MarkAsReadAsync(customerId, ct);
        }

        public async Task<int> GetUnreadCountAsync(int customerId, CancellationToken ct = default)
        {
            return await _chatRepository.GetUnreadCountAsync(customerId, ct);
        }
    }
}
