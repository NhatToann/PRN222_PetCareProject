namespace PetShop.Models
{
    public sealed class SlotCapacityException : InvalidOperationException
    {
        public DateTime? SuggestedStart { get; }

        public SlotCapacityException(string message, DateTime? suggestedStart = null)
            : base(message)
        {
            SuggestedStart = suggestedStart;
        }
    }
}
