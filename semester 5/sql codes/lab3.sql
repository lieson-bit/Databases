CREATE database lab3;
use lab3;
SET SQL_SAFE_UPDATES = 0;

CREATE TABLE IF NOT EXISTS City (
  id_city INT NOT NULL AUTO_INCREMENT,
  name_city VARCHAR(20) NOT NULL,
  status VARCHAR(20),
  PRIMARY KEY (id_city)
);

CREATE TABLE IF NOT EXISTS University (
  id_university INT NOT NULL AUTO_INCREMENT,
  name_university VARCHAR(50) NOT NULL,
  id_city INT NOT NULL, 
  PRIMARY KEY (id_university),
  FOREIGN KEY (id_city) REFERENCES City(id_city) 
  ON DELETE CASCADE 
  ON UPDATE NO ACTION
);


CREATE TABLE IF NOT EXISTS Admission_com(
  id_admission INT NOT NULL AUTO_INCREMENT,
  id_university INT NOT NULL,
  Start_Date DATE NOT NULL,
  End_Date DATE NOT NULL,
  PRIMARY KEY(id_admission),
  FOREIGN KEY(id_university) REFERENCES University(id_university)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS Falculty(
  id_falculty INT NOT NULL AUTO_INCREMENT,
  name_falculty VARCHAR(50) NOT NULL,
  id_university INT NOT NULL,
  PRIMARY KEY(id_falculty),
  FOREIGN KEY(id_university) REFERENCES University(id_university)
  ON DELETE CASCADE
  ON UPDATE CASCADE
  );
  
  CREATE TABLE IF NOT EXISTS Department(
  id_department INT NOT NULL AUTO_INCREMENT,
  name_department VARCHAR(50) NOT NULL,
  id_falculty INT NOT NULL,
  PRIMARY KEY(id_department),
  FOREIGN KEY(id_falculty) REFERENCES Falculty(id_falculty)
  ON DELETE CASCADE
  ON UPDATE CASCADE
  );
  
  CREATE TABLE IF NOT EXISTS Discipline(
  id_discipline INT NOT NULL AUTO_INCREMENT,
  code_name VARCHAR(50) NOT NULL,
  name_discipline VARCHAR(50) NOT NULL,
  PRIMARY KEY(id_discipline)
);

 CREATE TABLE IF NOT EXISTS Specialization (
  id_specialization INT NOT NULL AUTO_INCREMENT,
  id_department INT NOT NULL,
  id_discipline INT NOT NULL,
  PRIMARY KEY (id_specialization),
  FOREIGN KEY (id_department) REFERENCES Department(id_department)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (id_discipline) REFERENCES Discipline(id_discipline)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);


 CREATE TABLE IF NOT EXISTS State_Exam(
  id_state_exam INT NOT NULL AUTO_INCREMENT,
  name_state_exam VARCHAR(50) NOT NULL,
  PRIMARY KEY(id_state_exam)
);

CREATE TABLE IF NOT EXISTS State_Exam_Discipline (
  id_state_exam INT NOT NULL,
  id_discipline INT NOT NULL,
  PRIMARY KEY (id_state_exam, id_discipline),
  FOREIGN KEY (id_state_exam) REFERENCES State_Exam(id_state_exam)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  FOREIGN KEY (id_discipline) REFERENCES Discipline(id_discipline)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);


INSERT INTO City (name_city, status) VALUES 
('Saint-Petersburg', 'Active'), 
('Moscow', 'Inactive'),
('Sochi', 'Active'),
('Kranstat', 'Inactive'),
('Kazan', 'Active');

INSERT INTO University (name_university, id_city)
SELECT 'GUAP', id_city FROM City WHERE name_city = 'Saint-Petersburg';
INSERT INTO University (name_university, id_city)
SELECT 'ITMO', id_city FROM City WHERE name_city = 'Saint-Petersburg';
INSERT INTO University (name_university, id_city)
SELECT 'POLIT', id_city FROM City WHERE name_city = 'Moscow';
INSERT INTO University (name_university, id_city)
SELECT 'Sorbonne University', id_city FROM City WHERE name_city = 'Moscow';
INSERT INTO University (name_university, id_city)
SELECT 'Moscow State Technical University', id_city FROM City WHERE name_city = 'Moscow';

DELETE FROM University;
ALTER TABLE University AUTO_INCREMENT = 1;

INSERT INTO Admission_com (id_university, Start_Date, End_Date) 
VALUES 
(1, '2024-01-01', '2024-05-31'),
(2, '2024-02-01', '2024-06-30'),
(3, '2024-03-01', '2024-07-31'),
(4, '2024-04-01', '2024-08-31'),
(5, '2024-05-01', '2024-09-30');

DELETE FROM Admission_com;
ALTER TABLE Admission_com AUTO_INCREMENT = 1;

INSERT INTO Falculty (name_falculty, id_university)
VALUES 
('Business School', 1), 
('Business School', 3),
('Business School', 4),
('Economics', 2),
('Economics', 4),
('Physics', 3),
('Physics', 1),
('Physics', 5),
('Software Engineering', 1),
('Software Engineering', 2),
('Architecture', 5),
('Architecture', 2);

DELETE FROM Falculty;
ALTER TABLE Falculty AUTO_INCREMENT = 1;

-- Добавление кафедр, связанных с факультетом для всех университетов с факультетом Business School
INSERT INTO Department (name_department, id_falculty) 
SELECT 'Business Administration', id_falculty 
FROM Falculty 
WHERE name_falculty = 'Business School';

-- Добавление кафедр, связанных с факультетом для Университета 3 и 5, исключая id_university 1, хотя в нем есть физика (Физика)
INSERT INTO Department (name_department, id_falculty) 
VALUES ('Quantum Physics', 
    (SELECT id_falculty FROM Falculty WHERE name_falculty = 'Physics' AND id_university = 3)),
    ('Quantum Physics', 
    (SELECT id_falculty FROM Falculty WHERE name_falculty = 'Physics' AND id_university = 5));

-- Добавление кафедр, связанных с 'Информатикой' в Университете 1 и Университете 2
INSERT INTO Department (name_department, id_falculty) 
VALUES ('Artificial Intelligence', 
    (SELECT id_falculty FROM Falculty WHERE name_falculty = 'Software Engineering' AND id_university = 1)),
   ('Software Engineering', 
    (SELECT id_falculty FROM Falculty WHERE name_falculty = 'Software Engineering' AND id_university = 2));

INSERT INTO Department (name_department, id_falculty) 
VALUES ('Micro-Economics', 
    (SELECT id_falculty FROM Falculty WHERE name_falculty = 'Economics' AND id_university = 4));
    
DELETE FROM Department;
ALTER TABLE Department AUTO_INCREMENT = 1;

INSERT INTO State_Exam (name_state_exam) VALUES 
('Calculus Exam'), 
('Thermodynamics Exam'),
('Basics of Economics Exam'),
('Quantum Mechanics Exam'),
('Computer Archtecture Exam'),
('Artificial Intelligence Exam'),
('Acount Exam'),
('Drawing Exam'),
('Logical Programing Exam'),
('Moral Philosophy');

delete from state_exam where name_state_exam = "Moral Philosophy";
DELETE FROM State_Exam;
ALTER TABLE State_Exam AUTO_INCREMENT = 1;

INSERT INTO Discipline (code_name, name_discipline) VALUES 
('ENG101', 'Thermodynamics'), 
('MATH102', 'Calculus'),
('PHYS103', 'Quantum Mechanics'),
('PHIL104', 'Moral Philosophy'),
('CS105', 'Artificial Intelligence'),
('ECO294', 'Basics of Economics'),
('ACC043', 'Acount'),
('DYT5323', 'Drawing'),
('LPL456','Logical Programing'),
('CAE657', 'Computer Archtecture');



DROP PROCEDURE IF EXISTS insert_into_state_exam_discipline;

DELIMITER //

CREATE PROCEDURE insert_into_state_exam_discipline(
    IN exam_name VARCHAR(50),
    IN discipline_name VARCHAR(50)
)
BEGIN
    -- Insert data into State_Exam_Discipline using subqueries to get the respective IDs
    INSERT INTO State_Exam_Discipline (id_state_exam, id_discipline)
    SELECT 
        (SELECT id_state_exam FROM State_Exam WHERE name_state_exam = exam_name),
        (SELECT id_discipline FROM Discipline WHERE name_discipline = discipline_name)
    WHERE 
        (SELECT COUNT(*) FROM State_Exam WHERE name_state_exam = exam_name) > 0
        AND
        (SELECT COUNT(*) FROM Discipline WHERE name_discipline = discipline_name) > 0;
END //

DELIMITER ;


CALL insert_into_state_exam_discipline('Calculus Exam', 'Calculus');
CALL insert_into_state_exam_discipline('Thermodynamics Exam', 'Thermodynamics');
CALL insert_into_state_exam_discipline('Quantum Mechanics Exam', 'Quantum Mechanics');
CALL insert_into_state_exam_discipline('Moral Philosophy Exam', 'Moral Philosophy'); -- Не хранится в этой таблице, так как не присутствует ни в одной из таблиц
CALL insert_into_state_exam_discipline('Artificial Intelligence Exam', 'Artificial Intelligence');
CALL insert_into_state_exam_discipline('Basics of Economics Exam', 'Basics of Economics');
CALL insert_into_state_exam_discipline('Acount Exam', 'Acount');
CALL insert_into_state_exam_discipline('Drawing Exam', 'Drawing');
CALL insert_into_state_exam_discipline('Logical Programing Exam','Logical Programing');
CALL insert_into_state_exam_discipline('Computer Archtecture Exam', 'Computer Archtecture');



