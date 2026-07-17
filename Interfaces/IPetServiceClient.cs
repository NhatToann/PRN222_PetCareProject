using PetShop.Models;

namespace PetShop.Interfaces;

public interface IPetServiceClient
{
    Task<FrontendApiResult<IReadOnlyList<PetServiceDto>>> GetAllAsync(string? keyword = null, CancellationToken ct = default);

    Task<FrontendApiResult<PetServiceDetailDto>> GetDetailAsync(int serviceId, CancellationToken ct = default);

    Task<FrontendApiResult<PetServiceGroupedDto>> GetGroupedAsync(CancellationToken ct = default);
}