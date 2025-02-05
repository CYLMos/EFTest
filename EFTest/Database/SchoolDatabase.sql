CREATE TABLE "DummyCount" (
  "Id" integer PRIMARY KEY NOT NULL,
  "SchoolCount" integer,
  "DepartmentCount" integer,
  "ClassCount" integer,
  "StaffCount" integer,
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

/* Generate All Dummy Data Func */
CREATE OR REPLACE FUNCTION generate_dummy_data()
	RETURNS TRIGGER AS
$$
BEGIN
	TRUNCATE TABLE "School" CASCADE;

	PERFORM generate_school_dummy();
	PERFORM generate_department_dummy();
		
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

/* Dummy Data Trigger */
CREATE OR REPLACE TRIGGER SCHOOL_DUMMY_TRIGGER
AFTER INSERT OR UPDATE
ON "DummyCount"
FOR EACH STATEMENT
EXECUTE PROCEDURE generate_dummy_data();