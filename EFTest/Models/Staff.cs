using System.ComponentModel.DataAnnotations.Schema;

namespace EFTest.Models
{
    [Table("Staff")]
    public class Staff
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string Address { get; set; }

        public string Phone { get; set; }

        public string DepartmentId { get; set; }

        public string ClassId { get; set; }
    }
}
