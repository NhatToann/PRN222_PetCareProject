using Microsoft.EntityFrameworkCore;
using PetShop.Data;
using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Repositories
{
    public class StaffRepository : IStaffRepository
    {
        private readonly ShopPetDatabaseContext _context;

        public StaffRepository(ShopPetDatabaseContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Staff>> GetAllAsync()
        {
            return await _context.Staff.ToListAsync();
        }

        public async Task<Staff?> GetByIdAsync(int id)
        {
            return await _context.Staff.FindAsync(id);
        }

        public async Task<Staff> AddAsync(Staff staff)
        {
            _context.Staff.Add(staff);
            await _context.SaveChangesAsync();
            return staff;
        }

        public async Task UpdateAsync(Staff staff)
        {
            _context.Staff.Update(staff);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Staff staff)
        {
            _context.Staff.Remove(staff);
            await _context.SaveChangesAsync();
        }
    }
}