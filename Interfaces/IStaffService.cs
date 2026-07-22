using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IStaffService
    {
        Task<IEnumerable<StaffDto>> GetAllStaffsAsync();
        Task<StaffDto?> GetStaffByIdAsync(int id);
        Task<StaffDto> CreateStaffAsync(StaffCreateUpdateDto dto);
        Task<bool> UpdateStaffAsync(int id, StaffCreateUpdateDto dto);
        Task<bool> DeleteStaffAsync(int id);
    }
}