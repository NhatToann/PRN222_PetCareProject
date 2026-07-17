using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using Google.Apis.Auth;
using Microsoft.Extensions.Configuration;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services
{
    public sealed class AuthService : IAuthService
    {
        private readonly IAuthRepository _authRepository;
        private readonly IConfiguration _configuration;
        private readonly IEmailService _emailService;

        public AuthService(IAuthRepository authRepository, IConfiguration configuration, IEmailService emailService)
        {
            _authRepository = authRepository;
            _configuration = configuration;
            _emailService = emailService;
        }

        public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken ct = default)
        {
            var email = NormalizeEmail(request.Email);

            if (string.IsNullOrWhiteSpace(email))
            {
                throw new ArgumentException("Email không được để trống.");
            }

            if (string.IsNullOrWhiteSpace(request.Password))
            {
                throw new ArgumentException("Mật khẩu không được để trống.");
            }

            var existing = await _authRepository.GetCustomerByEmailAsync(email, ct);
            if (existing is not null)
            {
                throw new InvalidOperationException("Email đã tồn tại.");
            }

            var customer = new Customer
            {
                Name = string.IsNullOrWhiteSpace(request.Name) ? null : request.Name.Trim(),
                Email = email,
                Password = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim(),
                AddressCustomer = string.IsNullOrWhiteSpace(request.Address) ? null : request.Address.Trim(),
                Role = "user",
                Status = "inactive"
            };

            var created = await _authRepository.CreateCustomerAsync(customer, ct);

            var otp = GenerateOtp();
            created.OtpCode = otp;
            created.OtpExpiry = DateTime.UtcNow.AddMinutes(5);
            await _authRepository.UpdateCustomerAsync(created, ct);

            await _emailService.SendOtpEmailAsync(created.Email!, otp, ct);

            return MapToAuthResponse(created);
        }

        public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken ct = default)
        {
            var identity = (request.Email ?? string.Empty).Trim();
            var normalizedEmail = NormalizeEmail(request.Email);
            var password = request.Password ?? string.Empty;

            if (string.IsNullOrWhiteSpace(identity) || string.IsNullOrWhiteSpace(password))
            {
                throw new UnauthorizedAccessException("Email hoặc mật khẩu không hợp lệ.");
            }

            var staff = await _authRepository.GetStaffByEmailAsync(normalizedEmail, ct);
            if (staff is not null && IsPasswordValid(password, staff.Password))
            {
                var role = string.Equals(staff.Position, "admin", StringComparison.OrdinalIgnoreCase)
                    || string.Equals(staff.Position, "quản lý", StringComparison.OrdinalIgnoreCase)
                    ? "admin"
                    : "staff";

                return new AuthResponseDto(
                    staff.StaffId,
                    staff.Name,
                    staff.Email ?? normalizedEmail,
                    role,
                    "active"
                );
            }

            var doctor = await _authRepository.GetDoctorByEmailAsync(normalizedEmail, ct);
            if (doctor is not null && IsPasswordValid(password, doctor.Password))
            {
                return new AuthResponseDto(
                    doctor.DoctorId,
                    doctor.Name,
                    doctor.Email,
                    "doctor",
                    "active"
                );
            }

            var admin = await _authRepository.GetAdminByEmailOrUsernameAsync(identity, ct);
            if (admin is not null && IsPasswordValid(password, admin.Password))
            {
                return new AuthResponseDto(
                    admin.AdminId,
                    admin.Name ?? admin.Username,
                    admin.Email ?? normalizedEmail,
                    "admin",
                    "active"
                );
            }

            var customer = await _authRepository.GetCustomerByEmailAsync(normalizedEmail, ct);
            if (customer is null || string.IsNullOrWhiteSpace(customer.Password))
            {
                throw new UnauthorizedAccessException("Email hoặc mật khẩu không đúng.");
            }

            if (!IsPasswordValid(password, customer.Password))
            {
                throw new UnauthorizedAccessException("Email hoặc mật khẩu không đúng.");
            }

            if (!string.Equals(customer.Status, "active", StringComparison.OrdinalIgnoreCase))
            {
                throw new UnauthorizedAccessException("Tài khoản chưa xác thực email. Vui lòng nhập OTP đã gửi qua email.");
            }

            return MapToAuthResponse(customer);
        }

        public async Task<AuthResponseDto> LoginWithGoogleAsync(GoogleLoginRequestDto request, CancellationToken ct = default)
        {
            var hasIdToken = !string.IsNullOrWhiteSpace(request.IdToken);
            var hasAccessToken = !string.IsNullOrWhiteSpace(request.AccessToken);

            if (!hasIdToken && !hasAccessToken)
            {
                throw new ArgumentException("Cần cung cấp IdToken hoặc AccessToken.");
            }

            string? email = null;
            string? googleSubject = null;
            string? name = null;
            bool? emailVerified = null;

            if (hasIdToken)
            {
                var payload = await ValidateGoogleIdTokenAsync(request.IdToken!);
                email = payload.Email;
                googleSubject = payload.Subject;
                name = payload.Name;
                emailVerified = payload.EmailVerified;
            }
            else
            {
                (email, googleSubject, name, emailVerified) = await GetGoogleProfileFromAccessTokenAsync(request.AccessToken!, ct);
            }

            if (string.IsNullOrWhiteSpace(email))
            {
                throw new UnauthorizedAccessException("Không lấy được email từ Google.");
            }

            if (emailVerified.HasValue && emailVerified.Value == false)
            {
                throw new UnauthorizedAccessException("Email Google chưa được xác minh.");
            }

            email = NormalizeEmail(email);

            var customer = await _authRepository.GetCustomerByEmailAsync(email, ct);

            var isFirstGoogleLogin = customer is null;

            if (customer is null)
            {
                customer = new Customer
                {
                    Name = name,
                    Email = email,
                    GoogleId = googleSubject,
                    Password = null,
                    Role = "user",
                    Status = "active"
                };

                customer = await _authRepository.CreateCustomerAsync(customer, ct);
            }
            else
            {
                customer.GoogleId ??= googleSubject;
                customer.Name = string.IsNullOrWhiteSpace(customer.Name) ? name : customer.Name;
                customer.Status = "active";
                await _authRepository.UpdateCustomerAsync(customer, ct);
            }

            if (isFirstGoogleLogin)
            {
                await _emailService.SendGoogleFirstLoginEmailAsync(customer.Email!, customer.Name, ct);
            }

            return MapToAuthResponse(customer);
        }

        private async Task<GoogleJsonWebSignature.Payload> ValidateGoogleIdTokenAsync(string idToken)
        {
            try
            {
                var audiences = GetGoogleAudiences();

                if (audiences.Count == 0)
                {
                    throw new InvalidOperationException("Google Login chưa cấu hình đúng. Hãy set GoogleAuth:ClientId hoặc GoogleAuth:ClientIds bằng Client ID thật từ Google Cloud Console.");
                }

                return await GoogleJsonWebSignature.ValidateAsync(idToken,
                    new GoogleJsonWebSignature.ValidationSettings
                    {
                        Audience = audiences
                    });
            }
            catch (InvalidJwtException ex)
            {
                throw new UnauthorizedAccessException($"Google IdToken không hợp lệ: {ex.Message}");
            }
        }

        private static async Task<(string? Email, string? Subject, string? Name, bool? EmailVerified)> GetGoogleProfileFromAccessTokenAsync(string accessToken, CancellationToken ct)
        {
            using var httpClient = new HttpClient
            {
                BaseAddress = new Uri("https://www.googleapis.com/")
            };

            httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

            using var response = await httpClient.GetAsync("oauth2/v3/userinfo", ct);
            if (!response.IsSuccessStatusCode)
            {
                throw new UnauthorizedAccessException("Google AccessToken không hợp lệ hoặc đã hết hạn.");
            }

            var json = await response.Content.ReadAsStringAsync(ct);

            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            string? email = root.TryGetProperty("email", out var emailElement) ? emailElement.GetString() : null;
            string? subject = root.TryGetProperty("sub", out var subElement) ? subElement.GetString() : null;
            string? name = root.TryGetProperty("name", out var nameElement) ? nameElement.GetString() : null;
            bool? emailVerified = root.TryGetProperty("email_verified", out var emailVerifiedElement)
                ? emailVerifiedElement.GetBoolean()
                : null;

            return (email, subject, name, emailVerified);
        }

        public async Task SendEmailOtpAsync(SendEmailOtpRequestDto request, CancellationToken ct = default)
        {
            var email = NormalizeEmail(request.Email);
            if (string.IsNullOrWhiteSpace(email))
            {
                throw new ArgumentException("Email không được để trống.");
            }

            var hasAccount = await _authRepository.EmailExistsInAnyRoleAsync(email, ct);
            if (!hasAccount)
            {
                throw new KeyNotFoundException("Email chưa đăng ký tài khoản.");
            }

            var customer = await _authRepository.GetCustomerByEmailAsync(email, ct)
                ?? throw new KeyNotFoundException("Email chưa có tài khoản khách hàng để nhận OTP.");

            var otp = GenerateOtp();
            customer.OtpCode = otp;
            customer.OtpExpiry = DateTime.UtcNow.AddMinutes(5);
            await _authRepository.UpdateCustomerAsync(customer, ct);

            await _emailService.SendOtpEmailAsync(email, otp, ct);
        }

        public async Task<SimpleMessageDto> VerifyEmailOtpAsync(VerifyEmailOtpRequestDto request, CancellationToken ct = default)
        {
            var email = NormalizeEmail(request.Email);
            var otp = request.OtpCode?.Trim() ?? string.Empty;

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(otp))
            {
                throw new ArgumentException("Email và mã OTP không được để trống.");
            }

            var customer = await _authRepository.GetCustomerByEmailAsync(email, ct)
                ?? throw new KeyNotFoundException("Không tìm thấy tài khoản với email này.");

            ValidateOtp(customer, otp);

            customer.Status = "active";
            customer.ResetToken = GenerateResetToken();
            customer.ResetTokenExpiry = DateTime.UtcNow.AddMinutes(5);
            await _authRepository.UpdateCustomerAsync(customer, ct);

            return new SimpleMessageDto(customer.ResetToken ?? string.Empty);
        }

        public async Task ResetPasswordAsync(ResetPasswordRequestDto request, CancellationToken ct = default)
        {
            var email = NormalizeEmail(request.Email);
            var resetToken = request.ResetToken?.Trim() ?? string.Empty;
            var otp = request.OtpCode?.Trim() ?? string.Empty;
            var newPassword = request.NewPassword ?? string.Empty;
            var confirmPassword = request.ConfirmPassword ?? string.Empty;

            if (string.IsNullOrWhiteSpace(email))
            {
                throw new ArgumentException("Email không được để trống.");
            }

            if (string.IsNullOrWhiteSpace(newPassword))
            {
                throw new ArgumentException("Mật khẩu mới không được để trống.");
            }

            if (!string.Equals(newPassword, confirmPassword, StringComparison.Ordinal))
            {
                throw new ArgumentException("Mật khẩu xác nhận không khớp.");
            }

            var customer = await _authRepository.GetCustomerByEmailAsync(email, ct)
                ?? throw new KeyNotFoundException("Không tìm thấy tài khoản với email này.");

            var usedResetToken = false;
            if (!string.IsNullOrWhiteSpace(resetToken))
            {
                ValidateResetToken(customer, resetToken);
                usedResetToken = true;
            }
            else if (!string.IsNullOrWhiteSpace(otp))
            {
                ValidateOtp(customer, otp);
            }
            else
            {
                throw new ArgumentException("Cần cung cấp reset token hoặc OTP.");
            }

            customer.Password = BCrypt.Net.BCrypt.HashPassword(newPassword);
            ConsumeOtp(customer);
            if (usedResetToken)
            {
                ConsumeResetToken(customer);
            }
            await _authRepository.UpdateCustomerAsync(customer, ct);
        }

        private static void ValidateOtp(Customer customer, string otp)
        {
            if (string.IsNullOrWhiteSpace(customer.OtpCode) || customer.OtpExpiry is null)
            {
                throw new UnauthorizedAccessException("Mã OTP không hợp lệ hoặc chưa được gửi.");
            }

            if (customer.OtpExpiry < DateTime.UtcNow)
            {
                throw new UnauthorizedAccessException("Mã OTP đã hết hạn.");
            }

            if (!string.Equals(customer.OtpCode, otp, StringComparison.Ordinal))
            {
                throw new UnauthorizedAccessException("Mã OTP không đúng.");
            }
        }

        private static void ConsumeOtp(Customer customer)
        {
            customer.OtpCode = null;
            customer.OtpExpiry = null;
        }

        private static void ValidateResetToken(Customer customer, string resetToken)
        {
            if (string.IsNullOrWhiteSpace(customer.ResetToken) || customer.ResetTokenExpiry is null)
            {
                throw new UnauthorizedAccessException("Reset token không hợp lệ hoặc chưa được cấp.");
            }

            if (customer.ResetTokenExpiry < DateTime.UtcNow)
            {
                throw new UnauthorizedAccessException("Reset token đã hết hạn.");
            }

            if (!string.Equals(customer.ResetToken, resetToken, StringComparison.Ordinal))
            {
                throw new UnauthorizedAccessException("Reset token không đúng.");
            }
        }

        private static void ConsumeResetToken(Customer customer)
        {
            customer.ResetToken = null;
            customer.ResetTokenExpiry = null;
        }


        private List<string> GetGoogleAudiences()
        {
            var audiences = new List<string>();

            var singleClientId = _configuration["GoogleAuth:ClientId"]?.Trim();
            if (!string.IsNullOrWhiteSpace(singleClientId) && !IsPlaceholder(singleClientId))
            {
                audiences.Add(singleClientId);
            }

            var clientIdsCsv = _configuration["GoogleAuth:ClientIds"]?.Trim();
            if (!string.IsNullOrWhiteSpace(clientIdsCsv))
            {
                foreach (var id in clientIdsCsv.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                {
                    if (!string.IsNullOrWhiteSpace(id) && !IsPlaceholder(id) && !audiences.Contains(id, StringComparer.OrdinalIgnoreCase))
                    {
                        audiences.Add(id);
                    }
                }
            }

            return audiences;
        }

        private static string GenerateOtp()
        {
            var random = new Random();
            return random.Next(100000, 999999).ToString();
        }

        private static string GenerateResetToken()
        {
            return Guid.NewGuid().ToString("N");
        }

        private static string NormalizeEmail(string? email)
        {
            return (email ?? string.Empty).Trim().ToLowerInvariant();
        }

        private static bool IsPlaceholder(string value)
        {
            return value.Contains("YOUR_", StringComparison.OrdinalIgnoreCase)
                   || value.Contains("YOUR-", StringComparison.OrdinalIgnoreCase)
                   || value.Contains("example", StringComparison.OrdinalIgnoreCase)
                   || value.Contains("placeholder", StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsPasswordValid(string password, string? storedPassword)
        {
            if (string.IsNullOrWhiteSpace(storedPassword))
            {
                return false;
            }

            var normalizedStored = storedPassword.Trim();

            if (normalizedStored.StartsWith("$2", StringComparison.Ordinal))
            {
                return BCrypt.Net.BCrypt.Verify(password, normalizedStored);
            }

            return string.Equals(password, normalizedStored, StringComparison.Ordinal);
        }

        private static AuthResponseDto MapToAuthResponse(Customer customer)
        {
            return new AuthResponseDto(
                customer.CustomerId,
                customer.Name ?? string.Empty,
                customer.Email ?? string.Empty,
                customer.Role,
                customer.Status ?? string.Empty
            );
        }
    }
}
