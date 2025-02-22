CREATE TABLE "DummyCount" (
  "Id" integer PRIMARY KEY NOT NULL,
  "SchoolCount" integer,
  "DepartmentCount" integer,
  "ClassCount" integer,
  "StaffCount" integer,
  "TeacherCount" integer,
  "StudentCount" integer
);

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
  "DepartmentId" text
);

CREATE TABLE "Teacher" (
  "Id" text PRIMARY KEY NOT NULL,
  "Name" text,
  "Address" text,
  "Phone" text,
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

CREATE INDEX "IX_Staff" ON "Staff" ("DepartmentId", "Name");

CREATE INDEX "IX_Teacher" ON "Teacher" ("ClassId", "Name");

CREATE INDEX "IX_Student" ON "Student" ("ClassId", "Name");

ALTER TABLE "Department" ADD FOREIGN KEY ("SchoolId") REFERENCES "School" ("Id");

ALTER TABLE "Class" ADD FOREIGN KEY ("SchoolId") REFERENCES "School" ("Id");

ALTER TABLE "Teacher" ADD FOREIGN KEY ("ClassId") REFERENCES "Class" ("Id");

ALTER TABLE "Student" ADD FOREIGN KEY ("ClassId") REFERENCES "Class" ("Id");

ALTER TABLE "Staff" ADD FOREIGN KEY ("DepartmentId") REFERENCES "Department" ("Id");

/* Generate All Dummy Data Func */
CREATE OR REPLACE FUNCTION generate_dummy_data()
	RETURNS TRIGGER AS
$$
BEGIN
	TRUNCATE TABLE "School" CASCADE;

	PERFORM generate_school_dummy();
	PERFORM generate_department_dummy();
	PERFORM generate_class_dummy();
	PERFORM generate_staff_dummy();
	PERFORM generate_teacher_dummy();
	PERFORM generate_student_dummy();
		
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/* Generate School Dummy Data Func */
CREATE OR REPLACE FUNCTION generate_school_dummy()
	RETURNS text AS
$$
DECLARE school_count int := (
	SELECT DC."SchoolCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
BEGIN
	IF(school_count > 0) THEN
		WITH
			SCHOOLID AS (
				SELECT
					GEN_RANDOM_UUID () AS "Id"
				FROM
					GENERATE_SERIES(1, school_count) AS gs
			)
		INSERT INTO "School" ("Id", "Name", "Address", "Phone")
		SELECT
			SI."Id",
			SUBSTRING(SI."Id"::TEXT, 1, 6),
			'It is ' || SUBSTRING(SI."Id"::TEXT, 1, 6) || 's Address',
			'It is ' || SUBSTRING(SI."Id"::TEXT, 1, 6) || 's Phone'
		FROM
			SCHOOLID SI;
	END IF;
		
	RETURN 'Success';
END;
$$ LANGUAGE plpgsql;

/* Generate Department Dummy Data */
CREATE OR REPLACE FUNCTION generate_department_dummy()
	RETURNS text AS
$$
DECLARE department_count int := (
	SELECT DC."DepartmentCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
DECLARE school_count int := (
	SELECT DC."SchoolCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
BEGIN
	IF(department_count > 0 AND school_count > 0) THEN
		WITH
			SIDTABLE AS (
				SELECT 
					S."Id" AS "SchoolId",
					ROW_NUMBER() OVER () AS "Id"
				FROM "School" S, GENERATE_SERIES(1, department_count / school_count)
				ORDER BY RANDOM() 
			),
			DIDTABLE AS (
				SELECT
					gs."gs" AS "Id",
					GEN_RANDOM_UUID () AS "DepartmentId"
				FROM
					GENERATE_SERIES(1, department_count) gs
			),
			IDTABLE AS (
				SELECT 
					DIT."DepartmentId", SIT."SchoolId"
				FROM
					DIDTABLE DIT
				INNER JOIN SIDTABLE SIT
				ON DIT."Id" = SIT."Id"
			),
			INSERTTABLE AS (
				SELECT
					IT."DepartmentId" AS "Id",
					IT."SchoolId" AS "SchoolId",
					SUBSTRING(IT."DepartmentId"::TEXT, 1, 6) AS "Name",
					'It is ' || SUBSTRING(IT."DepartmentId"::TEXT, 1, 6) || 's Phone' AS "Phone"
				FROM
					IDTABLE IT
			)
		INSERT INTO "Department" ("Id", "Name", "Phone", "SchoolId")
		SELECT
			IT."Id",
			IT."Name",
			IT."Phone",
			IT."SchoolId"
		FROM
			INSERTTABLE IT;
	END IF;
		
	RETURN 'Success';
END;
$$ LANGUAGE plpgsql;

/* Generate Class Dummy Data */
CREATE OR REPLACE FUNCTION generate_class_dummy()
	RETURNS text AS
$$
DECLARE class_count int := (
	SELECT DC."ClassCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
DECLARE school_count int := (
	SELECT DC."SchoolCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
BEGIN
	IF(class_count > 0 AND school_count > 0) THEN
		WITH
			SIDTABLE AS (
				SELECT 
					S."Id" AS "SchoolId",
					ROW_NUMBER() OVER () AS "Id"
				FROM "School" S, GENERATE_SERIES(1, class_count / school_count)
				ORDER BY RANDOM() 
			),
			CIDTABLE AS (
				SELECT
					gs."gs" AS "Id",
					GEN_RANDOM_UUID () AS "ClassId"
				FROM
					GENERATE_SERIES(1, class_count) gs
			),
			IDTABLE AS (
				SELECT 
					CIT."ClassId", SIT."SchoolId"
				FROM
					CIDTABLE CIT
				INNER JOIN SIDTABLE SIT
				ON CIT."Id" = SIT."Id"
			),
			INSERTTABLE AS (
				SELECT
					IT."ClassId" AS "Id",
					IT."SchoolId" AS "SchoolId",
					SUBSTRING(IT."ClassId"::TEXT, 1, 6) AS "Name"
				FROM
					IDTABLE IT
			)
		INSERT INTO "Class" ("Id", "Name", "SchoolId")
		SELECT
			IT."Id",
			IT."Name",
			IT."SchoolId"
		FROM
			INSERTTABLE IT;
	END IF;
		
	RETURN 'Success';
END;
$$ LANGUAGE plpgsql;

/* Generate Staff Dummy Data */
CREATE OR REPLACE FUNCTION generate_staff_dummy()
	RETURNS text AS
$$
DECLARE staff_count int := (
	SELECT DC."StaffCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
DECLARE department_count int := (
	SELECT DC."DepartmentCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
BEGIN
	IF(staff_count > 0 AND department_count > 0) THEN
		WITH
			DIDTABLE AS (
				SELECT 
					D."Id" AS "DepartmentId",
					ROW_NUMBER() OVER () AS "Id"
				FROM "Department" D, GENERATE_SERIES(1, staff_count / department_count)
				ORDER BY RANDOM() 
			),
			SIDTABLE AS (
				SELECT
					gs."gs" AS "Id",
					GEN_RANDOM_UUID () AS "StaffId"
				FROM
					GENERATE_SERIES(1, staff_count) gs
			),
			IDTABLE AS (
				SELECT 
					SIT."StaffId", DIT."DepartmentId"
				FROM
					SIDTABLE SIT
				INNER JOIN DIDTABLE DIT
				ON SIT."Id" = DIT."Id"
			),
			INSERTTABLE AS (
				SELECT
					IT."StaffId" AS "Id",
					IT."DepartmentId" AS "DepartmentId",
					SUBSTRING(IT."StaffId"::TEXT, 1, 6) AS "Name",
					'It is ' || SUBSTRING(IT."StaffId"::TEXT, 1, 6) || 's Address' AS "Address",
					'It is ' || SUBSTRING(IT."StaffId"::TEXT, 1, 6) || 's Phone' AS "Phone"
				FROM
					IDTABLE IT
			)
		INSERT INTO "Staff" ("Id", "Name", "DepartmentId", "Address", "Phone")
		SELECT
			IT."Id",
			IT."Name",
			IT."DepartmentId",
			IT."Address",
			IT."Phone"
		FROM
			INSERTTABLE IT;
	END IF;
		
	RETURN 'Success';
END;
$$ LANGUAGE plpgsql;

/* Generate Teacher Dummy Data */
CREATE OR REPLACE FUNCTION generate_teacher_dummy()
	RETURNS text AS
$$
DECLARE teacher_count int := (
	SELECT DC."TeacherCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
DECLARE class_count int := (
	SELECT DC."ClassCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
BEGIN
	IF(teacher_count > 0 AND class_count > 0) THEN
		WITH
			CIDTABLE AS (
				SELECT 
					C."Id" AS "ClassId",
					ROW_NUMBER() OVER () AS "Id"
				FROM "Class" C, GENERATE_SERIES(1, teacher_count / class_count)
				ORDER BY RANDOM() 
			),
			TIDTABLE AS (
				SELECT
					gs."gs" AS "Id",
					GEN_RANDOM_UUID () AS "TeacherId"
				FROM
					GENERATE_SERIES(1, teacher_count) gs
			),
			IDTABLE AS (
				SELECT 
					TIT."TeacherId", CIT."ClassId"
				FROM
					TIDTABLE TIT
				INNER JOIN CIDTABLE CIT
				ON TIT."Id" = CIT."Id"
			),
			INSERTTABLE AS (
				SELECT
					IT."TeacherId" AS "Id",
					IT."ClassId" AS "ClassId",
					SUBSTRING(IT."TeacherId"::TEXT, 1, 6) AS "Name",
					'It is ' || SUBSTRING(IT."TeacherId"::TEXT, 1, 6) || 's Address' AS "Address",
					'It is ' || SUBSTRING(IT."TeacherId"::TEXT, 1, 6) || 's Phone' AS "Phone"
				FROM
					IDTABLE IT
			)
		INSERT INTO "Teacher" ("Id", "Name", "ClassId", "Address", "Phone")
		SELECT
			IT."Id",
			IT."Name",
			IT."ClassId",
			IT."Address",
			IT."Phone"
		FROM
			INSERTTABLE IT;
	END IF;
		
	RETURN 'Success';
END;
$$ LANGUAGE plpgsql;

/* Generate Student Dummy Data */
CREATE OR REPLACE FUNCTION generate_student_dummy()
	RETURNS text AS
$$
DECLARE student_count int := (
	SELECT DC."StudentCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
DECLARE class_count int := (
	SELECT DC."ClassCount"
	FROM "DummyCount" DC
	ORDER BY "Id" ASC
	LIMIT 1
);
BEGIN
	IF(student_count > 0 AND class_count > 0) THEN
		WITH
			CIDTABLE AS (
				SELECT 
					C."Id" AS "ClassId",
					ROW_NUMBER() OVER () AS "Id"
				FROM "Class" C, GENERATE_SERIES(1, student_count / class_count)
				ORDER BY RANDOM() 
			),
			SIDTABLE AS (
				SELECT
					gs."gs" AS "Id",
					GEN_RANDOM_UUID () AS "StudentId"
				FROM
					GENERATE_SERIES(1, student_count) gs
			),
			IDTABLE AS (
				SELECT 
					SIT."StudentId", CIT."ClassId"
				FROM
					SIDTABLE SIT
				INNER JOIN CIDTABLE CIT
				ON SIT."Id" = CIT."Id"
			),
			INSERTTABLE AS (
				SELECT
					IT."StudentId" AS "Id",
					IT."ClassId" AS "ClassId",
					SUBSTRING(IT."StudentId"::TEXT, 1, 6) AS "Name",
					'It is ' || SUBSTRING(IT."StudentId"::TEXT, 1, 6) || 's Address' AS "Address",
					'It is ' || SUBSTRING(IT."StudentId"::TEXT, 1, 6) || 's Phone' AS "Phone"
				FROM
					IDTABLE IT
			)
		INSERT INTO "Student" ("Id", "Name", "ClassId", "Address", "Phone")
		SELECT
			IT."Id",
			IT."Name",
			IT."ClassId",
			IT."Address",
			IT."Phone"
		FROM
			INSERTTABLE IT;
	END IF;
		
	RETURN 'Success';
END;
$$ LANGUAGE plpgsql;

/* Dummy Data Trigger */
CREATE OR REPLACE TRIGGER SCHOOL_DUMMY_TRIGGER
AFTER INSERT OR UPDATE
ON "DummyCount"
FOR EACH STATEMENT
EXECUTE PROCEDURE generate_dummy_data();