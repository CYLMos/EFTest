using System.ComponentModel.DataAnnotations.Schema;

namespace EFTest.Models
{
    [Table("Department")]
    public class Department
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string Phone { get; set; }

        public string SchoolId { get; set; }

        public List<Staff> Staffs { get; set; } = new List<Staff>();
    }
}
