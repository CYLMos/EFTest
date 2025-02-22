﻿using Microsoft.EntityFrameworkCore;

namespace EFTest.Models
{
    public class SchoolContext : DbContext
    {
        public DbSet<School> Schools { get; set; }
        public DbSet<Department> Departments { get; set; }
        public DbSet<Class> Classes { get; set; }
        public DbSet<Student> Students { get; set; }
        public DbSet<Staff> Staffs { get; set; }

        public SchoolContext(DbContextOptions<SchoolContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<School>().HasKey(e => e.Id);

            modelBuilder.Entity<School>()
                .HasMany(e => e.Departments)
                .WithOne()
                .HasForeignKey(e => e.SchoolId)
                .IsRequired();

            modelBuilder.Entity<School>()
                .HasMany(e => e.Classes)
                .WithOne()
                .HasForeignKey(e => e.SchoolId)
                .IsRequired();

            modelBuilder.Entity<Department>()
                .HasMany(e => e.Staffs)
                .WithOne()
                .HasForeignKey(e => e.DepartmentId)
                .IsRequired();

            modelBuilder.Entity<Department>()
                .HasIndex(e => e.SchoolId);

            modelBuilder.Entity<Class>()
                .HasMany(e => e.Staffs)
                .WithOne()
                .HasForeignKey(e => e.ClassId)
                .IsRequired();

            modelBuilder.Entity<Class>()
                .HasMany(e => e.Students)
                .WithOne()
                .HasForeignKey(e => e.ClassId)
                .IsRequired();

            modelBuilder.Entity<Class>()
                .HasIndex(e => new { e.SchoolId, e.Name });

            modelBuilder.Entity<Staff>()
                .HasIndex(e => new { e.DepartmentId, e.ClassId, e.Name });

            modelBuilder.Entity<Student>()
                .HasIndex(e => new { e.ClassId, e.Name });

            base.OnModelCreating(modelBuilder);
        }
    }
}
