using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/breed-pricing")]
    public sealed class BreedPricingController : ControllerBase
    {
        private readonly ShopPetDatabaseContext _db;

        public BreedPricingController(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<ActionResult<IReadOnlyList<BreedPricingDto>>> GetAll(CancellationToken ct)
        {
            var items = await _db.BreedPricings
                .AsNoTracking()
                .Include(bp => bp.Breed)
                .ThenInclude(b => b!.Species)
                .OrderBy(bp => bp.BreedId)
                .Select(bp => new BreedPricingDto(
                    bp.BreedPricingId,
                    bp.BreedId,
                    bp.Breed!.BreedName,
                    bp.Breed.Species != null ? bp.Breed.Species.SpeciesName : null,
                    bp.PriceAdjust
                ))
                .ToListAsync(ct);

            return Ok(items);
        }

        [HttpGet("breed/{breedId:int}")]
        public async Task<ActionResult<BreedPricingDto>> GetByBreed(int breedId, CancellationToken ct)
        {
            var item = await _db.BreedPricings
                .AsNoTracking()
                .Include(bp => bp.Breed)
                .ThenInclude(b => b!.Species)
                .Where(bp => bp.BreedId == breedId)
                .Select(bp => new BreedPricingDto(
                    bp.BreedPricingId,
                    bp.BreedId,
                    bp.Breed!.BreedName,
                    bp.Breed.Species != null ? bp.Breed.Species.SpeciesName : null,
                    bp.PriceAdjust
                ))
                .FirstOrDefaultAsync(ct);

            if (item == null)
            {
                return NotFound(new { message = "Không tìm thấy BreedPricing cho giống loài này." });
            }

            return Ok(item);
        }

        [HttpPost]
        public async Task<ActionResult<BreedPricingDto>> Create([FromBody] CreateBreedPricingRequest request, CancellationToken ct)
        {
            if (request.BreedId <= 0)
            {
                return BadRequest(new { message = "BreedId không hợp lệ." });
            }

            if (request.PriceAdjustPercent < 1 || request.PriceAdjustPercent > 500)
            {
                return BadRequest(new { message = "PriceAdjust phải từ 1% đến 500%." });
            }

            var breedExists = await _db.Breeds
                .AsNoTracking()
                .Include(b => b.Species)
                .AnyAsync(b => b.BreedId == request.BreedId, ct);

            if (!breedExists)
            {
                return BadRequest(new { message = "Giống loài không tồn tại." });
            }

            var existing = await _db.BreedPricings
                .FirstOrDefaultAsync(bp => bp.BreedId == request.BreedId, ct);

            if (existing != null)
            {
                return BadRequest(new { message = "Đã tồn tại PriceAdjust cho giống loài này. Vui lòng sử dụng PUT để cập nhật." });
            }

            var breedPricing = new BreedPricing
            {
                BreedId = request.BreedId,
                PriceAdjust = request.PriceAdjustPercent
            };

            _db.BreedPricings.Add(breedPricing);
            await _db.SaveChangesAsync(ct);

            var result = await _db.BreedPricings
                .AsNoTracking()
                .Include(bp => bp.Breed)
                .ThenInclude(b => b!.Species)
                .Where(bp => bp.BreedPricingId == breedPricing.BreedPricingId)
                .Select(bp => new BreedPricingDto(
                    bp.BreedPricingId,
                    bp.BreedId,
                    bp.Breed!.BreedName,
                    bp.Breed.Species != null ? bp.Breed.Species.SpeciesName : null,
                    bp.PriceAdjust
                ))
                .FirstAsync(ct);

            return CreatedAtAction(nameof(GetByBreed), new { breedId = breedPricing.BreedId }, result);
        }

        [HttpPut("{id:int}")]
        public async Task<ActionResult<BreedPricingDto>> Update(int id, [FromBody] UpdateBreedPricingRequest request, CancellationToken ct)
        {
            if (request.PriceAdjustPercent < 1 || request.PriceAdjustPercent > 500)
            {
                return BadRequest(new { message = "PriceAdjust phải từ 1% đến 500%." });
            }

            var breedPricing = await _db.BreedPricings
                .FirstOrDefaultAsync(bp => bp.BreedPricingId == id, ct);

            if (breedPricing == null)
            {
                return NotFound(new { message = "Không tìm thấy BreedPricing." });
            }

            breedPricing.PriceAdjust = request.PriceAdjustPercent;
            await _db.SaveChangesAsync(ct);

            var result = await _db.BreedPricings
                .AsNoTracking()
                .Include(bp => bp.Breed)
                .ThenInclude(b => b!.Species)
                .Where(bp => bp.BreedPricingId == id)
                .Select(bp => new BreedPricingDto(
                    bp.BreedPricingId,
                    bp.BreedId,
                    bp.Breed!.BreedName,
                    bp.Breed.Species != null ? bp.Breed.Species.SpeciesName : null,
                    bp.PriceAdjust
                ))
                .FirstAsync(ct);

            return Ok(result);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id, CancellationToken ct)
        {
            var breedPricing = await _db.BreedPricings
                .FirstOrDefaultAsync(bp => bp.BreedPricingId == id, ct);

            if (breedPricing == null)
            {
                return NotFound(new { message = "Không tìm thấy BreedPricing." });
            }

            _db.BreedPricings.Remove(breedPricing);
            await _db.SaveChangesAsync(ct);

            return NoContent();
        }

        [HttpPost("seed-all")]
        public async Task<ActionResult<IReadOnlyList<BreedPricingDto>>> SeedAllBreeds(CancellationToken ct)
        {
            var addedCount = 0;
            var updatedCount = 0;

            // Lấy tất cả breeds
            var allBreeds = await _db.Breeds
                .AsNoTracking()
                .Include(b => b.Species)
                .ToListAsync(ct);

            foreach (var breed in allBreeds)
            {
                // Tính % dựa trên species và breed name
                decimal priceAdjust = CalculatePriceAdjust(breed.BreedName, breed.Species?.SpeciesName ?? "");

                // Kiểm tra đã tồn tại chưa
                var existing = await _db.BreedPricings
                    .FirstOrDefaultAsync(bp => bp.BreedId == breed.BreedId, ct);

                if (existing != null)
                {
                    // Cập nhật nếu khác
                    if (existing.PriceAdjust != priceAdjust)
                    {
                        existing.PriceAdjust = priceAdjust;
                        updatedCount++;
                    }
                }
                else
                {
                    // Thêm mới
                    _db.BreedPricings.Add(new BreedPricing
                    {
                        BreedId = breed.BreedId,
                        PriceAdjust = priceAdjust
                    });
                    addedCount++;
                }
            }

            await _db.SaveChangesAsync(ct);

            // Trả về danh sách đã tạo
            var result = await _db.BreedPricings
                .AsNoTracking()
                .Include(bp => bp.Breed)
                .ThenInclude(b => b!.Species)
                .Select(bp => new BreedPricingDto(
                    bp.BreedPricingId,
                    bp.BreedId,
                    bp.Breed!.BreedName,
                    bp.Breed.Species != null ? bp.Breed.Species.SpeciesName : null,
                    bp.PriceAdjust
                ))
                .ToListAsync(ct);

            return Ok(new
            {
                message = $"Đã seed {addedCount} breeds mới, cập nhật {updatedCount} breeds.",
                totalBreeds = result.Count,
                data = result
            });
        }

        private static decimal CalculatePriceAdjust(string breedName, string speciesName)
        {
            var name = breedName.ToLower();
            var species = speciesName.ToLower();

            // MEO - species_id = 2 (kiểm tra bằng speciesName hoặc breed patterns)
            bool isCatBreed = name.Contains("persian") || name.Contains("ragdoll") || name.Contains("british")
                           || name.Contains("maine coon") || name.Contains("siamese") || name.Contains("sphynx")
                           || name.Contains("devon") || name.Contains("cornish") || name.Contains("exotic")
                           || name.Contains("scottish") || name.Contains("russian") || name.Contains("bengal")
                           || name.Contains("birman") || name.Contains("abyssinian") || name.Contains("savannah")
                           || name.Contains("norwegian");

            if (isCatBreed || species.Contains("cat") || species.Contains("meo"))
            {
                if (name.Contains("sphynx")) return 75m;
                if (name.Contains("siamese") || name.Contains("devon") || name.Contains("cornish rex")) return 80m;
                if (name.Contains("exotic") || name.Contains("scottish") || name.Contains("russian blue")) return 85m;
                if (name.Contains("bengal") || name.Contains("british")) return 95m;
                if (name.Contains("persian") || name.Contains("ragdoll") || name.Contains("birman") || name.Contains("abyssinian")) return 100m;
                if (name.Contains("maine coon") || name.Contains("savannah")) return 115m;
                if (name.Contains("norwegian forest")) return 120m;
                return 100m;
            }

            // CHO - species_id = 1
            // Size nho
            if (name.Contains("chihuahua")) return 80m;
            if (name.Contains("pomeranian") || name.Contains("maltese") || name.Contains("shih tzu") || name.Contains("poodle") || name.Contains("yorkshire") || name.Contains("yorkie")) return 85m;
            if (name.Contains("papillon") || name.Contains("japanese chin") || name.Contains("italian grey")) return 82m;
            if (name.Contains("affenpinscher") || name.Contains("brussels")) return 78m;

            // Size trung binh
            if (name.Contains("beagle") || name.Contains("corgi")) return 95m;
            if (name.Contains("golden") || name.Contains("labrador") || name.Contains("border") || name.Contains("shiba") || name.Contains("dalmatian") || name.Contains("australian") || name.Contains("bulldog")) return 100m;

            // Size lon
            if (name.Contains("german shepherd")) return 105m;
            if (name.Contains("husky") || name.Contains("alaskan")) return 120m;
            if (name.Contains("samoyed")) return 130m;
            if (name.Contains("chow") || name.Contains("akita")) return 115m;
            if (name.Contains("boxer") || name.Contains("doberman") || name.Contains("rottweiler") || name.Contains("pitbull") || name.Contains("bull terrier") || name.Contains("weimaraner")) return 110m;

            // Giant breed
            if (name.Contains("great dane")) return 145m;
            if (name.Contains("saint bernard") || name.Contains("mastiff") || name.Contains("newfoundland")) return 145m;
            if (name.Contains("leonberger") || name.Contains("irish wolfhound") || name.Contains("anatolian") || name.Contains("bernese") || name.Contains("tibetan")) return 140m;

            // Default
            return 100m;
        }
    }
}
