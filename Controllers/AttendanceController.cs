using Microsoft.AspNetCore.Mvc;
using PetShop.Interfaces;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/attendance")]
    public sealed class AttendanceController : ControllerBase
    {
        private readonly IAttendanceService _attendanceService;

        public AttendanceController(IAttendanceService attendanceService)
        {
            _attendanceService = attendanceService;
        }

        /// <summary>Lấy danh sách nhân viên chưa checkout (Admin dashboard).</summary>
        [HttpGet("unclosed")]
        public async Task<ActionResult> GetUnclosed([FromQuery] DateOnly? date, CancellationToken ct)
        {
            var result = await _attendanceService.GetUnclosedAsync(date, ct);
            return Ok(result);
        }

        [HttpGet("staff/{staffId:int}/overview")]
        public async Task<ActionResult> GetOverview([FromRoute] int staffId, CancellationToken ct)
        {
            var overview = await _attendanceService.GetOverviewAsync(staffId, ct);
            return Ok(overview);
        }

        [HttpPost("staff/{staffId:int}/toggle")]
        public async Task<ActionResult> Toggle([FromRoute] int staffId, CancellationToken ct)
        {
            var result = await _attendanceService.ToggleAsync(staffId, ct);
            if (result.Status == "success")
                return Ok(result);
            return BadRequest(result);
        }

    }
}
