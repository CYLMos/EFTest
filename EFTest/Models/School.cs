using System.ComponentModel.DataAnnotations.Schema;

namespace EFTest.Models
{
    [Table("School")]
    public class School
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string Address { get; set; }

        public string Phone { get; set; }

        public List<Department> Departments { get; set; } = new List<Department>();

        public List<Class> Classes { get; set; } = new List<Class>();
    }
}
