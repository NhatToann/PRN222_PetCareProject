using Microsoft.AspNetCore.Mvc;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/pet-services")]
    public sealed class PetServicesController : ControllerBase
    {
        private readonly IPetServiceService _service;

        public PetServicesController(IPetServiceService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<IReadOnlyList<PetServiceDto>>> GetAll(CancellationToken ct)
        {
            var items = await _service.GetAllAsync(ct);
            return Ok(items);
        }

        [HttpGet("grouped")]
        public async Task<ActionResult<PetServiceGroupedDto>> GetGrouped(CancellationToken ct)
        {
            var items = await _service.GetAllAsync(ct);

            var spaServices = items
                .Where(s => string.Equals(s.ServiceType, "spa", StringComparison.OrdinalIgnoreCase))
                .ToList();

            var healthCheckServices = items
                .Where(s => string.Equals(s.ServiceType, "health_check", StringComparison.OrdinalIgnoreCase))
                .ToList();

            var response = new PetServiceGroupedDto(
                SpaServices: spaServices,
                HealthCheckServices: healthCheckServices,
                SeparatorText: "bạn muốn kiểm tra sức khoẻ cho thú cưng của bạn?"
            );

            return Ok(response);
        }

        [HttpGet("{serviceId:int}")]
        public async Task<ActionResult<PetServiceDetailDto>> GetDetail(int serviceId, CancellationToken ct)
        {
            var detail = await _service.GetDetailAsync(serviceId, ct);
            if (detail == null)
            {
                return NotFound();
            }

            return Ok(detail);
        }
    }
}
