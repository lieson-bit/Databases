use lab3;
SET SQL_SAFE_UPDATES = 0;
-- Inserting values

DELETE FROM State_Exam_Discipline;
ALTER TABLE State_Exam_Discipline AUTO_INCREMENT = 1;

DELETE FROM Specialization;
ALTER TABLE Specialization AUTO_INCREMENT = 1;

DELETE FROM State_Exam;
ALTER TABLE State_Exam AUTO_INCREMENT = 1;

DELETE FROM Discipline;
ALTER TABLE Discipline AUTO_INCREMENT = 1;

DELETE FROM Department;
ALTER TABLE Department AUTO_INCREMENT = 1;

DELETE FROM Falculty;
ALTER TABLE Falculty AUTO_INCREMENT = 1;

DELETE FROM Admission_com;
ALTER TABLE Admission_com AUTO_INCREMENT = 1;

DELETE FROM University;
ALTER TABLE University AUTO_INCREMENT = 1;

DELETE FROM City;
ALTER TABLE City AUTO_INCREMENT = 1;


INSERT INTO City (name_city, status) VALUES 
('Кранштат', 'Неактивный'),
('Санкт-Петербург', 'Активный'); -- Город, в котором есть все укрупненные группы

INSERT INTO University (name_university, id_city) VALUES 
('Харьковский Национальный Университет', 1),
('Санкт-Петербургский Государственный Университет Аэрокосмического Приборостроения', 2);

INSERT INTO Admission_com (id_university, Start_Date, End_Date) VALUES 
(1, '2024-01-01', '2024-05-31'),  -- Направление, где нужно сдавать математику
(2, '2024-02-01', '2024-06-30'),  -- Не принимающая на одну направленность
(1, '2024-05-01', '2024-09-30');  -- Не удовлетворяет условию

INSERT INTO Falculty (name_falculty, id_university) VALUES 
('Факультет программной инженерии', 1),
('Факультет программной инженерии', 2),
('Факультет экономики', 1),
('Факультет искусств', 2),
('Факультет экономики', 2);   

Insert into Department (name_department, id_falculty) values
('Кафедра разработки программного обеспечения систем', 2),
('Кафедра бизнеса', 5),
('Кафедра рисования', 4),
('Факультет искусства и дизайна', 4);

INSERT INTO Discipline (id_discipline, code_name, name_discipline) VALUES
(1, '02.03.01', 'Программные системы и управление'),
(2, '02.03.02', 'Информационные системы и технологии'),
(3, '02.01.03', 'Автоматизированные системы управления'),
(4, '38.03.01', 'Математика и Экономика'),
(5, '38.03.02', 'Иностранные языки и перевод'),
(6, '01.01.08', 'Искусство и дизайн');


INSERT INTO Specialization (id_specialization, id_department, id_discipline, name_specialization) VALUES
(1, 1, 1, 'Математика и компьютерные науки'),
(2, 1, 2, 'Фундаментальные информатика и информационные технологии'),
(3, 1, 3, 'Математическое обеспечение и администрирование информационных систем'),
(4, 2, 4, 'Экономика'),
(5, 2, 5, 'Менеджмент'),
(6, 4, 6, 'Дизайн');


INSERT INTO State_Exam (name_state_exam) VALUES 
('Экзамен по математике'),  -- Направление, где нужно сдавать математику
('Экзамен по информатике'),  -- Направление, где нужно сдавать информатику
('Экзамен по экономике'),
('Экзамен по иностранному языку'),
('Экзамен по Искусство и дизайн');  -- Направление, где не нужно сдавать математику

INSERT INTO State_Exam_Discipline (id_state_exam, id_discipline) VALUES
(1, 1),
(2, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 6);
