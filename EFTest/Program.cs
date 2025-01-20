using EFTest.Models;
using EFTest.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContextPool<SchoolContext>(opt =>
    opt.UseNpgsql(
        builder.Configuration.GetConnectionString("PostgresDatabase"),
        o => o
            .SetPostgresVersion(16, 0)
            .UseNodaTime()));

var dbService = new DatabaseService(
    builder.Configuration.GetSection("AppSettings").GetValue<bool>("HasInitData"),
    builder.Configuration.GetSection("AppSettings").GetValue<int>("InitDataCount"),
    builder.Configuration.GetConnectionString("PostgresDatabase") ?? "");
await dbService.Initialization();

builder.Services.AddSingleton<DatabaseService>(dbService);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
