using System.Net;
using System.Net.Sockets;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;
using PetShop.Services;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/shift-exchange")]
    public sealed class ShiftExchangeController : ControllerBase
    {
        private readonly ShopPetDatabaseContext _db;
        private readonly string[] _allowedIpPrefixes;

        private readonly IAttendanceService _attendanceService;

        public ShiftExchangeController(
            ShopPetDatabaseContext db,
            IConfiguration configuration,
            IAttendanceService attendanceService)
        {
            _db = db;
            _allowedIpPrefixes = configuration.GetSection("Attendance:AllowedIpPrefixes")
                .Get<string[]>() ?? new[] { "192.168.1." };
            _attendanceService = attendanceService;
        }

        [HttpGet("verify-network")]
        public ActionResult<VerifyNetworkDto> VerifyNetwork()
        {
            var xClientIp = Request.Headers["X-Client-IP"].FirstOrDefault();
            var realClientIp = HttpContext.Items["RealClientIp"] as string;
            var xForwardedFor = Request.Headers["X-Forwarded-For"].FirstOrDefault();
            var xRealIp = Request.Headers["X-Real-IP"].FirstOrDefault();
            var remoteIp = HttpContext.Connection.RemoteIpAddress?.ToString();

            var socketRemoteIp = HttpContext.Connection.RemoteIpAddress?.ToString();
            var isLoopback = !string.IsNullOrEmpty(socketRemoteIp) &&
                (socketRemoteIp == "::1" || socketRemoteIp == "127.0.0.1");

            Console.WriteLine($"[VerifyNetwork] Headers -> X-Client-IP: [{xClientIp}], X-Real-IP: [{xRealIp}], X-Forwarded-For: [{xForwardedFor}], RemoteIp: [{remoteIp}], SocketLoopback: {isLoopback}");

            var raw = xClientIp
                ?? xRealIp
                ?? realClientIp
                ?? (xForwardedFor?.Split(',')[0].Trim())
                ?? remoteIp
                ?? "unknown";

            var ip = NormalizeClientIp(raw);
            var isCompanyNetwork = _allowedIpPrefixes.Any(prefix =>
                ip.StartsWith(prefix, StringComparison.OrdinalIgnoreCase));

            Console.WriteLine($"[VerifyNetwork] Resolved IP: [{ip}], IsCompanyNetwork: {isCompanyNetwork}");

            return Ok(new VerifyNetworkDto(
                ip,
                isCompanyNetwork,
                string.Join(", ", _allowedIpPrefixes),
                xClientIp,
                realClientIp,
                xForwardedFor,
                remoteIp,
                raw,
                xRealIp
            ));
        }

        private static string NormalizeClientIp(string raw)
        {
            if (string.IsNullOrWhiteSpace(raw) || raw.Equals("unknown", StringComparison.OrdinalIgnoreCase))
                return "unknown";

            var s = raw.Split('%')[0].Trim();

            if (!IPAddress.TryParse(s, out var addr))
                return raw;

            if (IPAddress.IsLoopback(addr))
                return "127.0.0.1";

            if (addr.AddressFamily == AddressFamily.InterNetworkV6 && addr.IsIPv4MappedToIPv6)
                return addr.MapToIPv4().ToString();

            return addr.ToString();
        }

        /// <summary>
        /// Cùng nhân viên + ngày + khung giờ: giữ schedule_id nhỏ nhất, xóa các dòng còn lại.
        /// </summary>
        private async Task RemoveDuplicateSlotRowsForStaffAsync(
            int staffId,
            DateOnly workDate,
            TimeOnly startTime,
            TimeOnly endTime,
            CancellationToken ct)
        {
            var rows = await _db.WorkSchedules
                .Where(s =>
                    s.StaffId == staffId &&
                    s.WorkDate == workDate &&
                    s.StartTime == startTime &&
                    s.EndTime == endTime)
                .OrderBy(s => s.ScheduleId)
                .ToListAsync(ct);

            if (rows.Count <= 1)
                return;

            _db.WorkSchedules.RemoveRange(rows.Skip(1));
        }

        [HttpGet("staff/{staffId:int}/my-shifts")]
        public async Task<ActionResult<IReadOnlyList<ShiftOptionDto>>> GetMyShifts([FromRoute] int staffId, CancellationToken ct)
        {
            var nowDate = DateOnly.FromDateTime(DateTime.Now);
            var shifts = await _db.WorkSchedules
                .AsNoTracking()
                .Where(x => x.StaffId == staffId && x.WorkDate >= nowDate)
                .OrderBy(x => x.WorkDate)
                .ThenBy(x => x.StartTime)
                .Take(60)
                .Select(x => new ShiftOptionDto(
                    x.ScheduleId,
                    x.StaffId,
                    x.Staff != null ? x.Staff.Name : null,
                    x.WorkDate,
                    x.ShiftId,
                    x.StartTime.ToTimeSpan(),
                    x.EndTime.ToTimeSpan(),
                    x.Status
                ))
                .ToListAsync(ct);

            return Ok(WorkScheduleDedup.ShiftOptions(shifts));
        }

        [HttpGet("all-shifts")]
        public async Task<ActionResult<IReadOnlyList<ShiftOptionDto>>> GetAllShifts(CancellationToken ct)
        {
            var nowDate = DateOnly.FromDateTime(DateTime.Now);
            var shifts = await _db.WorkSchedules
                .AsNoTracking()
                .Where(x => x.WorkDate >= nowDate)
                .OrderBy(x => x.WorkDate)
                .ThenBy(x => x.StartTime)
                .Take(300)
                .Select(x => new ShiftOptionDto(
                    x.ScheduleId,
                    x.StaffId,
                    x.Staff != null ? x.Staff.Name : null,
                    x.WorkDate,
                    x.ShiftId,
                    x.StartTime.ToTimeSpan(),
                    x.EndTime.ToTimeSpan(),
                    x.Status
                ))
                .ToListAsync(ct);

            return Ok(WorkScheduleDedup.ShiftOptions(shifts));
        }

        [HttpGet("staff/options")]
        public async Task<ActionResult<IReadOnlyList<StaffOptionDto>>> GetStaffOptions([FromQuery] int excludeStaffId, CancellationToken ct)
        {
            var list = await _db.Staff
                .AsNoTracking()
                .Where(x => x.StaffId != excludeStaffId)
                .OrderBy(x => x.Name)
                .Select(x => new StaffOptionDto(x.StaffId, x.Name))
                .ToListAsync(ct);

            return Ok(list);
        }

        [HttpPost("pass")]
        public async Task<ActionResult<ShiftExchangeActionResultDto>> CreatePass([FromBody] CreatePassShiftRequestDto request, CancellationToken ct)
        {
            Console.WriteLine($"[CreatePass] StaffId={request.StaffId}, FromDate={request.FromDate}, FromScheduleId={request.FromScheduleId}, ToStaffId={request.ToStaffId}");

            var today = DateOnly.FromDateTime(DateTime.Now);
            if (request.FromDate < today)
            {
                Console.WriteLine("[CreatePass] FAIL: date in past");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Không thể gửi yêu cầu cho ngày trong quá khứ."));
            }

            if (request.FromDate == today)
            {
                Console.WriteLine("[CreatePass] FAIL: same day as today");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Đã qua 0h sáng ngày hôm nay, không thể gửi yêu cầu đổi ca cùng ngày."));
            }

            if (await _attendanceService.HasAttendanceForDateAsync(request.StaffId, request.FromDate, ct))
            {
                Console.WriteLine("[CreatePass] FAIL: already clocked in");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Bạn đã chấm công ngày này rồi, không thể yêu cầu đổi ca."));
            }

            var mySchedule = await _db.WorkSchedules
                .AsNoTracking()
                .FirstOrDefaultAsync(x =>
                    x.ScheduleId == request.FromScheduleId &&
                    x.StaffId == request.StaffId,
                    ct);

            Console.WriteLine($"[CreatePass] mySchedule=(ScheduleId={mySchedule?.ScheduleId}, StaffId={mySchedule?.StaffId}, WorkDate={mySchedule?.WorkDate})");

            if (mySchedule is null)
            {
                Console.WriteLine("[CreatePass] FAIL: schedule not found or wrong staff");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Không tìm thấy ca của bạn để nhờ làm thay."));
            }

            if (mySchedule.WorkDate != request.FromDate)
            {
                Console.WriteLine($"[CreatePass] FAIL: date mismatch. ScheduleDate={mySchedule.WorkDate}, RequestDate={request.FromDate}");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Ngày ca không khớp với ca đã chọn."));
            }

            // Chỉ chặn trùng theo đúng dòng lịch (ScheduleId), không chặn cả ngày — cùng ngày nhiều ca vẫn gửi nhờ làm thay/đổi tiếp được
            var existingReq = await _db.ShiftRequests
                .AsNoTracking()
                .FirstOrDefaultAsync(r =>
                    r.EmployeeId == request.StaffId &&
                    r.Type == "Leave" &&
                    r.FromShiftId == request.FromScheduleId &&
                    r.Status == "Pending",
                    ct);

            if (existingReq is not null)
            {
                return BadRequest(new ShiftExchangeActionResultDto("error", "Ca (dòng lịch) này đã có yêu cầu nhờ làm thay đang chờ duyệt. Huỷ yêu cầu cũ nếu muốn gửi lại."));
            }

            // ⚠️ Kiểm tra người được nhờ đã có ca cùng khung giờ chưa
            var toStaffHasSlot = await _db.WorkSchedules
                .AsNoTracking()
                .AnyAsync(s =>
                    s.StaffId == request.ToStaffId &&
                    s.WorkDate == mySchedule.WorkDate &&
                    s.StartTime == mySchedule.StartTime &&
                    s.EndTime == mySchedule.EndTime,
                    ct);
            if (toStaffHasSlot)
            {
                return BadRequest(new ShiftExchangeActionResultDto("error",
                    $"Nhân viên được nhờ đã có ca cùng khung giờ ngày {mySchedule.WorkDate:dd/MM/yyyy} rồi, không thể nhận thêm ca này."));
            }

            var req = new ShiftRequest
            {
                EmployeeId = request.StaffId,
                ToStaffId = request.ToStaffId,
                Type = "Leave",
                TargetDate = request.FromDate,
                FromDate = request.FromDate,
                FromShiftId = mySchedule.ScheduleId,  // ScheduleId (id dòng trong WorkSchedule)
                Reason = request.Reason,
                Status = "Pending",
                CreatedAt = DateTime.Now,
                ToNotified = false,
                AdminNotified = false,
                ApprovedByTo = false,
            };

            _db.ShiftRequests.Add(req);
            await _db.SaveChangesAsync(ct);

            return Ok(new ShiftExchangeActionResultDto("success", "Gửi yêu cầu nhờ làm thay thành công."));
        }

        [HttpPost("swap")]
        public async Task<ActionResult<ShiftExchangeActionResultDto>> CreateSwap([FromBody] CreateSwapShiftRequestDto request, CancellationToken ct)
        {
            Console.WriteLine($"[CreateSwap] StaffId={request.StaffId}, FromDate={request.FromDate}, FromScheduleId={request.FromScheduleId}, ToDate={request.ToDate}, ToScheduleId={request.ToScheduleId}, ToStaffId={request.ToStaffId}");

            var today = DateOnly.FromDateTime(DateTime.Now);
            if (request.FromDate < today || request.ToDate < today)
            {
                Console.WriteLine("[CreateSwap] FAIL: date in past");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Không thể đổi ca cho ngày trong quá khứ."));
            }

            if (request.FromDate == today)
            {
                Console.WriteLine("[CreateSwap] FAIL: same day as today (fromDate)");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Đã qua 0h sáng ngày hôm nay, không thể gửi yêu cầu đổi ca cùng ngày."));
            }

            if (request.ToDate == today)
            {
                Console.WriteLine("[CreateSwap] FAIL: same day as today (toDate)");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Đã qua 0h sáng ngày hôm nay, không thể đổi ca nhận ngày hôm nay."));
            }

            if (await _attendanceService.HasAttendanceForDateAsync(request.StaffId, request.FromDate, ct))
            {
                Console.WriteLine("[CreateSwap] FAIL: requester already clocked in");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Bạn đã chấm công ngày này rồi, không thể yêu cầu đổi ca."));
            }

            if (await _attendanceService.HasAttendanceForDateAsync(request.ToStaffId, request.ToDate, ct))
            {
                Console.WriteLine("[CreateSwap] FAIL: toStaff already clocked in");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Nhân viên được đổi đã chấm công ngày kia rồi, không thể đổi."));
            }

            var fromSchedule = await _db.WorkSchedules
                .AsNoTracking()
                .FirstOrDefaultAsync(x =>
                    x.ScheduleId == request.FromScheduleId &&
                    x.StaffId == request.StaffId,
                    ct);

            Console.WriteLine($"[CreateSwap] fromSchedule=(ScheduleId={fromSchedule?.ScheduleId}, StaffId={fromSchedule?.StaffId}, WorkDate={fromSchedule?.WorkDate})");

            if (fromSchedule is null)
            {
                Console.WriteLine("[CreateSwap] FAIL: fromSchedule not found or wrong staff");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Không tìm thấy ca của bạn để đổi."));
            }

            if (fromSchedule.WorkDate != request.FromDate)
            {
                Console.WriteLine($"[CreateSwap] FAIL: fromSchedule date mismatch. DB={fromSchedule.WorkDate}, Request={request.FromDate}");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Ngày ca của bạn không khớp."));
            }

            var toSchedule = await _db.WorkSchedules
                .AsNoTracking()
                .FirstOrDefaultAsync(x =>
                    x.ScheduleId == request.ToScheduleId &&
                    x.StaffId == request.ToStaffId,
                    ct);

            Console.WriteLine($"[CreateSwap] toSchedule=(ScheduleId={toSchedule?.ScheduleId}, StaffId={toSchedule?.StaffId}, WorkDate={toSchedule?.WorkDate})");

            if (toSchedule is null)
            {
                Console.WriteLine("[CreateSwap] FAIL: toSchedule not found or wrong staff");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Không tìm thấy ca của nhân viên được chọn để đổi."));
            }

            if (toSchedule.WorkDate != request.ToDate)
            {
                Console.WriteLine($"[CreateSwap] FAIL: toSchedule date mismatch. DB={toSchedule.WorkDate}, Request={request.ToDate}");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Ngày ca muốn đổi không khớp."));
            }

            // Một dòng lịch (ca cụ thể) chỉ một yêu cầu đổi đang Pending; khác ScheduleId cùng ngày vẫn đổi tiếp được
            var existingReq = await _db.ShiftRequests
                .AsNoTracking()
                .FirstOrDefaultAsync(r =>
                    r.EmployeeId == request.StaffId &&
                    r.Type == "Swap" &&
                    r.FromShiftId == request.FromScheduleId &&
                    r.Status == "Pending",
                    ct);

            if (existingReq is not null)
            {
                Console.WriteLine($"[CreateSwap] FAIL: duplicate pending request #{existingReq.RequestId} for FromScheduleId={request.FromScheduleId}");
                return BadRequest(new ShiftExchangeActionResultDto("error", "Ca (dòng lịch) này đã có yêu cầu đổi đang chờ duyệt. Huỷ hoặc đợi xử lý xong để đổi tiếp."));
            }

            // ⚠️ Kiểm tra người gửi đã có ca cùng khung giờ ngày nhận (toSchedule) chưa
            var requesterHasSlot = await _db.WorkSchedules
                .AsNoTracking()
                .AnyAsync(s =>
                    s.StaffId == request.StaffId &&
                    s.WorkDate == toSchedule.WorkDate &&
                    s.StartTime == toSchedule.StartTime &&
                    s.EndTime == toSchedule.EndTime,
                    ct);
            if (requesterHasSlot)
            {
                return BadRequest(new ShiftExchangeActionResultDto("error",
                    $"Bạn đã có ca cùng khung giờ ngày {toSchedule.WorkDate:dd/MM/yyyy} rồi, không thể nhận thêm ca để đổi."));
            }

            // ⚠️ Kiểm tra nhân viên được đổi đã có ca cùng khung giờ ngày gửi (fromSchedule) chưa
            var toStaffHasSlot = await _db.WorkSchedules
                .AsNoTracking()
                .AnyAsync(s =>
                    s.StaffId == request.ToStaffId &&
                    s.WorkDate == fromSchedule.WorkDate &&
                    s.StartTime == fromSchedule.StartTime &&
                    s.EndTime == fromSchedule.EndTime,
                    ct);
            if (toStaffHasSlot)
            {
                return BadRequest(new ShiftExchangeActionResultDto("error",
                    $"Nhân viên được đổi đã có ca cùng khung giờ ngày {fromSchedule.WorkDate:dd/MM/yyyy} rồi, không thể nhận thêm ca để đổi."));
            }

            Console.WriteLine("[CreateSwap] SUCCESS — creating ShiftRequest");
            var req = new ShiftRequest
            {
                EmployeeId = request.StaffId,
                ToStaffId = request.ToStaffId,
                Type = "Swap",
                TargetDate = request.FromDate,
                FromDate = request.FromDate,
                ToDate = request.ToDate,
                FromShiftId = fromSchedule.ScheduleId,
                ToShiftId = toSchedule.ScheduleId,
                Reason = request.Reason,
                Status = "Pending",
                CreatedAt = DateTime.Now,
                ToNotified = false,
                AdminNotified = false,
                ApprovedByTo = false,
            };

            _db.ShiftRequests.Add(req);
            await _db.SaveChangesAsync(ct);

            return Ok(new ShiftExchangeActionResultDto("success", "Gửi yêu cầu đổi ca thành công."));
        }

        [HttpGet("pending")]
        public async Task<ActionResult<IReadOnlyList<PendingRequestDto>>> GetPendingRequests([FromQuery] int staffId, CancellationToken ct)
        {
            var requests = await _db.ShiftRequests
                .AsNoTracking()
                .Where(r => r.ToStaffId == staffId && r.Status == "Pending")
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new PendingRequestDto(
                    r.RequestId,
                    r.EmployeeId,
                    r.Employee != null ? r.Employee.Name : null,
                    r.ToStaffId,
                    r.Type ?? "",
                    r.FromDate ?? DateOnly.MinValue,
                    r.ToDate,
                    r.FromShiftId,
                    r.ToShiftId,
                    r.Reason ?? "",
                    r.Status ?? "",
                    r.CreatedAt ?? DateTime.MinValue
                ))
                .ToListAsync(ct);

            return Ok(requests);
        }

        [HttpGet("my-requests")]
        public async Task<ActionResult<IReadOnlyList<MyRequestDto>>> GetMyRequests([FromQuery] int staffId, CancellationToken ct)
        {
            var requests = await _db.ShiftRequests
                .AsNoTracking()
                .Where(r => r.EmployeeId == staffId)
                .OrderByDescending(r => r.CreatedAt)
                .Take(50)
                .Select(r => new MyRequestDto(
                    r.RequestId,
                    r.ToStaffId,
                    r.ToStaffId != null ? _db.Staff.Where(s => s.StaffId == r.ToStaffId).Select(s => s.Name).FirstOrDefault() : null,
                    r.Type ?? "",
                    r.FromDate ?? DateOnly.MinValue,
                    r.ToDate,
                    r.Status ?? "",
                    r.Reason ?? "",
                    r.CreatedAt ?? DateTime.MinValue,
                    r.ApprovedByTo == true
                ))
                .ToListAsync(ct);

            return Ok(requests);
        }

        [HttpPost("accept/{requestId:int}")]
        public async Task<ActionResult<ShiftExchangeActionResultDto>> AcceptRequest([FromRoute] int requestId, [FromQuery] int responderStaffId, CancellationToken ct)
        {
            Console.WriteLine($"[AcceptRequest] requestId={requestId}, responderStaffId={responderStaffId}");

            var req = await _db.ShiftRequests
                .FirstOrDefaultAsync(r => r.RequestId == requestId && r.ToStaffId == responderStaffId && r.Status == "Pending", ct);

            if (req is null)
            {
                return BadRequest(new ShiftExchangeActionResultDto("error", "Yêu cầu không tồn tại hoặc không thuộc về bạn."));
            }

            Console.WriteLine($"[AcceptRequest] Found: Type={req.Type}, FromShiftId={req.FromShiftId}, ToShiftId={req.ToShiftId}, EmployeeId={req.EmployeeId}, FromDate={req.FromDate}, ToDate={req.ToDate}");

            var targetDate = req.Type == "Swap" ? req.ToDate : req.FromDate;

            if (targetDate.HasValue && await _attendanceService.HasAttendanceForDateAsync(responderStaffId, targetDate.Value, ct))
            {
                req.Status = "Rejected";
                req.ApprovedByTo = false;
                await _db.SaveChangesAsync(ct);

                return BadRequest(new ShiftExchangeActionResultDto("error", "Bạn đã chấm công ngày đó rồi, không thể nhận đổi."));
            }

            if (req.Type == "Swap")
            {
                // myShift = ca MUON CHO của responder (req.ToShiftId), bên responder sở hữu
                // partnerShift = ca MUON NHẬN của requester (req.FromShiftId), bên requester sở hữu
                var myShift = await _db.WorkSchedules
                    .FirstOrDefaultAsync(s => s.ScheduleId == req.ToShiftId && s.StaffId == responderStaffId, ct);
                var partnerShift = await _db.WorkSchedules
                    .FirstOrDefaultAsync(s => s.ScheduleId == req.FromShiftId && s.StaffId == req.EmployeeId, ct);

                Console.WriteLine($"[AcceptRequest] myShift=(ScheduleId={myShift?.ScheduleId}, StaffId={myShift?.StaffId}), partnerShift=(ScheduleId={partnerShift?.ScheduleId}, StaffId={partnerShift?.StaffId})");

                if (myShift is null || partnerShift is null)
                {
                    Console.WriteLine($"[AcceptRequest] FAIL: {(myShift is null ? "myShift" : "partnerShift")} is null. ToShiftId={req.ToShiftId} responderStaffId={responderStaffId}, FromShiftId={req.FromShiftId} EmployeeId={req.EmployeeId}");
                    return BadRequest(new ShiftExchangeActionResultDto("error", "Ca của một trong hai bên không còn tồn tại."));
                }

                if (await _attendanceService.HasAttendanceForDateAsync(req.EmployeeId!.Value, partnerShift.WorkDate, ct))
                {
                    return BadRequest(new ShiftExchangeActionResultDto("error", "Người gửi yêu cầu đã chấm công ca kia rồi."));
                }

                // ⚠️ Kiểm tra requester đã có ca trùng khung giờ ngày nhận (partnerShift) chưa
                var requesterHasSlot = await _db.WorkSchedules
                    .AnyAsync(s =>
                        s.StaffId == req.EmployeeId &&
                        s.WorkDate == partnerShift.WorkDate &&
                        s.StartTime == partnerShift.StartTime &&
                        s.EndTime == partnerShift.EndTime,
                        ct);
                if (requesterHasSlot)
                {
                    return BadRequest(new ShiftExchangeActionResultDto("error",
                        $"Người gửi yêu cầu đã có ca cùng khung giờ ngày {partnerShift.WorkDate:dd/MM/yyyy} rồi, không thể nhận thêm ca nữa."));
                }

                // ⚠️ Kiểm tra responder đã có ca trùng khung giờ ngày nhận (myShift) chưa
                var responderHasSlot = await _db.WorkSchedules
                    .AnyAsync(s =>
                        s.StaffId == responderStaffId &&
                        s.WorkDate == myShift.WorkDate &&
                        s.StartTime == myShift.StartTime &&
                        s.EndTime == myShift.EndTime,
                        ct);
                if (responderHasSlot)
                {
                    return BadRequest(new ShiftExchangeActionResultDto("error",
                        $"Bạn đã có ca cùng khung giờ ngày {myShift.WorkDate:dd/MM/yyyy} rồi, không thể nhận thêm ca nữa."));
                }

                // Swap: responder nhận ca requester (myShift), requester nhận ca responder (partnerShift)
                (myShift.StaffId, partnerShift.StaffId) = (partnerShift.StaffId, myShift.StaffId);

                // Sau khi swap, dọn trùng khung giờ cho cả hai (nếu sau swap có dòng trùng)
                await RemoveDuplicateSlotRowsForStaffAsync(
                    req.EmployeeId!.Value,
                    myShift.WorkDate,
                    myShift.StartTime,
                    myShift.EndTime,
                    ct);
                await RemoveDuplicateSlotRowsForStaffAsync(
                    responderStaffId,
                    partnerShift.WorkDate,
                    partnerShift.StartTime,
                    partnerShift.EndTime,
                    ct);
            }
            else
            {
                // Leave: ca MUON NHỜ của requester = req.FromShiftId, sở hữu bởi requester
                var myShift = await _db.WorkSchedules
                    .FirstOrDefaultAsync(s => s.ScheduleId == req.FromShiftId && s.StaffId == req.EmployeeId, ct);

                if (myShift is null)
                {
                    return BadRequest(new ShiftExchangeActionResultDto("error", "Ca cần nhờ làm thay không còn tồn tại."));
                }

                // ⚠️ Kiểm tra requester đã nhận ca cùng khung giờ chưa
                var requesterHasSlot = await _db.WorkSchedules
                    .AnyAsync(s =>
                        s.StaffId == req.EmployeeId &&
                        s.WorkDate == myShift.WorkDate &&
                        s.StartTime == myShift.StartTime &&
                        s.EndTime == myShift.EndTime,
                        ct);
                if (requesterHasSlot)
                {
                    return BadRequest(new ShiftExchangeActionResultDto("error",
                        $"Người gửi yêu cầu đã có ca cùng khung giờ ngày {myShift.WorkDate:dd/MM/yyyy} rồi, không thể nhận thêm ca."));
                }

                // ⚠️ Kiểm tra responder đã có ca cùng khung giờ chưa
                var responderHasSlot = await _db.WorkSchedules
                    .AnyAsync(s =>
                        s.StaffId == responderStaffId &&
                        s.WorkDate == myShift.WorkDate &&
                        s.StartTime == myShift.StartTime &&
                        s.EndTime == myShift.EndTime,
                        ct);
                if (responderHasSlot)
                {
                    return BadRequest(new ShiftExchangeActionResultDto("error",
                        $"Nhân viên được nhờ đã có ca cùng khung giờ ngày {myShift.WorkDate:dd/MM/yyyy} rồi, không thể nhận thêm ca."));
                }

                myShift.StaffId = responderStaffId;

                await RemoveDuplicateSlotRowsForStaffAsync(
                    responderStaffId,
                    myShift.WorkDate,
                    myShift.StartTime,
                    myShift.EndTime,
                    ct);
            }

            req.Status = "Approved";
            req.ApprovedByTo = true;

            await _db.SaveChangesAsync(ct);

            return Ok(new ShiftExchangeActionResultDto("success", "Đã chấp nhận yêu cầu đổi ca."));
        }

        [HttpPost("decline/{requestId:int}")]
        public async Task<ActionResult<ShiftExchangeActionResultDto>> DeclineRequest([FromRoute] int requestId, [FromQuery] int responderStaffId, CancellationToken ct)
        {
            var req = await _db.ShiftRequests
                .FirstOrDefaultAsync(r => r.RequestId == requestId && r.ToStaffId == responderStaffId && r.Status == "Pending", ct);

            if (req is null)
            {
                return BadRequest(new ShiftExchangeActionResultDto("error", "Yêu cầu không tồn tại hoặc không thuộc về bạn."));
            }

            req.Status = "Rejected";
            req.ApprovedByTo = false;

            await _db.SaveChangesAsync(ct);

            return Ok(new ShiftExchangeActionResultDto("success", "Đã từ chối yêu cầu."));
        }

        [HttpPost("cancel/{requestId:int}")]
        public async Task<ActionResult<ShiftExchangeActionResultDto>> CancelRequest([FromRoute] int requestId, [FromQuery] int staffId, CancellationToken ct)
        {
            var req = await _db.ShiftRequests
                .FirstOrDefaultAsync(r => r.RequestId == requestId && r.EmployeeId == staffId && r.Status == "Pending", ct);

            if (req is null)
            {
                return BadRequest(new ShiftExchangeActionResultDto("error", "Yêu cầu không tồn tại hoặc không thể huỷ."));
            }

            req.Status = "Cancelled";

            await _db.SaveChangesAsync(ct);

            return Ok(new ShiftExchangeActionResultDto("success", "Đã huỷ yêu cầu."));
        }
    }
}
