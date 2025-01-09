namespace EFTest.Models
{
    public class School
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string Address { get; set; }

        public string Phone { get; set; }

        public List<Department> Departments { get; set; }

        public List<Class> Classes { get; set; }
    }
}
