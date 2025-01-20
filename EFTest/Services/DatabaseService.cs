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
                }

                await connection.CloseAsync();
            }
        }
    }
}
