using System.Text;
using HandlebarsDotNet;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using PetShop.Interfaces;

namespace PetShop.Services
{
    public sealed class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly IWebHostEnvironment _environment;

        public EmailService(IConfiguration configuration, IWebHostEnvironment environment)
        {
            _configuration = configuration;
            _environment = environment;
        }

        public async Task SendOtpEmailAsync(string toEmail, string otp, CancellationToken ct = default)
        {
            var subject = "PetShop - Xac thuc email dang ky";
            var body = $"Chao ban,\n\nCam on ban da dang ky tai khoan tai PetShop.\nMa OTP xac thuc email cua ban la: {otp}\nMa co hieu luc trong 10 phut.\n\nTran trong,\nPetShop";

            await SendPlainTextEmailAsync(toEmail, subject, body, ct);
        }

        public async Task SendGoogleFirstLoginEmailAsync(string toEmail, string? name, CancellationToken ct = default)
        {
            var displayName = string.IsNullOrWhiteSpace(name) ? "ban" : name.Trim();

            var subject = "PetShop - Dang nhap Google thanh cong";
            var body = $"Xin chao {displayName},\n\nBan vua dang nhap bang Google lan dau vao PetShop.\nNeu day khong phai ban, vui long lien he ho tro ngay.\n\nTran trong,\nPetShop";

            await SendPlainTextEmailAsync(toEmail, subject, body, ct);
        }

        public async Task SendOrderInvoiceEmailAsync(
            string toEmail,
            string? customerName,
            string orderCode,
            IEnumerable<(string ItemName, int Quantity, decimal UnitPrice)> items,
            decimal totalAmount,
            CancellationToken ct = default)
        {
            var safeName = string.IsNullOrWhiteSpace(customerName) ? "Quy khach" : customerName.Trim();
            var subject = $"PetShop - Hoa don don hang {orderCode}";

            var template = LoadHandlebarsTemplate("wwwroot/EmailTemplates/OrderInvoice.hbs");
            var html = template(new
            {
                CustomerName = safeName,
                OrderCode = orderCode,
                Items = items.Select(i => new
                {
                    ItemName = Escape(i.ItemName),
                    Quantity = i.Quantity,
                    UnitPrice = i.UnitPrice.ToString("N0"),
                    LineTotal = (i.Quantity * i.UnitPrice).ToString("N0")
                }),
                TotalAmount = totalAmount.ToString("N0")
            });

            await SendHtmlEmailAsync(toEmail, subject, html, ct);
        }

        public async Task SendSpaInvoiceEmailAsync(
            string toEmail,
            string? customerName,
            string bookingCode,
            IEnumerable<(string ItemName, int Quantity, decimal UnitPrice)> items,
            decimal totalAmount,
            string paymentStatusLabel,
            CancellationToken ct = default)
        {
            var safeName = string.IsNullOrWhiteSpace(customerName) ? "Quy khach" : customerName.Trim();
            var statusIsCancelled = string.Equals(paymentStatusLabel.Trim(), "Đã hủy", StringComparison.OrdinalIgnoreCase)
                                  || paymentStatusLabel.Trim().Equals("cancelled", StringComparison.OrdinalIgnoreCase);

            string subject;
            string html;

            if (statusIsCancelled)
            {
                subject = $"PetShop - Thong bao huy dich vu spa {bookingCode}";
                var template = LoadHandlebarsTemplate("wwwroot/EmailTemplates/SpaCancellation.hbs");
                html = template(new
                {
                    CustomerName = EscapeHtmlMinimal(safeName),
                    BookingCode = bookingCode,
                    StatusLabel = paymentStatusLabel,
                    StatusClass = "cancelled",
                    Items = items.Select(i => new
                    {
                        ItemName = EscapeHtmlMinimal(i.ItemName),
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice.ToString("N0"),
                        LineTotal = (i.Quantity * i.UnitPrice).ToString("N0")
                    }),
                    TotalAmount = totalAmount.ToString("N0")
                });
            }
            else
            {
                subject = $"PetShop - Hoa don spa {bookingCode}";
                var template = LoadHandlebarsTemplate("wwwroot/EmailTemplates/SpaInvoice.hbs");
                html = template(new
                {
                    CustomerName = safeName,
                    BookingCode = bookingCode,
                    Items = items.Select(i => new
                    {
                        ItemName = Escape(i.ItemName),
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice.ToString("N0"),
                        LineTotal = (i.Quantity * i.UnitPrice).ToString("N0")
                    }),
                    TotalAmount = totalAmount.ToString("N0")
                });
            }

            await SendHtmlEmailAsync(toEmail, subject, html, ct);
        }

        public async Task SendBoardingInvoiceEmailAsync(
            string toEmail,
            string? customerName,
            string bookingCode,
            string roomDisplayName,
            DateOnly checkIn,
            DateOnly checkOut,
            int days,
            int pets,
            string? notes,
            decimal pricePerDay,
            decimal totalPrice,
            string paymentMethodLabel,
            string paymentStatusLabel,
            CancellationToken ct = default)
        {
            var safeName = string.IsNullOrWhiteSpace(customerName) ? "Quy khach" : customerName.Trim();
            var subject = $"PetShop - Xac nhan dat phong boarding {bookingCode}";

            var statusIsPaid = string.Equals(paymentStatusLabel.Trim(), "Đã thanh toán", StringComparison.OrdinalIgnoreCase);

            var template = LoadHandlebarsTemplate("wwwroot/EmailTemplates/BoardingInvoice.hbs");
            var html = template(new
            {
                CustomerName = EscapeHtmlMinimal(safeName),
                BookingCode = bookingCode,
                RoomDisplay = EscapeHtmlMinimal(string.IsNullOrWhiteSpace(roomDisplayName) ? "Phong boarding" : roomDisplayName.Trim()),
                CheckIn = checkIn.ToString("dd/MM/yyyy"),
                CheckOut = checkOut.ToString("dd/MM/yyyy"),
                Days = days,
                Pets = pets,
                Notes = EscapeHtmlMinimal(notes ?? ""),
                PricePerDay = pricePerDay.ToString("N0"),
                TotalPrice = totalPrice.ToString("N0"),
                PaymentMethodLabel = EscapeHtmlMinimal(paymentMethodLabel),
                PaymentStatusLabel = EscapeHtmlMinimal(paymentStatusLabel),
                PaymentStatusClass = statusIsPaid ? "payment-badge--paid" : "payment-badge--unpaid"
            });

            await SendHtmlEmailAsync(toEmail, subject, html, ct);
        }

        private async Task SendPlainTextEmailAsync(string toEmail, string subject, string body, CancellationToken ct)
        {
            var message = CreateBaseMessage(toEmail, subject);
            message.Body = new TextPart("plain") { Text = body };
            await SendAsync(message, ct);
        }

        private async Task SendHtmlEmailAsync(string toEmail, string subject, string htmlBody, CancellationToken ct)
        {
            var message = CreateBaseMessage(toEmail, subject);
            var htmlPart = new TextPart("html");
            htmlPart.SetText(Encoding.UTF8, htmlBody);
            message.Body = htmlPart;
            await SendAsync(message, ct);
        }

        private HandlebarsTemplate<object, object> LoadHandlebarsTemplate(string relativePath)
        {
            var fullPath = Path.Combine(_environment.ContentRootPath, relativePath.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(fullPath))
            {
                throw new FileNotFoundException($"Khong tim thay email template: {relativePath}");
            }

            var templateContent = File.ReadAllText(fullPath);
            return Handlebars.Compile(templateContent);
        }

        private MimeMessage CreateBaseMessage(string toEmail, string subject)
        {
            if (string.IsNullOrWhiteSpace(toEmail))
            {
                throw new ArgumentException("Email nguoi nhan khong duoc de trong.");
            }

            var (_, _, _, _, from, _) = GetSmtpSettings();

            var message = new MimeMessage();
            message.From.Add(MailboxAddress.Parse(from));
            message.To.Add(MailboxAddress.Parse(toEmail.Trim()));
            message.Subject = subject;
            return message;
        }

        private async Task SendAsync(MimeMessage message, CancellationToken ct)
        {
            var (host, port, username, password, _, secureSocketOptions) = GetSmtpSettings();

            try
            {
                using var client = new SmtpClient();
                await client.ConnectAsync(host, port, secureSocketOptions, ct);
                await client.AuthenticateAsync(username, password, ct);
                await client.SendAsync(message, ct);
                await client.DisconnectAsync(true, ct);
            }
            catch (OperationCanceledException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"Gui email that bai. Kiem tra cau hinh Mail (Username/App Password/From) va ket noi SMTP. Chi tiet: {ex.Message}", ex);
            }
        }

        private (string Host, int Port, string Username, string Password, string From, SecureSocketOptions SocketOptions) GetSmtpSettings()
        {
            var host = _configuration["Mail:SmtpHost"]?.Trim();
            var portRaw = _configuration["Mail:SmtpPort"]?.Trim();
            var username = _configuration["Mail:Username"]?.Trim();
            var password = _configuration["Mail:Password"]?.Trim();
            var from = (_configuration["Mail:From"] ?? username)?.Trim();

            if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(portRaw) ||
                string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(from))
            {
                throw new InvalidOperationException("Chua cau hinh Mail trong appsettings (SmtpHost, SmtpPort, Username, Password, From).");
            }

            if (IsPlaceholder(username) || IsPlaceholder(password) || IsPlaceholder(from))
            {
                throw new InvalidOperationException("Verify Email chua cau hinh mail that. Hay thay Mail:Username, Mail:Password (App Password) va Mail:From trong appsettings.");
            }

            if (!int.TryParse(portRaw, out var port))
            {
                throw new InvalidOperationException("Mail:SmtpPort khong hop le.");
            }

            var secureSocketOptions = ParseSecureSocketOptions(_configuration["Mail:SecureSocketOptions"]);

            return (host, port, username, password, from, secureSocketOptions);
        }

        private static SecureSocketOptions ParseSecureSocketOptions(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return SecureSocketOptions.StartTls;
            }

            return value.Trim().ToLowerInvariant() switch
            {
                "auto" => SecureSocketOptions.Auto,
                "none" => SecureSocketOptions.None,
                "ssl" => SecureSocketOptions.SslOnConnect,
                "sslonconnect" => SecureSocketOptions.SslOnConnect,
                "starttls" => SecureSocketOptions.StartTls,
                "starttlswhenavailable" => SecureSocketOptions.StartTlsWhenAvailable,
                _ => SecureSocketOptions.StartTls
            };
        }

        private static bool IsPlaceholder(string value)
        {
            return value.Contains("YOUR_", StringComparison.OrdinalIgnoreCase)
                   || value.Contains("YOUR-", StringComparison.OrdinalIgnoreCase)
                   || value.Contains("example", StringComparison.OrdinalIgnoreCase)
                   || value.Contains("placeholder", StringComparison.OrdinalIgnoreCase);
        }

        private static string Escape(string value)
        {
            return System.Net.WebUtility.HtmlEncode(value ?? string.Empty);
        }

        /// <summary>
        /// Chỉ escape &lt; &gt; &amp; &quot; — giữ nguyên chữ Unicode (tiếng Việt) trong HTML.
        /// Tránh double-encode (HtmlEncode tạo &#225; rồi SMTP/MIME escape &amp; → hiển thị sai trên Gmail).
        /// </summary>
        private static string EscapeHtmlMinimal(string? value)
        {
            if (string.IsNullOrEmpty(value))
                return string.Empty;

            return value
                .Replace("&", "&amp;", StringComparison.Ordinal)
                .Replace("<", "&lt;", StringComparison.Ordinal)
                .Replace(">", "&gt;", StringComparison.Ordinal)
                .Replace("\"", "&quot;", StringComparison.Ordinal);
        }
    }
}
