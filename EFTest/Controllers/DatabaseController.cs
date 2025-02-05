using EFTest.Models;
using Microsoft.AspNetCore.Mvc;
namespace EFTest.Controllers
{
    [ApiController]
    public class DatabaseController : ControllerBase
    {
        private readonly SchoolContext _context;

        public DatabaseController(SchoolContext context)
            => _context = context;

        [Route("/school/add/{name}")]
        [HttpGet]
        [HttpPost]
        public async Task<School> AddSchool(string name)
        {
            var school = new School
            {
                Id = $"{Guid.NewGuid()}",
                Name = name,
                Address = $"{name}'s Address",
                Phone = $"{name}'s Phone"
            };

            _context.Schools.Add(school);
            await _context.SaveChangesAsync();

            return school;
        }

        [Route("/school/search/name/{name}")]
        [HttpGet]
        public School SearchSchoolByName(string name)
            => _context.Schools.FirstOrDefault(s => s.Name == name) ?? new School();

        [Route("/school/search/id/{id}")]
        [HttpGet]
        public School SearchSchoolById(string id)
            => _context.Schools.FirstOrDefault(s => s.Id == id) ?? new School();

        [Route("/department/add")]
        [HttpPost]
        public async Task<Department> AddDepartment(string name, string schoolId)
        {
            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(schoolId))
                return null!;

            var department = new Department
            {
                Id = $"{Guid.NewGuid()}",
                Name = name,
                Phone = $"{name}'s Phone",
                SchoolId = schoolId
            };

            _context.Departments.Add(department);
            await _context.SaveChangesAsync();

            return department;
        }

        [Route("/department/search/name/{name}")]
        [HttpGet]
        public Department SearchDepartmentByName(string name)
            => _context.Departments.FirstOrDefault(s => s.Name == name) ?? new Department();

        [Route("/department/search/id/{id}")]
        [HttpGet]
        public Department SearchDepartmentById(string id)
            => _context.Departments.FirstOrDefault(s => s.Id == id) ?? new Department();
    }
}
