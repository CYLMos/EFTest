using System.ComponentModel.DataAnnotations.Schema;

namespace EFTest.Models
{
    [Table("Student")]
    public class Student
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string Address { get; set; }

        public string Phone { get; set; }

        public string ClassId { get; set; }
    }
}
