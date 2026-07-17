using Microsoft.AspNetCore.Mvc;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/reviews")]
    public sealed class ReviewController : ControllerBase
    {
        private readonly IReviewRepository _repo;

        public ReviewController(IReviewRepository repo)
        {
            _repo = repo;
        }

        [HttpGet("services/{serviceId:int}")]
        public async Task<ActionResult<IReadOnlyList<ReviewDisplayDto>>> GetServiceReviews(int serviceId, CancellationToken ct)
        {
            var reviews = await _repo.GetServiceReviewsAsync(serviceId, ct);
            return Ok(reviews);
        }

        [HttpGet("products/{productId:int}")]
        public async Task<ActionResult<IReadOnlyList<ReviewDisplayDto>>> GetProductReviews(int productId, CancellationToken ct)
        {
            var reviews = await _repo.GetProductReviewsAsync(productId, ct);
            return Ok(reviews);
        }

        [HttpPost("products/{productId:int}")]
        public async Task<ActionResult<SimpleMessageDto>> UpsertProductReview(
            int productId,
            [FromQuery] int customerId,
            [FromBody] CreateProductReviewRequestDto request,
            CancellationToken ct)
        {
            if (request is null)
            {
                return BadRequest(new { message = "Thiếu dữ liệu đánh giá." });
            }

            var result = await _repo.UpsertProductReviewAsync(
                productId,
                customerId,
                request.OrderId,
                request.Rating,
                request.Comment,
                ct);

            if (!result.Success)
            {
                return BadRequest(new { message = result.Message });
            }

            return Ok(new SimpleMessageDto(result.Message));
        }
    }
}
