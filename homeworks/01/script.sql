CREATE TABLE departments (
    id     integer PRIMARY KEY,
    name   varchar(250) UNIQUE,
    budget integer CHECK (budget > 0)
);

CREATE TABLE teachers (
    id            integer PRIMARY KEY,
    email         varchar(250) UNIQUE,
    rate          numeric(3,2) NOT NULL CHECK (rate IN (0.25, 0.50, 0.75, 1.00)),
    department_id integer NOT NULL
);

CREATE TABLE badges (
    id         integer PRIMARY KEY,
    number     integer UNIQUE NOT NULL,
    issue_date date NOT NULL,
    teacher_id integer NOT NULL UNIQUE
);

CREATE TABLE students (
    id    integer PRIMARY KEY,
    email varchar(250) UNIQUE,
    age   integer NOT NULL CHECK (age BETWEEN 16 AND 80)
);

CREATE TABLE tracks (
    id    integer PRIMARY KEY,
    name  varchar(250) UNIQUE NOT NULL,
    hours integer NOT NULL CHECK (hours > 0)
);

CREATE TABLE enrollments (
    student_id integer,
    track_id   integer,
    grade      integer CHECK (grade BETWEEN 0 AND 100), 
    PRIMARY KEY (student_id, track_id)
);

ALTER TABLE teachers ADD FOREIGN KEY (department_id) REFERENCES departments (id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE badges ADD FOREIGN KEY (teacher_id) REFERENCES teachers (id) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE enrollments ADD FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE enrollments ADD FOREIGN KEY (track_id) REFERENCES tracks (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY IMMEDIATE;