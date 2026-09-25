CREATE TABLE departments (
    id          integer         PRIMARY KEY,
    name        varchar(250),
    budget      integer,

    constraint uq_department_name UNIQUE (name),
    constraint chk_departments_budget CHECK (budget > 0)
);

CREATE TABLE teachers (
    id            integer       PRIMARY KEY,
    email         varchar(250)  NOT NULL,
    rate          numeric(3,2)  NOT NULL,
    department_id integer       NOT NULL,

    constraint uq_teachers_email UNIQUE (email),
    constraint chk_teachers_rate CHECK (rate IN (0.25,0.50,0.75,1.00))
);

CREATE TABLE badges (
    id           integer      PRIMARY KEY,
    number       integer      NOT NULL,
    issue_date   date         NOT NULL      DEFAULT NOW(),
    teacher_id   integer      NOT NULL,

    constraint uq_badges_number UNIQUE (number),
    constraint uq_badges_teacherId UNIQUE (teacher_id)
);

CREATE TABLE students (
    id      integer         PRIMARY KEY,
    email   varchar(250)    NOT NULL,
    age     integer         NOT NULL,

    constraint uq_students_email UNIQUE(email),
    CONSTRAINT chk_student_email CHECK (email LIKE '%_@_%.__%'),
    constraint chk_students_age CHECK (age BETWEEN 16 AND 80)
);

CREATE TABLE tracks (
    id      integer         PRIMARY KEY,
    name    varchar(250)    NOT NULL,
    hours   integer         NOT NULL,

    constraint uq_tracks_name UNIQUE(name),
    constraint chk_track_hours CHECK (hours > 0)
);

CREATE TABLE enrollments (
    student_id      integer,
    track_id        integer,
    grade           integer, 
    PRIMARY KEY (student_id, track_id),

    constraint chk_enrollments_grade CHECK (grade BETWEEN 0 and 100)
);

-- 1 кафедра много учителей
ALTER TABLE teachers ADD FOREIGN KEY (department_id) REFERENCES departments (id) DEFERRABLE INITIALLY IMMEDIATE;
-- 1 пропуск 1 учитель
ALTER TABLE badges ADD FOREIGN KEY (teacher_id) REFERENCES teachers (id) DEFERRABLE INITIALLY IMMEDIATE;

-- многие ко многим
-- 1 ученик много предметов
ALTER TABLE enrollments ADD FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY IMMEDIATE;
-- 1 предмет много учеников
ALTER TABLE enrollments ADD FOREIGN KEY (track_id) REFERENCES tracks (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY IMMEDIATE;