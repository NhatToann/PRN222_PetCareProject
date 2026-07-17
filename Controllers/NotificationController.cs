using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Models;

namespace PetShop.Controllers
{
    /// <summary>
    /// API tương thích frontend — dữ liệu lấy từ bảng ShiftRequest (không dùng bảng Notifications).
    /// </summary>
    [ApiController]
    [Route("api/notifications")]
    public sealed class NotificationController : ControllerBase
    {
        private readonly ShopPetDatabaseContext _db;

        public NotificationController(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        [HttpGet("{staffId:int}")]
        public async Task<ActionResult<IReadOnlyList<NotificationDto>>> GetNotifications(
            [FromRoute] int staffId,
            [FromQuery] bool? unreadOnly,
            CancellationToken ct)
        {
            IQueryable<ShiftRequest> q = _db.ShiftRequests
                .AsNoTracking()
                .Where(r => r.ToStaffId == staffId && r.Status == "Pending");

            if (unreadOnly == true)
            {
                q = q.Where(r => r.ToNotified == false || r.ToNotified == null);
            }

            var result = await q
                .OrderByDescending(r => r.CreatedAt)
                .Take(50)
                .Select(r => new NotificationDto(
                    r.RequestId,
                    staffId,
                    r.Type == "Swap" ? "Yêu cầu đổi ca" : "Yêu cầu làm thay",
                    r.Type == "Swap"
                        ? $"Yêu cầu đổi ca (Request #{r.RequestId})"
                        : $"Yêu cầu nhờ làm thay (Request #{r.RequestId})",
                    r.ToNotified == true,
                    r.CreatedAt ?? DateTime.MinValue,
                    r.RequestId,
                    false
                ))
                .ToListAsync(ct);

            return Ok(result);
        }

        [HttpGet("{staffId:int}/unread-count")]
        public async Task<ActionResult<UnreadCountDto>> GetUnreadCount([FromRoute] int staffId, CancellationToken ct)
        {
            var count = await _db.ShiftRequests
                .AsNoTracking()
                .CountAsync(
                    r => r.ToStaffId == staffId &&
                         r.Status == "Pending" &&
                         (r.ToNotified == false || r.ToNotified == null),
                    ct);

            return Ok(new UnreadCountDto(count));
        }

        [HttpPut("{requestId:int}/read")]
        public async Task<ActionResult> MarkAsRead(
            [FromRoute] int requestId,
            [FromQuery] int staffId,
            CancellationToken ct)
        {
            var updated = await _db.ShiftRequests
                .Where(r =>
                    r.RequestId == requestId &&
                    r.ToStaffId == staffId &&
                    r.Status == "Pending")
                .ExecuteUpdateAsync(
                    setters => setters.SetProperty(r => r.ToNotified, true),
                    ct);

            if (updated == 0)
            {
                return NotFound(new { message = "Không tìm thấy yêu cầu hoặc đã xử lý." });
            }

            return Ok(new { message = "Đã đánh dấu đã đọc." });
        }

        [HttpPut("{staffId:int}/read-all")]
        public async Task<ActionResult> MarkAllAsRead([FromRoute] int staffId, CancellationToken ct)
        {
            var count = await _db.ShiftRequests
                .Where(r =>
                    r.ToStaffId == staffId &&
                    r.Status == "Pending" &&
                    (r.ToNotified == false || r.ToNotified == null))
                .ExecuteUpdateAsync(
                    setters => setters.SetProperty(r => r.ToNotified, true),
                    ct);

            return Ok(new { message = $"Đã đánh dấu {count} thông báo là đã đọc." });
        }

        [HttpDelete("{requestId:int}")]
        public Task<ActionResult> DeleteNotification([FromRoute] int requestId, CancellationToken ct)
        {
            _ = requestId;
            _ = ct;
            return Task.FromResult<ActionResult>(Ok(new { message = "Không hỗ trợ xóa; yêu cầu được quản lý trong đổi ca." }));
        }
    }

    public sealed record NotificationDto(
        int NotificationId,
        int StaffId,
        string Title,
        string Message,
        bool IsRead,
        DateTime CreatedAt,
        int? RelatedRequestId,
        bool IsHandled
    );

    public sealed record UnreadCountDto(int Count);
}
