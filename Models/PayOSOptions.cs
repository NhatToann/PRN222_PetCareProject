namespace PetShop.Models
{
    public sealed class PayOSOptions
    {
        public const string SectionName = "PayOS";

        public string ClientId { get; set; } = string.Empty;

        public string ApiKey { get; set; } = string.Empty;

        public string ChecksumKey { get; set; } = string.Empty;

        public string BaseUrl { get; set; } = "https://api-merchant.payos.vn/v2";

        public string? WebhookUrl { get; set; }
    }
}
