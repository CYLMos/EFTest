CREATE TABLE "School" (
  "Id" text PRIMARY KEY NOT NULL,
  "Name" text,
  "Address" text,
  "Phone" text
);

CREATE TABLE "Department" (
  "Id" text PRIMARY KEY NOT NULL,
  "Name" text,
  "Phone" text,
  "SchoolId" text
);

CREATE TABLE "Class" (
  "Id" text PRIMARY KEY NOT NULL,
  "Name" text,
  "SchoolId" text
);

CREATE TABLE "Staff" (
  "Id" text PRIMARY KEY NOT NULL,
  "Name" text,
  "Address" text,
  "Phone" text,
  "DepartmentId" text,
  "ClassId" text
);

CREATE TABLE "Student" (
  "Id" text PRIMARY KEY NOT NULL,
  "Name" text,
  "ClassId" text,
  "Address" text,
  "Phone" text
);

CREATE INDEX "IX_Department" ON "Department" ("SchoolId");

CREATE INDEX "IX_Class" ON "Class" ("SchoolId", "Name");

CREATE INDEX "IX_Staff" ON "Staff" ("DepartmentId", "ClassId", "Name");

CREATE INDEX "IX_Student" ON "Student" ("ClassId", "Name");

ALTER TABLE "Department" ADD FOREIGN KEY ("SchoolId") REFERENCES "School" ("Id");

ALTER TABLE "Class" ADD FOREIGN KEY ("SchoolId") REFERENCES "School" ("Id");

ALTER TABLE "Staff" ADD FOREIGN KEY ("ClassId") REFERENCES "Class" ("Id");

ALTER TABLE "Student" ADD FOREIGN KEY ("ClassId") REFERENCES "Class" ("Id");

ALTER TABLE "Staff" ADD FOREIGN KEY ("DepartmentId") REFERENCES "Department" ("Id");
