using Microsoft.AspNetCore.Mvc;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public sealed class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterRequestDto request, CancellationToken ct)
        {
            try
            {
                var result = await _authService.RegisterAsync(request, ct);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("login")]
        public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginRequestDto request, CancellationToken ct)
        {
            try
            {
                var result = await _authService.LoginAsync(request, ct);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpPost("google-login")]
        public async Task<ActionResult<AuthResponseDto>> GoogleLogin([FromBody] GoogleLoginRequestDto request, CancellationToken ct)
        {
            try
            {
                var result = await _authService.LoginWithGoogleAsync(request, ct);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpPost("send-email-otp")]
        public async Task<ActionResult<SimpleMessageDto>> SendEmailOtp([FromBody] SendEmailOtpRequestDto request, CancellationToken ct)
        {
            try
            {
                await _authService.SendEmailOtpAsync(request, ct);
                return Ok(new SimpleMessageDto("Đã gửi OTP đến email."));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new { message = $"Gửi OTP thất bại: {ex.Message}" });
            }
        }

        [HttpPost("verify-email-otp")]
        public async Task<ActionResult<SimpleMessageDto>> VerifyEmailOtp([FromBody] VerifyEmailOtpRequestDto request, CancellationToken ct)
        {
            try
            {
                var result = await _authService.VerifyEmailOtpAsync(request, ct);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("reset-password")]
        public async Task<ActionResult<SimpleMessageDto>> ResetPassword([FromBody] ResetPasswordRequestDto request, CancellationToken ct)
        {
            try
            {
                await _authService.ResetPasswordAsync(request, ct);
                return Ok(new SimpleMessageDto("Đặt lại mật khẩu thành công."));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("google-client-id")]
        public ActionResult<object> GetGoogleClientId([FromServices] IConfiguration configuration)
        {
            var clientId = (configuration["GoogleAuth:ClientId"] ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(clientId))
            {
                return NotFound(new { message = "Google Client ID chưa được cấu hình." });
            }

            return Ok(new { clientId });
        }

    }
}
