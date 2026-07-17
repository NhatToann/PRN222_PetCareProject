using PetShop.Models;

namespace PetShop.Interfaces;

public interface IAuthClient
{
    Task<FrontendApiResult<AuthResponseDto>> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<AuthResponseDto>> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<SimpleMessageDto>> SendOtpAsync(SendEmailOtpRequestDto request, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<SimpleMessageDto>> VerifyOtpAsync(VerifyEmailOtpRequestDto request, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<SimpleMessageDto>> ResetPasswordAsync(ResetPasswordRequestDto request, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<AuthResponseDto>> GoogleLoginAsync(GoogleLoginRequestDto request, CancellationToken cancellationToken = default);

    Task<FrontendApiResult<SimpleMessageDto>> GetGoogleClientIdAsync(CancellationToken cancellationToken = default);
}
