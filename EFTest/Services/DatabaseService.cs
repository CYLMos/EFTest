using EFTest.Models;
using Microsoft.Data.SqlClient;
using Npgsql;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace EFTest.Services
{
    public class DatabaseService
    {
        private readonly bool _hasInitData = false;
        private readonly int _InitDataCount = 0;
        private readonly string _connectionString;

        public DatabaseService(bool hasInitData, int initDataCount, string connectionString)
        {
            _hasInitData = hasInitData;
            _InitDataCount = initDataCount;
            _connectionString = connectionString;
        }

        public async Task Initialization()
        {
            if (!_hasInitData || _InitDataCount <= 0) return;

            using (var connection = new NpgsqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                var emptyCommand = new NpgsqlCommand("TRUNCATE TABLE \"School\" CASCADE", connection);
                emptyCommand.Parameters.Clear();
                await emptyCommand.ExecuteNonQueryAsync();

                var schoolIds = await InitSchool(connection);
                var departmentIds = await InitDepartment(connection, schoolIds);

                await connection.CloseAsync();
            }
        }

        private async Task<List<string>> InitSchool(NpgsqlConnection connection)
        {
            var ids = new List<string>();
            for (var i = 0; i < _InitDataCount; i++)
            {
                var command = new NpgsqlCommand(
                    "INSERT INTO \"School\" (\"Id\", \"Name\", \"Address\", \"Phone\") VALUES (@Id, @Name, @Address, @Phone);",
                    connection);

                var id = $"{Guid.NewGuid()}";
                var shortId = id.Substring(0, 6);
                var school = new School()
                {
                    Id = id,
                    Name = shortId,
                    Address = $"Address_{shortId}",
                    Phone = $"Phone_{shortId}"
                };

                command.Parameters.Clear();
                command.Parameters.AddWithValue("@Id", school.Id);
                command.Parameters.AddWithValue("@Name", school.Name);
                command.Parameters.AddWithValue("@Address", school.Phone);
                command.Parameters.AddWithValue("@Phone", school.Phone);

                await command.ExecuteNonQueryAsync();
                ids.Add(id);
            }

            return ids;
        }

        private async Task<List<string>> InitDepartment(NpgsqlConnection connection, List<string> schoolIds)
        {
            var ids = new List<string>();
            var rnd = new Random();
            for (var i = 0; i < _InitDataCount; i++)
            {
                var command = new NpgsqlCommand(
                    "INSERT INTO \"Department\" (\"Id\", \"Name\", \"SchoolId\", \"Phone\") VALUES (@Id, @Name, @SchoolId, @Phone);",
                    connection);

                var schoolId = schoolIds[rnd.Next(0, _InitDataCount)];
                var id = $"{Guid.NewGuid()}";
                var shortId = id.Substring(0, 6);
                var department = new Department()
                {
                    Id = id,
                    Name = shortId,
                    SchoolId = schoolId,
                    Phone = $"Phone_{shortId}"
                };

                command.Parameters.Clear();
                command.Parameters.AddWithValue("@Id", department.Id);
                command.Parameters.AddWithValue("@Name", department.Name);
                command.Parameters.AddWithValue("@SchoolId", department.SchoolId);
                command.Parameters.AddWithValue("@Phone", department.Phone);

                await command.ExecuteNonQueryAsync();
                ids.Add(id);
            }

            return ids;
        }
    }
}
