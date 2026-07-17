using PetShop.Models;

namespace PetShop.Interfaces;

public interface IPetsClient
{
    Task<FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>> GetByCustomerAsync(int customerId, CancellationToken ct = default);

    Task<FrontendApiResult<IReadOnlyList<PetWithBreedPriceDto>>> GetWithPricingAsync(int customerId, int serviceId, CancellationToken ct = default);

    Task<FrontendApiResult<IReadOnlyList<PetManageDto>>> GetManageAsync(int customerId, CancellationToken ct = default);

    Task<FrontendApiResult<IReadOnlyList<SpeciesOptionDto>>> GetSpeciesAsync(CancellationToken ct = default);

    Task<FrontendApiResult<IReadOnlyList<BreedOptionDto>>> GetBreedsAsync(int? speciesId = null, CancellationToken ct = default);

    Task<FrontendApiResult<PetManageDto>> CreateAsync(UpsertPetRequestDto request, CancellationToken ct = default);

    Task<FrontendApiResult<PetManageDto>> UpdateAsync(int petId, UpsertPetRequestDto request, CancellationToken ct = default);

    Task<FrontendApiResult<bool>> DeleteAsync(int petId, int customerId, CancellationToken ct = default);
}
