using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken ct = default);
        Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken ct = default);
        Task<AuthResponseDto> LoginWithGoogleAsync(GoogleLoginRequestDto request, CancellationToken ct = default);
        Task SendEmailOtpAsync(SendEmailOtpRequestDto request, CancellationToken ct = default);
        Task<SimpleMessageDto> VerifyEmailOtpAsync(VerifyEmailOtpRequestDto request, CancellationToken ct = default);
        Task ResetPasswordAsync(ResetPasswordRequestDto request, CancellationToken ct = default);
    }
}
