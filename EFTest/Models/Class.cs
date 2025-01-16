using System.ComponentModel.DataAnnotations.Schema;

namespace EFTest.Models
{
    [Table("Class")]
    public class Class
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string SchoolId { get; set; }

        public List<Staff> Staffs { get; set; } = new List<Staff>();

        public List<Student> Students { get; set; } = new List<Student>();
    }
}
