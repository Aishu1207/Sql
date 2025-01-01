create database Aishwarya;
use Aishwarya;
-- Student table
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE
);
-- Courses table
CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(50) NOT NULL,
    total_lectures INT NOT NULL
);
-- Lectures table
CREATE TABLE Lectures (
    lecture_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    lecture_date DATE,
    FOREIGN KEY (course_id)
        REFERENCES courses (course_id)
);

-- Attendance Table
CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    lecture_id INT,
    Status VARCHAR(10),
    FOREIGN KEY (student_id)
        REFERENCES students (student_id),
    FOREIGN KEY (lecture_id)
        REFERENCES lectures (lecture_id)
);
SELECT 
    *
FROM
    Students;
insert into Students values(1,'Aishwarya Darekar','aishu@gmail.com'),
(2,'Lavanya Darekar','lavanya@gmail.com'),(3,'Akshay Darekar','akshay@gmail.com'),(4,'Pranay Darekar','pranay@gmail.com'),
(5,'Swarupa Dhumal','swarupa@gmail.com'),(6,'Omkar Dhumal','omkar@gmail.com'),(7,'Ishwari Gurav','ishwari@gmail.com'),
(8,'Kranti Lad','kranti@gmail.com'),(9,'Tejas Malekar','tejas@gmail.com'),
(10,'Tejaswini Malekar','tejaswini@gmail.com'),(11,'Priya Gurav','priya@gmail.com'),
(12,'Pratiksha Dhumal','pratiksha@gmail.com'),(13,'Pinki Gurav','pinki@gmail.com'),
(14,'Anita Mhatre','anita@gmail.com'),(15,'Deepali Gurav','deepali@gmail.com'),(16,'Rupali Gurav','rupali@gmail.com'),
(17,'Shivam Dube','shivam@gmail.com'),(18,'Ravindra Jadeja','ravindra@gmail.com'),(19,'Virat Kolhi','virat@gmail.com'),
(20,'Rohit Sharma','rohit@gmail.com');

insert into Courses(course_name,total_lectures)values('SQL',22),('Python',30),('Java',20),('C++',15),('HTML',20);
SELECT 
    *
FROM
    Courses;

insert into Lectures(course_id,lecture_date) values(1,'2024-01-01'),(1,'2024-01-02'),(1,'2024-01-03'),
(2,'2024-01-04'),(2,'2024-01-05'),(2,'2024-01-06'),
(3,'2024-01-07'),(3,'2024-01-08'),(3,'2024-01-09'),
(4,'2024-01-10'),(4,'2024-01-11'),(4,'2024-01-12'),
(5,'2024-01-13'),(5,'2024-01-14'),(5,'2024-01-15');
SELECT 
    *
FROM
    Lectures;
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Present'),(1,1,27,'Absent'),(1,1,28,'Leave'),(1,1,29,'Partial'),
(2,2,30,'Present'),(2,2,31,'Absent'),(2,2,32,'Leave'),(2,2,33,'Partial'),
(3,3,34,'Present'),(3,4,35,'Absent'),(3,5,36,'Leave'),(3,6,37,'Partial'),
(4,4,38,'Present'),(4,5,39,'Absent'),(4,6,40,'Leave'),(4,7,26,'Partial'),
(5,5,27,'Present'),(5,6,28,'Absent'),(5,7,29,'Leave'),(5,8,30,'Partial'),
(6,6,31,'Present'),(6,7,32,'Absent'),(6,8,33,'Leave'),(6,9,34,'Partial'),
(7,7,35,'Present'),(7,8,36,'Absent'),(7,9,37,'Leave'),(7,10,38,'Partial'),
(8,8,39,'Present'),(8,9,40,'Absent'),(8,10,26,'Leave'),(8,11,27,'Partial'),
(9,9,28,'Present'),(9,10,29,'Absent'),(9,11,30,'Leave'),(9,12,31,'Partial'),
(10,10,32,'Present'),(10,11,33,'Absent'),(10,12,34,'Leave'),(10,13,35,'Partial'),
(11,11,36,'Present'),(11,12,37,'Absent'),(11,13,38,'Leave'),(11,14,39,'Partial');
SELECT 
    *
FROM
    Attendance;

-- Student with Highest absenteeism
drop procedure HighestAbsenteeism;
DELIMITER //
create procedure HighestAbsenteeism()
BEGIN
select student_id ,COUNT(*) 
AS Absence
from Attendance
where status='Absent'
group by student_id
order by Absence desc
limit 1;
end //
delimiter ;

call HighestAbsenteeism();

-- Given a student ID, what is his/her attendance (present) in each course.
Delimiter //
create procedure StudentAttendance(studentID int)
BEGIN
select course_id,COUNT(*) as 
present_days
from Attendance
where student_id = studentID and
status='Present'
group by course_id;
end //
delimiter ;

call StudentAttendance(3);

-- Generate a report for student showing the following as shown.
delimiter //
CREATE PROCEDURe report()
BEGIN
    DECLARE present_count INT;
    DECLARE absent_count INT;
    DECLARE leave_count INT;
     DECLARE total_count INT;
    DECLARE partial_count INT;
    SELECT 
        SUM(CASE WHEN Status = 'Present' THEN 1 ELSE 0 END),
        SUM(CASE WHEN Status = 'Absent' THEN 1 ELSE 0 END),
        SUM(CASE WHEN Status = 'Leave' THEN 1 ELSE 0 END),
        SUM(CASE WHEN Status = 'Partial' THEN 1 ELSE 0 END)
    INTO present_count, absent_count, leave_count, partial_count
    FROM Attendance;
    SET total_count = present_count + absent_count + leave_count + partial_count;
    SELECT 
        'Present' AS status,
        ROUND((present_count / total_count) * 100) AS percentage
    UNION ALL
    SELECT 
        'Absent' AS status,
        ROUND((absent_count / total_count) * 100) AS percentage
    UNION ALL
    SELECT 
        'Leave' AS status,
        ROUND((leave_count / total_count) * 100) AS percentage
    UNION ALL
    SELECT 
        'Partial' AS status,
        ROUND((partial_count / total_count) * 100) AS percentage;
END //
delimiter ;
call report();
-- Generate a course wise report for any month. A course wise report contains the following
-- a. Course name
-- b. Lectures required
-- c. Lectures completed
-- d. Lectures remaining

Delimiter //
CREATE PROCEDURE ReportForMonth(reportMonth INT, reportYear INT)
BEGIN
    SELECT c.course_name,
           c.total_lectures,
           COUNT(l.lecture_id) AS lectures_completed,
           (c.total_lectures - COUNT(l.lecture_id)) AS lectures_remaining
    FROM courses c
    JOIN lectures l ON c.course_id = l.course_id
    WHERE MONTH(l.lecture_date) = reportMonth AND YEAR(l.lecture_date) = reportYear
    GROUP BY c.course_id;
END //
delimiter ;
call ReportForMonth(1,2024);

-- Create a TRIGGER that ensures that any student who has more than 50% absenteeism after 10 lectures will not be allowed to attend the module, i.e., prevent the attendance of that student from being marked.
DELIMITER //
CREATE TRIGGER PreventHighAbsenteeism
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
    DECLARE total_lectures INT;
    DECLARE absent_lectures INT;
    DECLARE absenteeism_ratio FLOAT;
    SELECT COUNT(*)
    INTO total_lectures
    FROM attendance
    WHERE student_id = NEW.student_id
      AND course_id = NEW.course_id;
 IF total_lectures >= 10 THEN
        SELECT COUNT(*)
        INTO absent_lectures
        FROM attendance
        WHERE student_id = NEW.student_id
          AND course_id = NEW.course_id
          AND status = 'Absent';
        SET absenteeism_ratio = absent_lectures / total_lectures;
        IF absenteeism_ratio > 0.5 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot mark attendance: absenteeism exceeds 50% after 10 lectures';
        END IF;
    END IF;
END //
DELIMITER ;
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Absent');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Absent');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Absent');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Absent');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Present');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Present');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Present');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Present');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Present');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Present');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Present');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Absent');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Absent');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Absent');
insert into Attendance(student_id,course_id,lecture_id,status)values(1,1,26,'Absent');

