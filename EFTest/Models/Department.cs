using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace EFTest.Models
{
    [Table("Department")]
    public class Department
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string Phone { get; set; }

        public string SchoolId { get; set; }

        [JsonIgnore]
        public List<Staff> Staffs { get; set; } = new List<Staff>();
    }
}
