using EFTest.Models;
using Microsoft.AspNetCore.Mvc;
namespace EFTest.Controllers
{
    [ApiController]
    public class DatabaseController : ControllerBase
    {
        private readonly SchoolContext _context;

        public DatabaseController(SchoolContext context)
        {
            _context = context;
        }

        [Route("/school/add/{name}")]
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
    }
}
