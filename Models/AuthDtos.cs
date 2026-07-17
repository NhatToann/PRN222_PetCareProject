namespace PetShop.Models
{
    public sealed record RegisterRequestDto(
        string Name,
        string Email,
        string Password,
        string? Phone,
        string? Address
    );

    public sealed record LoginRequestDto(
        string Email,
        string Password
    );

    public sealed record GoogleLoginRequestDto(
        string? IdToken,
        string? AccessToken
    );

    public sealed record SendEmailOtpRequestDto(
        string Email
    );

    public sealed record VerifyEmailOtpRequestDto(
        string Email,
        string OtpCode
    );

    public sealed record ResetPasswordRequestDto(
        string Email,
        string? ResetToken,
        string? OtpCode,
        string NewPassword,
        string ConfirmPassword
    );

    public sealed record AuthResponseDto(
        int UserId,
        string Name,
        string Email,
        string Role,
        string Status
    );

    public sealed record SimpleMessageDto(string Message);
}
