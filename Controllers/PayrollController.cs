using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/payroll")]
    public sealed class PayrollController : ControllerBase
    {
        private readonly IPayrollService _payrollService;
        private readonly ShopPetDatabaseContext _db;

        public PayrollController(IPayrollService payrollService, ShopPetDatabaseContext db)
        {
            _payrollService = payrollService;
            _db = db;
        }

        [HttpGet("history")]
        public async Task<ActionResult<IReadOnlyList<PayrollSummaryDto>>> GetPayrollHistory(
            [FromQuery] int? staffId,
            CancellationToken ct)
        {
            var history = await _payrollService.GetPayrollHistoryAsync(staffId, ct);
            return Ok(history);
        }

        [HttpGet("staff/{staffId:int}/detail")]
        public async Task<ActionResult<StaffPayrollDetailDto>> GetStaffPayrollDetail(
            [FromRoute] int staffId,
            [FromQuery] DateOnly periodStart,
            [FromQuery] DateOnly periodEnd,
            CancellationToken ct)
        {
            var detail = await _payrollService.GetStaffPayrollDetailAsync(staffId, periodStart, periodEnd, ct);
            if (detail is null)
                return NotFound(new { status = "error", message = "Khong tim thay nhan vien." });
            return Ok(detail);
        }

        [HttpGet("staff/{staffId:int}/generate")]
        public async Task<ActionResult<PayrollListResultDto>> GenerateStaffPayroll(
            [FromRoute] int staffId,
            [FromQuery] DateOnly periodStart,
            [FromQuery] DateOnly periodEnd,
            CancellationToken ct)
        {
            if (periodEnd < periodStart)
                return BadRequest(new { status = "error", message = "Ngay ket thuc phai lon hon hoac bang ngay bat dau." });

            var result = await _payrollService.GeneratePayrollForStaffAsync(staffId, periodStart, periodEnd, ct);
            return result.Status == "error" ? BadRequest(result) : Ok(result);
        }

        [HttpPost("generate-all")]
        public async Task<ActionResult<PayrollListResultDto>> GenerateAllPayroll(
            [FromBody] GenerateAllPayrollDto dto,
            CancellationToken ct)
        {
            if (dto.PeriodEnd < dto.PeriodStart)
                return BadRequest(new { status = "error", message = "Ngay ket thuc phai lon hon hoac bang ngay bat dau." });

            var result = await _payrollService.GenerateAllPayrollAsync(dto.PeriodStart, dto.PeriodEnd, ct);
            return result.Status == "error" ? BadRequest(result) : Ok(result);
        }

        [HttpGet("config")]
        public async Task<ActionResult<IReadOnlyList<StaffSalaryConfigDto>>> GetAllSalaryConfigs(CancellationToken ct)
        {
            var configs = await _payrollService.GetAllSalaryConfigsAsync(ct);
            return Ok(configs);
        }

        [HttpGet("config/staff/{staffId:int}")]
        public async Task<ActionResult<PayrollConfigResultDto>> GetSalaryConfig(
            [FromRoute] int staffId, CancellationToken ct)
        {
            var result = await _payrollService.GetSalaryConfigAsync(staffId, ct);
            return result.Status == "error" ? NotFound(result) : Ok(result);
        }

        [HttpPut("config/staff")]
        public async Task<ActionResult<PayrollConfigResultDto>> UpdateSalaryConfig(
            [FromBody] UpdateSalaryConfigDto dto, CancellationToken ct)
        {
            var result = await _payrollService.UpdateSalaryConfigAsync(dto, ct);
            return result.Status == "error" ? BadRequest(result) : Ok(result);
        }

        [HttpGet("staff-list")]
        public async Task<ActionResult<IReadOnlyList<object>>> GetStaffList(CancellationToken ct)
        {
            var list = await _db.Staff
                .AsNoTracking()
                .OrderBy(s => s.Name)
                .Select(s => new { s.StaffId, s.Name, s.Position })
                .ToListAsync(ct);
            return Ok(list);
        }
    }
}
