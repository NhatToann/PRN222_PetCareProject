namespace PetShop.Models
{
    public sealed record CreatePayOSPaymentRequest(
        int OrderCode,
        decimal Amount,
        string Description,
        string ReturnUrl,
        string CancelUrl
    );

    public sealed record PayOSCheckoutResult(string CheckoutUrl, int OrderCode, decimal Amount, string Description);

    public sealed record PayOSWebhookResult(bool Success, string Message);

    public sealed record PayOSWebhookPayload(bool? Success, string? Code, PayOSWebhookData? Data);

    public sealed record PayOSWebhookData(int OrderCode, string? Status);

    public sealed record PayOSPaymentStatusResult(int OrderCode, string Status, bool IsPaid, int Amount, string? CheckoutUrl);
}
