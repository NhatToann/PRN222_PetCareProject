using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IStaffRepository
    {
        Task<IEnumerable<Staff>> GetAllAsync();
        Task<Staff?> GetByIdAsync(int id);
        Task<Staff> AddAsync(Staff staff);
        Task UpdateAsync(Staff staff);
        Task DeleteAsync(Staff staff);
    }
}