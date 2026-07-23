using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PetShop.Models;
using PetShop.Services;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AllowAnonymous]
    public class ChatController : ControllerBase
    {
        private readonly IChatService _chatService;

        public ChatController(IChatService chatService)
        {
            _chatService = chatService;
        }

        [HttpGet("conversations")]
        public async Task<ActionResult<IReadOnlyList<ConversationSummaryDto>>> GetAllConversations(
            CancellationToken ct = default)
        {
            var conversations = await _chatService.GetAllConversationsAsync(ct);
            return Ok(conversations);
        }

        [HttpGet("{customerId:int}")]
        public async Task<ActionResult<ConversationDto>> GetConversation(
            int customerId,
            CancellationToken ct = default)
        {
            if (customerId <= 0)
            {
                return BadRequest(new { message = "Invalid customer ID." });
            }

            var conversation = await _chatService.GetConversationAsync(customerId, ct);
            // Return empty conversation if no messages exist yet
            if (conversation == null)
            {
                return Ok(new ConversationDto(
                    customerId,
                    "Khách hàng",
                    null,
                    null,
                    null,
                    0,
                    new List<ChatMessageDto>()
                ));
            }

            return Ok(conversation);
        }

        [HttpPost("{customerId:int}/send")]
        public async Task<ActionResult<ChatMessageDto>> SendMessage(
            int customerId,
            [FromBody] SendMessageRequest request,
            CancellationToken ct = default)
        {
            if (customerId <= 0)
            {
                return BadRequest(new { message = "Invalid customer ID." });
            }

            if (string.IsNullOrWhiteSpace(request?.Message))
            {
                return BadRequest(new { message = "Message cannot be empty." });
            }

            var message = await _chatService.SendMessageAsync(customerId, request.Message, ct);
            return Ok(message);
        }

        [HttpPost("{customerId:int}/reply")]
        public async Task<ActionResult<ChatMessageDto>> SendStaffReply(
            int customerId,
            [FromBody] SendMessageRequest request,
            CancellationToken ct = default)
        {
            if (customerId <= 0)
            {
                return BadRequest(new { message = "Invalid customer ID." });
            }

            if (string.IsNullOrWhiteSpace(request?.Message))
            {
                return BadRequest(new { message = "Message cannot be empty." });
            }

            var staffIdHeader = Request.Headers["X-Staff-Id"].FirstOrDefault();
            if (!int.TryParse(staffIdHeader, out var staffId))
            {
                return Unauthorized(new { message = "Staff ID is required." });
            }

            var message = await _chatService.SendStaffReplyAsync(customerId, staffId, request.Message, ct);
            return Ok(message);
        }

        [HttpPost("{customerId:int}/read")]
        public async Task<ActionResult> MarkAsRead(
            int customerId,
            CancellationToken ct = default)
        {
            if (customerId <= 0)
            {
                return BadRequest(new { message = "Invalid customer ID." });
            }

            await _chatService.MarkAsReadAsync(customerId, ct);
            return Ok(new { message = "Messages marked as read." });
        }

        [HttpGet("{customerId:int}/unread-count")]
        public async Task<ActionResult<ChatStatusDto>> GetUnreadCount(
            int customerId,
            CancellationToken ct = default)
        {
            if (customerId <= 0)
            {
                return BadRequest(new { message = "Invalid customer ID." });
            }

            var count = await _chatService.GetUnreadCountAsync(customerId, ct);
            return Ok(new ChatStatusDto(customerId, count, null));
        }
    }
}
