using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace PetShop.Repositories
{
    public interface IChatRepository
    {
        Task<ChatMessage> SaveMessageAsync(ChatMessage message, CancellationToken ct = default);
        Task<IReadOnlyList<ChatMessage>> GetConversationAsync(int customerId, CancellationToken ct = default);
        Task<int> GetUnreadCountAsync(int customerId, CancellationToken ct = default);
        Task MarkAsReadAsync(int customerId, CancellationToken ct = default);
        Task<IReadOnlyList<ConversationSummaryDto>> GetAllConversationsAsync(CancellationToken ct = default);
        Task<ConversationDto?> GetFullConversationAsync(int customerId, CancellationToken ct = default);
        Task<ChatMessage?> GetLastMessageAsync(int customerId, CancellationToken ct = default);
    }

    public class ChatRepository : IChatRepository
    {
        private readonly ShopPetDatabaseContext _db;

        public ChatRepository(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        public async Task<ChatMessage> SaveMessageAsync(ChatMessage message, CancellationToken ct = default)
        {
            if (message.SentAt == default)
            {
                message.SentAt = DateTime.UtcNow;
            }
            
            _db.ChatMessages.Add(message);
            await _db.SaveChangesAsync(ct);
            return message;
        }

        public async Task<IReadOnlyList<ChatMessage>> GetConversationAsync(int customerId, CancellationToken ct = default)
        {
            return await _db.ChatMessages
                .Include(m => m.Customer)
                .Include(m => m.Staff)
                .Where(m => m.CustomerId == customerId)
                .OrderBy(m => m.SentAt)
                .ToListAsync(ct);
        }

        public async Task<int> GetUnreadCountAsync(int customerId, CancellationToken ct = default)
        {
            return await _db.ChatMessages
                .CountAsync(m => m.CustomerId == customerId 
                    && m.SenderType == "Staff" 
                    && m.IsRead != true, ct);
        }

        public async Task MarkAsReadAsync(int customerId, CancellationToken ct = default)
        {
            var unreadMessages = await _db.ChatMessages
                .Where(m => m.CustomerId == customerId 
                    && m.SenderType == "Staff" 
                    && m.IsRead != true)
                .ToListAsync(ct);

            foreach (var message in unreadMessages)
            {
                message.IsRead = true;
            }

            await _db.SaveChangesAsync(ct);
        }

        public async Task<IReadOnlyList<ConversationSummaryDto>> GetAllConversationsAsync(CancellationToken ct = default)
        {
            var conversations = await _db.ChatMessages
                .Include(m => m.Customer)
                .GroupBy(m => m.CustomerId)
                .Select(g => new
                {
                    CustomerId = g.Key,
                    Customer = g.OrderByDescending(m => m.SentAt).First().Customer,
                    LastMessage = g.OrderByDescending(m => m.SentAt).First().Message,
                    LastMessageAt = g.Max(m => m.SentAt)
                })
                .ToListAsync(ct);

            var result = new List<ConversationSummaryDto>();
            foreach (var conv in conversations)
            {
                var unreadCount = await _db.ChatMessages
                    .CountAsync(m => m.CustomerId == conv.CustomerId 
                        && m.SenderType == "Staff" 
                        && m.IsRead != true, ct);

                result.Add(new ConversationSummaryDto(
                    conv.CustomerId,
                    conv.Customer?.Name,
                    conv.Customer?.Email,
                    conv.LastMessageAt,
                    conv.LastMessage ?? string.Empty,
                    unreadCount
                ));
            }

            return result
                .OrderByDescending(c => c.LastMessageAt)
                .ToList();
        }

        public async Task<ConversationDto?> GetFullConversationAsync(int customerId, CancellationToken ct = default)
        {
            var customer = await _db.Customers
                .FirstOrDefaultAsync(c => c.CustomerId == customerId, ct);

            var messages = await GetConversationAsync(customerId, ct);
            var unreadCount = await GetUnreadCountAsync(customerId, ct);

            var messageDtos = messages.Select(m => new ChatMessageDto(
                m.MessageId,
                m.CustomerId,
                m.Customer?.Name ?? (m.SenderType == "Customer" ? "Khách hàng" : null),
                m.StaffId,
                m.Staff?.Name,
                m.SenderType,
                m.Message,
                m.SentAt ?? DateTime.UtcNow,
                m.IsRead ?? false
            )).ToList();

            return new ConversationDto(
                customerId,
                customer?.Name ?? "Khách hàng",
                customer?.Email,
                messages.LastOrDefault()?.SentAt,
                messages.LastOrDefault()?.Message,
                unreadCount,
                messageDtos
            );
        }

        public async Task<ChatMessage?> GetLastMessageAsync(int customerId, CancellationToken ct = default)
        {
            return await _db.ChatMessages
                .Where(m => m.CustomerId == customerId)
                .OrderByDescending(m => m.SentAt)
                .FirstOrDefaultAsync(ct);
        }
    }
}
