using Microsoft.AspNetCore.Mvc;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/config")]
    public sealed class ConfigController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public ConfigController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet("google-client-id")]
        public ActionResult<object> GetGoogleClientId()
        {
            var clientId = (_configuration["GoogleAuth:ClientId"] ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(clientId))
            {
                return NotFound(new { message = "Google Client ID chưa được cấu hình." });
            }

            return Ok(new { clientId });
        }
    }
}
