namespace PetShop.Models;

public static class SpaBookingStatus
{
    public const string Pending = "Chưa thanh toán";
    public const string AwaitingPayOS = "Chờ thanh toán PayOS";
    public const string AwaitingConfirm = "Chờ xác nhận";
    public const string Paid = "Đã thanh toán";
    public const string Confirmed = "Đã xác nhận";
    public const string InProgress = "Đang thực hiện";
    public const string Completed = "Hoàn thành";
    public const string Cancelled = "Đã hủy";

    public static readonly IReadOnlyDictionary<string, string> Display = new Dictionary<string, string>
    {
        [Pending] = "Chờ thanh toán",
        [AwaitingPayOS] = "Chờ thanh toán PayOS",
        [AwaitingConfirm] = "Chờ xác nhận",
        [Paid] = "Đã thanh toán",
        [Confirmed] = "Đã xác nhận",
        [InProgress] = "Đang thực hiện",
        [Completed] = "Hoàn thành",
        [Cancelled] = "Đã hủy",
    };
}