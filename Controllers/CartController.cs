using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Models;

namespace PetShop.Controllers
{
    public sealed class CartController : Controller
    {
        private const string SessionKey = "cart";
        private readonly ShopPetDatabaseContext _db;

        public CartController(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        [HttpPost("/cart/dec/{id:int}")]
        public IActionResult Decrement([FromRoute] int id)
        {
            var items = HttpContext.Session.GetJson<List<CartItem>>(SessionKey) ?? new List<CartItem>();
            var idx = items.FindIndex(x => x.ProductId == id);
            if (idx >= 0)
            {
                var current = items[idx];
                var nextQty = current.Quantity - 1;
                if (nextQty <= 0) items.RemoveAt(idx);
                else items[idx] = current with { Quantity = nextQty };
                HttpContext.Session.SetJson(SessionKey, items);
            }
            return RedirectToAction(nameof(Index));
        }

        [HttpPost("/cart/remove/{id:int}")]
        public IActionResult Remove([FromRoute] int id)
        {
            var items = HttpContext.Session.GetJson<List<CartItem>>(SessionKey) ?? new List<CartItem>();
            var idx = items.FindIndex(x => x.ProductId == id);
            if (idx >= 0)
            {
                items.RemoveAt(idx);
                HttpContext.Session.SetJson(SessionKey, items);
            }
            return RedirectToAction(nameof(Index));
        }

        [HttpPost("/cart/add/{id:int}")]
        public async Task<IActionResult> Add(
            [FromRoute] int id,
            [FromForm] int qty = 1,
            [FromForm] bool goCart = false,
            [FromForm] string? returnUrl = null,
            CancellationToken ct = default)
        {
            if (qty < 1) qty = 1;

            var p = await _db.Products
                .AsNoTracking()
                .Where(x => x.ProductId == id)
                .Select(x => new { x.ProductId, x.Name, x.Price, x.StockQuantity, x.ImageUrl })
                .FirstOrDefaultAsync(ct);

            if (p is null) return NotFound("Không tìm thấy sản phẩm.");
            if (p.StockQuantity <= 0) return BadRequest("Sản phẩm đã hết hàng.");
            if (qty > p.StockQuantity) qty = p.StockQuantity;

            var items = HttpContext.Session.GetJson<List<CartItem>>(SessionKey) ?? new List<CartItem>();
            var idx = items.FindIndex(x => x.ProductId == id);
            if (idx >= 0)
            {
                var current = items[idx];
                items[idx] = current with { Quantity = current.Quantity + qty };
            }
            else
            {
                items.Add(new CartItem(p.ProductId, p.Name, p.Price, qty, p.ImageUrl));
            }

            HttpContext.Session.SetJson(SessionKey, items);

            if (goCart) return RedirectToAction(nameof(Index));

            if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
                return Redirect(returnUrl);

            return RedirectToAction(nameof(Index));
        }
    }

}
