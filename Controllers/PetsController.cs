using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Models;

namespace PetShop.Controllers
{
    [ApiController]
    [Route("api/pets")]
    public sealed class PetsController : ControllerBase
    {
        private readonly ShopPetDatabaseContext _db;

        public PetsController(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        [HttpGet("customer/{customerId:int}")]
        public async Task<ActionResult<IReadOnlyList<PetWithBreedPriceDto>>> GetPetsByCustomer(int customerId, CancellationToken ct)
        {
            var pets = await _db.Pets
                .AsNoTracking()
                .Where(p => p.CustomerId == customerId)
                .Where(p => p.DeletedAt == null)
                .Select(p => new PetWithBreedPriceDto(
                    p.Id,
                    p.PetName,
                    p.BreedId,
                    p.Breed != null ? p.Breed.BreedName : null,
                    null,
                    null
                ))
                .ToListAsync(ct);

            return Ok(pets);
        }

        [HttpGet("customer/{customerId:int}/manage")]
        public async Task<ActionResult<IReadOnlyList<PetManageDto>>> GetPetsForManage(int customerId, CancellationToken ct)
        {
            var accessValidation = ValidateSelfAccess(customerId);
            if (accessValidation is not null)
            {
                return accessValidation;
            }

            var pets = await _db.Pets
                .AsNoTracking()
                .Include(p => p.Breed)
                .ThenInclude(b => b!.Species)
                .Where(p => p.CustomerId == customerId)
                .Where(p => p.DeletedAt == null)
                .OrderByDescending(p => p.UpdatedAt ?? p.CreatedAt)
                .Select(p => new PetManageDto(
                    p.Id,
                    p.CustomerId,
                    p.PetName,
                    p.Age,
                    p.Gender,
                    p.WeightKg,
                    p.Description,
                    p.HealthStatus,
                    p.ImagePath,
                    p.BreedId,
                    p.Breed != null ? p.Breed.BreedName : null,
                    p.Breed != null ? p.Breed.SpeciesId : null,
                    p.Breed != null && p.Breed.Species != null ? p.Breed.Species.SpeciesName : null
                ))
                .ToListAsync(ct);

            return Ok(pets);
        }

        [HttpPost("upload-image")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public async Task<ActionResult<object>> UploadImage([FromForm] IFormFile image, CancellationToken ct)
        {
            if (image is null || image.Length == 0)
            {
                return BadRequest(new { message = "Vui lòng chọn ảnh hợp lệ." });
            }

            if (image.Length > 5 * 1024 * 1024)
            {
                return BadRequest(new { message = "Ảnh vượt quá 5MB." });
            }

            var contentType = image.ContentType?.ToLowerInvariant() ?? string.Empty;
            if (!contentType.StartsWith("image/"))
            {
                return BadRequest(new { message = "Chỉ cho phép tệp ảnh." });
            }

            var webRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadDir = Path.Combine(webRoot, "uploads", "pets");
            Directory.CreateDirectory(uploadDir);

            var ext = Path.GetExtension(image.FileName);
            if (string.IsNullOrWhiteSpace(ext))
            {
                ext = ".jpg";
            }
            var safeExt = Regex.Replace(ext, @"[^a-zA-Z0-9\.]", string.Empty);
            var fileName = $"pet_{Guid.NewGuid():N}{safeExt}";
            var physicalPath = Path.Combine(uploadDir, fileName);

            await using (var stream = new FileStream(physicalPath, FileMode.Create))
            {
                await image.CopyToAsync(stream, ct);
            }

            var url = $"/uploads/pets/{fileName}";
            return Ok(new { imageUrl = url });
        }

        [HttpGet("customer/{customerId:int}/service/{serviceId:int}/pricing")]
        public async Task<ActionResult<IReadOnlyList<PetWithBreedPriceDto>>> GetPetsWithPricing(
            int customerId,
            int serviceId,
            [FromQuery] decimal? basePrice,
            CancellationToken ct)
        {
            var service = await _db.PetServices
                .AsNoTracking()
                .Where(s => s.ServiceId == serviceId)
                .Select(s => new { s.Price })
                .FirstOrDefaultAsync(ct);

            if (service == null)
            {
                return BadRequest(new { message = "Dịch vụ không tồn tại." });
            }

            var effectiveBasePrice = basePrice ?? service.Price;

            var petsWithPricing = await _db.Pets
                .AsNoTracking()
                .Include(p => p.Breed)
                .Where(p => p.CustomerId == customerId)
                .Where(p => p.DeletedAt == null)
                .Select(p => new
                {
                    p.Id,
                    p.PetName,
                    p.BreedId,
                    BreedName = p.Breed != null ? p.Breed.BreedName : null,
                    PriceAdjustPercent = _db.BreedPricings
                        .Where(bp => bp.BreedId == p.BreedId)
                        .Select(bp => (decimal?)bp.PriceAdjust)
                        .FirstOrDefault()
                })
                .ToListAsync(ct);

            var result = petsWithPricing.Select(p =>
            {
                decimal finalPrice = effectiveBasePrice;
                if (p.BreedId.HasValue && p.PriceAdjustPercent.HasValue)
                {
                    finalPrice = effectiveBasePrice * p.PriceAdjustPercent.Value / 100m;
                }
                finalPrice = Math.Max(0m, finalPrice);

                return new PetWithBreedPriceDto(
                    p.Id,
                    p.PetName,
                    p.BreedId,
                    p.BreedName,
                    p.PriceAdjustPercent,
                    finalPrice
                );
            }).ToList();

            return Ok(result);
        }

        [HttpGet("meta/species")]
        public async Task<ActionResult<IReadOnlyList<SpeciesOptionDto>>> GetSpecies(CancellationToken ct)
        {
            var species = await _db.Species
                .AsNoTracking()
                .OrderBy(s => s.SpeciesName)
                .Select(s => new SpeciesOptionDto(s.SpeciesId, s.SpeciesName))
                .ToListAsync(ct);
            return Ok(species);
        }

        [HttpGet("meta/breeds")]
        public async Task<ActionResult<IReadOnlyList<BreedOptionDto>>> GetBreeds([FromQuery] int? speciesId, CancellationToken ct)
        {
            var query = _db.Breeds.AsNoTracking().AsQueryable();
            if (speciesId.HasValue)
            {
                query = query.Where(b => b.SpeciesId == speciesId.Value);
            }

            var breeds = await query
                .OrderBy(b => b.BreedName)
                .Select(b => new BreedOptionDto(b.BreedId, b.BreedName, b.SpeciesId))
                .ToListAsync(ct);

            return Ok(breeds);
        }

        [HttpPost]
        public async Task<ActionResult<PetManageDto>> CreatePet([FromBody] UpsertPetRequestDto request, CancellationToken ct)
        {
            var accessValidation = ValidateSelfAccess(request.CustomerId);
            if (accessValidation is not null)
            {
                return accessValidation;
            }

            var validation = await ValidateUpsertRequest(request, ct);
            if (validation is not null)
            {
                return validation;
            }

            var pet = new Pet
            {
                CustomerId = request.CustomerId,
                PetName = request.PetName.Trim(),
                Age = request.Age,
                Gender = NormalizeGenderValue(request.Gender)!,
                WeightKg = request.WeightKg,
                Description = NormalizeNullable(request.Description),
                HealthStatus = NormalizeNullable(request.HealthStatus),
                ImagePath = NormalizeNullable(request.ImagePath),
                BreedId = request.BreedId,
                DeletedAt = null,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now,
            };

            _db.Pets.Add(pet);
            await _db.SaveChangesAsync(ct);

            var result = await BuildManageDto(pet.Id, ct);
            return CreatedAtAction(nameof(GetPetsForManage), new { customerId = pet.CustomerId }, result!);
        }

        [HttpPut("{petId:int}")]
        public async Task<ActionResult<PetManageDto>> UpdatePet(int petId, [FromBody] UpsertPetRequestDto request, CancellationToken ct)
        {
            var accessValidation = ValidateSelfAccess(request.CustomerId);
            if (accessValidation is not null)
            {
                return accessValidation;
            }

            var validation = await ValidateUpsertRequest(request, ct);
            if (validation is not null)
            {
                return validation;
            }

            var pet = await _db.Pets.FirstOrDefaultAsync(p => p.Id == petId && p.DeletedAt == null, ct);
            if (pet is null)
            {
                return NotFound(new { message = "Không tìm thấy thú cưng." });
            }

            if (pet.CustomerId != request.CustomerId)
            {
                return BadRequest(new { message = "Thú cưng không thuộc khách hàng này." });
            }

            pet.PetName = request.PetName.Trim();
            pet.Age = request.Age;
            pet.Gender = NormalizeGenderValue(request.Gender)!;
            pet.WeightKg = request.WeightKg;
            pet.Description = NormalizeNullable(request.Description);
            pet.HealthStatus = NormalizeNullable(request.HealthStatus);
            pet.ImagePath = NormalizeNullable(request.ImagePath);
            pet.BreedId = request.BreedId;
            pet.UpdatedAt = DateTime.Now;

            await _db.SaveChangesAsync(ct);
            var result = await BuildManageDto(pet.Id, ct);
            return Ok(result);
        }

        [HttpDelete("{petId:int}")]
        public async Task<IActionResult> DeletePet(int petId, [FromQuery] int customerId, CancellationToken ct)
        {
            var accessValidation = ValidateSelfAccess(customerId);
            if (accessValidation is not null)
            {
                return accessValidation;
            }

            var pet = await _db.Pets.FirstOrDefaultAsync(p => p.Id == petId && p.DeletedAt == null, ct);
            if (pet is null)
            {
                return NotFound(new { message = "Không tìm thấy thú cưng." });
            }

            if (pet.CustomerId != customerId)
            {
                return BadRequest(new { message = "Thú cưng không thuộc khách hàng này." });
            }

            // Soft delete: keep row and historical relations (medical records/bookings).
            pet.DeletedAt = DateTime.Now;
            pet.UpdatedAt = DateTime.Now;
            await _db.SaveChangesAsync(ct);
            return NoContent();
        }

        private async Task<ActionResult?> ValidateUpsertRequest(UpsertPetRequestDto request, CancellationToken ct)
        {
            if (request.CustomerId <= 0)
            {
                return BadRequest(new { message = "CustomerId không hợp lệ." });
            }

            if (string.IsNullOrWhiteSpace(request.PetName))
            {
                return BadRequest(new { message = "Tên thú cưng là bắt buộc." });
            }

            if (request.Age < 0 || request.Age > 60)
            {
                return BadRequest(new { message = "Tuổi thú cưng không hợp lệ." });
            }

            if (string.IsNullOrWhiteSpace(request.Gender))
            {
                return BadRequest(new { message = "Giới tính là bắt buộc." });
            }

            var normalizedGender = NormalizeGenderValue(request.Gender);
            if (normalizedGender is null)
            {
                return BadRequest(new
                {
                    message = "Giới tính không hợp lệ. Vui lòng chọn Đực/Cái (male/female)."
                });
            }

            if (request.WeightKg.HasValue && request.WeightKg.Value < 0)
            {
                return BadRequest(new { message = "Cân nặng không hợp lệ." });
            }

            var customerExists = await _db.Customers
                .AsNoTracking()
                .AnyAsync(c => c.CustomerId == request.CustomerId, ct);
            if (!customerExists)
            {
                return BadRequest(new { message = "Khách hàng không tồn tại trong hệ thống." });
            }

            if (request.BreedId.HasValue)
            {
                var breedExists = await _db.Breeds
                    .AsNoTracking()
                    .AnyAsync(b => b.BreedId == request.BreedId.Value, ct);
                if (!breedExists)
                {
                    return BadRequest(new { message = "Giống loài không tồn tại." });
                }
            }

            return null;
        }

        private async Task<PetManageDto?> BuildManageDto(int petId, CancellationToken ct)
        {
            return await _db.Pets
                .AsNoTracking()
                .Include(p => p.Breed)
                .ThenInclude(b => b!.Species)
                .Where(p => p.Id == petId)
                .Where(p => p.DeletedAt == null)
                .Select(p => new PetManageDto(
                    p.Id,
                    p.CustomerId,
                    p.PetName,
                    p.Age,
                    p.Gender,
                    p.WeightKg,
                    p.Description,
                    p.HealthStatus,
                    p.ImagePath,
                    p.BreedId,
                    p.Breed != null ? p.Breed.BreedName : null,
                    p.Breed != null ? p.Breed.SpeciesId : null,
                    p.Breed != null && p.Breed.Species != null ? p.Breed.Species.SpeciesName : null
                ))
                .FirstOrDefaultAsync(ct);
        }

        private static string? NormalizeNullable(string? value)
        {
            var trimmed = value?.Trim();
            return string.IsNullOrWhiteSpace(trimmed) ? null : trimmed;
        }

        private static string? NormalizeGenderValue(string? value)
        {
            var input = (value ?? string.Empty).Trim().ToLowerInvariant();
            return input switch
            {
                "đực" => "male",
                "duc" => "male",
                "male" => "male",
                "m" => "male",
                "cái" => "female",
                "cai" => "female",
                "female" => "female",
                "f" => "female",
                _ => null
            };
        }

        private ActionResult? ValidateSelfAccess(int customerId)
        {
            var role = (Request.Headers["X-User-Role"].ToString() ?? string.Empty).Trim().ToLowerInvariant();
            var userIdRaw = Request.Headers["X-User-Id"].ToString();

            if (role != "user" && role != "staff")
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = "Chỉ user/staff được quản lý pet của chính mình." });
            }

            if (!int.TryParse(userIdRaw, out var callerUserId) || callerUserId <= 0)
            {
                return Unauthorized(new { message = "Thiếu thông tin người dùng." });
            }

            if (callerUserId != customerId)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = "Bạn chỉ được phép CRUD pet của chính mình." });
            }

            return null;
        }
    }
}
