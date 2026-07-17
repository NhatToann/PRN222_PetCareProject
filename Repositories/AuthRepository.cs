using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Repositories
{
    public sealed class AuthRepository : IAuthRepository
    {
        private readonly ShopPetDatabaseContext _db;

        public AuthRepository(ShopPetDatabaseContext db)
        {
            _db = db;
        }

        public Task<Customer?> GetCustomerByEmailAsync(string email, CancellationToken ct = default)
        {
            var normalizedEmail = NormalizeEmail(email);

            return _db.Customers
                .FirstOrDefaultAsync(x => (x.Email ?? string.Empty).Trim().ToLower() == normalizedEmail, ct);
        }

        public Task<Staff?> GetStaffByEmailAsync(string email, CancellationToken ct = default)
        {
            var normalizedEmail = NormalizeEmail(email);

            return _db.Staff
                .FirstOrDefaultAsync(x => (x.Email ?? string.Empty).Trim().ToLower() == normalizedEmail, ct);
        }

        public Task<Doctor?> GetDoctorByEmailAsync(string email, CancellationToken ct = default)
        {
            var normalizedEmail = NormalizeEmail(email);

            return _db.Doctors
                .FirstOrDefaultAsync(x => (x.Email ?? string.Empty).Trim().ToLower() == normalizedEmail, ct);
        }

        public Task<Admin?> GetAdminByEmailOrUsernameAsync(string input, CancellationToken ct = default)
        {
            var normalizedInput = NormalizeEmail(input);

            return _db.Admins
                .FirstOrDefaultAsync(x =>
                    (x.Email ?? string.Empty).Trim().ToLower() == normalizedInput
                    || x.Username.Trim().ToLower() == normalizedInput,
                    ct);
        }

        public async Task<Customer> CreateCustomerAsync(Customer customer, CancellationToken ct = default)
        {
            await _db.Customers.AddAsync(customer, ct);
            await _db.SaveChangesAsync(ct);
            return customer;
        }

        public async Task UpdateCustomerAsync(Customer customer, CancellationToken ct = default)
        {
            _db.Customers.Update(customer);
            await _db.SaveChangesAsync(ct);
        }

        public async Task<bool> EmailExistsInAnyRoleAsync(string email, CancellationToken ct = default)
        {
            var normalizedEmail = NormalizeEmail(email);

            return await _db.Customers.AnyAsync(x => (x.Email ?? string.Empty).Trim().ToLower() == normalizedEmail, ct)
                || await _db.Staff.AnyAsync(x => (x.Email ?? string.Empty).Trim().ToLower() == normalizedEmail, ct)
                || await _db.Doctors.AnyAsync(x => (x.Email ?? string.Empty).Trim().ToLower() == normalizedEmail, ct)
                || await _db.Admins.AnyAsync(x => (x.Email ?? string.Empty).Trim().ToLower() == normalizedEmail, ct)
                || await _db.Admins.AnyAsync(x => x.Username.Trim().ToLower() == normalizedEmail, ct);
        }

        private static string NormalizeEmail(string input)
        {
            return (input ?? string.Empty).Trim().ToLowerInvariant();
        }
    }
}
