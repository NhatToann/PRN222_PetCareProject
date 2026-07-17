namespace PetShop.Interfaces
{
    public interface IEmailService
    {
        Task SendOtpEmailAsync(string toEmail, string otp, CancellationToken ct = default);
        Task SendGoogleFirstLoginEmailAsync(string toEmail, string? name, CancellationToken ct = default);
        Task SendOrderInvoiceEmailAsync(
            string toEmail,
            string? customerName,
            string orderCode,
            IEnumerable<(string ItemName, int Quantity, decimal UnitPrice)> items,
            decimal totalAmount,
            CancellationToken ct = default);
        Task SendSpaInvoiceEmailAsync(
            string toEmail,
            string? customerName,
            string bookingCode,
            IEnumerable<(string ItemName, int Quantity, decimal UnitPrice)> items,
            decimal totalAmount,
            string paymentStatusLabel,
            CancellationToken ct = default);
        Task SendBoardingInvoiceEmailAsync(
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
            CancellationToken ct = default);
    }
}
