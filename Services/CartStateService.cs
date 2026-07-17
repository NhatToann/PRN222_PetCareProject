using Microsoft.JSInterop;
using PetShop.Models;

namespace PetShop.Services;

public sealed class CartStateService
{
    private const string KeyCart = "cart";

    public event Action? Changed;

    private List<FrontendCartItem> _items = new();
    public IReadOnlyList<FrontendCartItem> Items => _items;

    public int Count => _items.Sum(item => item.Quantity);
    public decimal Total => _items.Sum(item => item.Price * item.Quantity);

    private IJSRuntime? _js;

    public CartStateService(IJSRuntime js)
    {
        _js = js;
    }

    public void AttachRuntime(IJSRuntime js)
    {
        _js = js;
    }

    public async Task LoadAsync()
    {
        _items = new List<FrontendCartItem>();
        if (_js is null) return;
        try
        {
            var parsed = await _js.InvokeAsync<List<CartStorageItem>?>("cartStorage.read");
            if (parsed is not null)
            {
                _items = parsed.Select(p => new FrontendCartItem(
                    p.id, p.name ?? "", p.price, p.quantity, p.image, p.stockQuantity)).ToList();
            }
        }
        catch (Exception ex) when (ex is JSDisconnectedException or JSException or InvalidOperationException or System.Text.Json.JsonException)
        {
            // Circuit may not be ready, prerender phase, or localStorage payload malformed.
            // Re-load on reconnect or retry will be handled by the caller.
            System.Diagnostics.Debug.WriteLine($"[CartStateService] LoadAsync skipped: {ex.GetType().Name} {ex.Message}");
        }
    }

    public async Task AddAsync(ProductDto_temp product, int quantity = 1)
    {
        if (product.StockQuantity <= 0)
            throw new InvalidOperationException("Sản phẩm đã hết hàng.");

        var nextQuantity = Math.Clamp(quantity, 1, product.StockQuantity);
        var idx = _items.FindIndex(item => item.ProductId == product.ProductId);
        if (idx >= 0)
        {
            var current = _items[idx];
            _items[idx] = current with { Quantity = Math.Min(product.StockQuantity, current.Quantity + nextQuantity), StockQuantity = product.StockQuantity };
        }
        else
        {
            _items.Add(new FrontendCartItem(product.ProductId, product.Name, product.Price, nextQuantity, product.ImageUrl, product.StockQuantity));
        }

        await SaveAsync();
        Changed?.Invoke();
    }

    public async Task UpdateQuantityAsync(int productId, int quantity)
    {
        var idx = _items.FindIndex(item => item.ProductId == productId);
        if (idx < 0) return;

        if (quantity <= 0)
            _items.RemoveAt(idx);
        else
        {
            var item = _items[idx];
            _items[idx] = item with { Quantity = Math.Min(quantity, Math.Max(1, item.StockQuantity)) };
        }

        await SaveAsync();
        Changed?.Invoke();
    }

    public async Task RemoveAsync(int productId)
    {
        _items.RemoveAll(item => item.ProductId == productId);
        await SaveAsync();
        Changed?.Invoke();
    }

    public async Task ClearAsync()
    {
        _items.Clear();
        await SaveAsync();
        Changed?.Invoke();
    }

    private async Task SaveAsync()
    {
        if (_js is null) return;
        try
        {
            var dto = _items.Select(i => new CartStorageItem(
                i.ProductId, i.Name, i.Price, i.Quantity, i.ImageUrl, i.StockQuantity)).ToList();
            await _js.InvokeVoidAsync("cartStorage.write", dto);
        }
        catch (Exception ex) when (ex is JSDisconnectedException or InvalidOperationException)
        {
            // Circuit disconnected; persistence skipped. Data remains in memory.
            System.Diagnostics.Debug.WriteLine($"[CartStateService] SaveAsync skipped: {ex.GetType().Name} {ex.Message}");
        }
    }

    private sealed record CartStorageItem(int id, string? name, decimal price, int quantity, string? image, int stockQuantity);
}
