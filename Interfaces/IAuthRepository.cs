using PetShop.Models;

namespace PetShop.Interfaces
{
    public interface IAuthRepository
    {
        Task<Customer?> GetCustomerByEmailAsync(string email, CancellationToken ct = default);
        Task<Staff?> GetStaffByEmailAsync(string email, CancellationToken ct = default);
        Task<Doctor?> GetDoctorByEmailAsync(string email, CancellationToken ct = default);
        Task<Admin?> GetAdminByEmailOrUsernameAsync(string input, CancellationToken ct = default);
        Task<bool> EmailExistsInAnyRoleAsync(string email, CancellationToken ct = default);
        Task<Customer> CreateCustomerAsync(Customer customer, CancellationToken ct = default);
        Task UpdateCustomerAsync(Customer customer, CancellationToken ct = default);
    }
}
