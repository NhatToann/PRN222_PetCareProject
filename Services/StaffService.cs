using PetShop.Interfaces;
using PetShop.Models;

namespace PetShop.Services
{
    public class StaffService : IStaffService
    {
        private readonly IStaffRepository _staffRepository;

        public StaffService(IStaffRepository staffRepository)
        {
            _staffRepository = staffRepository;
        }

        public async Task<IEnumerable<StaffDto>> GetAllStaffsAsync()
        {
            var staffs = await _staffRepository.GetAllAsync();
            return staffs.Select(s => new StaffDto
            {
                StaffId = s.StaffId,
                // FIX: Dùng ?? string.Empty để triệt tiêu cảnh báo Possible null reference
                Name = s.Name ?? string.Empty,
                Phone = s.Phone ?? string.Empty,
                Email = s.Email ?? string.Empty,
                Position = s.Position ?? string.Empty
            });
        }

        public async Task<StaffDto?> GetStaffByIdAsync(int id)
        {
            var s = await _staffRepository.GetByIdAsync(id);
            if (s == null) return null;

            return new StaffDto
            {
                StaffId = s.StaffId,
                Name = s.Name ?? string.Empty,
                Phone = s.Phone ?? string.Empty,
                Email = s.Email ?? string.Empty,
                Position = s.Position ?? string.Empty
            };
        }

        public async Task<StaffDto> CreateStaffAsync(StaffCreateUpdateDto dto)
        {
            var staff = new Staff
            {
                Name = dto.Name,
                Phone = dto.Phone,
                Email = dto.Email,
                Password = dto.Password,
                Position = dto.Position
            };

            var createdStaff = await _staffRepository.AddAsync(staff);

            return new StaffDto
            {
                StaffId = createdStaff.StaffId,
                Name = createdStaff.Name ?? string.Empty,
                Phone = createdStaff.Phone ?? string.Empty,
                Email = createdStaff.Email ?? string.Empty,
                Position = createdStaff.Position ?? string.Empty
            };
        }

        public async Task<bool> UpdateStaffAsync(int id, StaffCreateUpdateDto dto)
        {
            var staff = await _staffRepository.GetByIdAsync(id);
            if (staff == null) return false;

            staff.Name = dto.Name;
            staff.Phone = dto.Phone;
            staff.Email = dto.Email;
            staff.Position = dto.Position;

            if (!string.IsNullOrWhiteSpace(dto.Password))
            {
                staff.Password = dto.Password;
            }

            await _staffRepository.UpdateAsync(staff);
            return true;
        }

        public async Task<bool> DeleteStaffAsync(int id)
        {
            var staff = await _staffRepository.GetByIdAsync(id);
            if (staff == null) return false;

            await _staffRepository.DeleteAsync(staff);
            return true;
        }
    }
}