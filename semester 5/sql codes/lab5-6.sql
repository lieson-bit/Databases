use lab3;

SELECT s.id_specialization, s.name_specialization
FROM Specialization AS s
WHERE LOWER(s.name_specialization) LIKE '%_систем%';

SELECT d.id_department, d.name_department
FROM Department AS d
LEFT JOIN Specialization AS s ON d.id_department = s.id_department
WHERE s.id_specialization IS NULL;


SELECT d.id_discipline, d.code_name, d.name_discipline
FROM Discipline AS d
JOIN State_Exam_Discipline AS sed1 ON d.id_discipline = sed1.id_discipline
JOIN State_Exam_Discipline AS sed2 ON d.id_discipline = sed2.id_discipline
JOIN State_Exam AS se1 ON sed1.id_state_exam = se1.id_state_exam
JOIN State_Exam AS se2 ON sed2.id_state_exam = se2.id_state_exam
WHERE se1.name_state_exam = 'Экзамен по математике'
  AND se2.name_state_exam = 'Экзамен по информатике';

-- 6-ой Лаб
-- г. факультет, принимающий на количество направлений больше среднего 
SELECT f.name_falculty, 
       f.id_falculty, 
       COUNT(DISTINCT disc.id_discipline) AS num_disciplines
FROM Falculty f
JOIN Department dept ON f.id_falculty = dept.id_falculty
JOIN Specialization spec ON dept.id_department = spec.id_department
JOIN Discipline disc ON spec.id_discipline = disc.id_discipline
GROUP BY f.name_falculty, f.id_falculty
HAVING COUNT(DISTINCT disc.id_discipline) > (
    SELECT AVG(num_disciplines) 
    FROM (
        SELECT f2.id_falculty, 
               COUNT(DISTINCT disc2.id_discipline) AS num_disciplines
        FROM Falculty f2
        LEFT JOIN Department dept2 ON f2.id_falculty = dept2.id_falculty
        LEFT JOIN Specialization spec2 ON dept2.id_department = spec2.id_department
        LEFT JOIN Discipline disc2 ON spec2.id_discipline = disc2.id_discipline
        GROUP BY f2.id_falculty
    ) AS avg_counts
);

-- д. город, в котором есть все укрупненные группы направлений и специальностей(УГСН) 
-- (первые 2 цифры номера специальности, т.е у 09.03.04 УГСН=09, а у 02.03.03-02)
-- city- делимая
-- делитель -укрупненные группы
-- Using 2 NOT EXISTS
SELECT DISTINCT c.name_city
FROM City c
WHERE NOT EXISTS (
  -- Select all unique укрупненные группы (UGSN) from disciplines
  SELECT DISTINCT LEFT(d.code_name, 2) AS UGSN
  FROM Discipline d
  WHERE NOT EXISTS (
    -- Check if all UGSNs are represented in the city's universities
    SELECT 1
    FROM University u
    JOIN Falculty f ON u.id_university = f.id_university
    JOIN Department dep ON f.id_falculty = dep.id_falculty
    JOIN Specialization sp ON dep.id_department = sp.id_department
    JOIN Discipline d_in_city ON sp.id_discipline = d_in_city.id_discipline
    WHERE u.id_city = c.id_city
      AND LEFT(d_in_city.code_name, 2) = LEFT(d.code_name, 2) -- Compare UGSNs
  )
);

/*
Внешний --запрос возвращает данные обо всех городах.
Первое значение NOT EXISTS гарантирует, что в городе существуют все различные UGSN (первые две цифры кодового имени).
Второе значение NOT EXISTS гарантирует, что UGSN существует по крайней мере в одном университете, факультете и специализации в пределах города. --
*/

-- Using Aggregation
SELECT c.name_city
FROM City c
JOIN University u ON c.id_city = u.id_city
JOIN Falculty f ON u.id_university = f.id_university
JOIN Department dep ON f.id_falculty = dep.id_falculty
JOIN Specialization sp ON dep.id_department = sp.id_department
JOIN Discipline d ON sp.id_discipline = d.id_discipline
GROUP BY c.id_city, c.name_city
HAVING COUNT(DISTINCT LEFT(d.code_name, 2)) = (
  SELECT COUNT(DISTINCT LEFT(d2.code_name, 2))
  FROM Discipline d2
);
/*
Основной запрос группирует данные по городам и подсчитывает различные номера UGN, присутствующие в каждом городе.
Предложение HAVING сравнивает это количество с общим количеством различных номеров UGN (подзапрос).
Если количество совпадает, в качестве результата возвращается город.
*/

-- е. вуз, с последним по алфавиту названием
-- Using all
SELECT name_university
FROM University u
WHERE name_university >= ALL (
  SELECT name_university
  FROM University
);

-- Using Max
SELECT name_university
FROM University
WHERE name_university = (
  SELECT MAX(name_university)
  FROM University
);

/*
Директива ALL сравнивает значение name_university из внешнего запроса со всеми результатами во вложенном запросе.
Университет с названием, удовлетворяющим >= ALL, является последним в алфавитном порядке.
*/

-- ж. направление, на которое не надо сдавать ЕГЭ по математике, но надо по иностранному языку


/*Using NOT IN*/
SELECT DISTINCT d.id_discipline, d.name_discipline
FROM Discipline d
JOIN State_Exam_Discipline sed1 ON d.id_discipline = sed1.id_discipline
JOIN State_Exam se1 ON sed1.id_state_exam = se1.id_state_exam
WHERE se1.name_state_exam = 'Экзамен по иностранному языку'
  AND d.id_discipline NOT IN (
    SELECT d2.id_discipline
    FROM Discipline d2
    JOIN State_Exam_Discipline sed2 ON d2.id_discipline = sed2.id_discipline
    JOIN State_Exam se2 ON sed2.id_state_exam = se2.id_state_exam
    WHERE se2.name_state_exam = 'Экзамен по математике'
  );

/*Using LEFT JOIN*/
SELECT DISTINCT d.id_discipline, d.name_discipline
FROM Discipline d
JOIN State_Exam_Discipline sed1 ON d.id_discipline = sed1.id_discipline
JOIN State_Exam se1 ON sed1.id_state_exam = se1.id_state_exam
LEFT JOIN (
  SELECT DISTINCT d2.id_discipline
  FROM Discipline d2
  JOIN State_Exam_Discipline sed2 ON d2.id_discipline = sed2.id_discipline
  JOIN State_Exam se2 ON sed2.id_state_exam = se2.id_state_exam
  WHERE se2.name_state_exam = 'Экзамен по математике'
) AS q1 ON d.id_discipline = q1.id_discipline
WHERE se1.name_state_exam = 'Экзамен по иностранному языку' 
  AND q1.id_discipline IS NULL;
  
  /*Using NOT EXISTS*/
SELECT d.id_discipline, d.name_discipline
FROM Discipline d
JOIN State_Exam_Discipline sed_foreign ON d.id_discipline = sed_foreign.id_discipline
JOIN State_Exam foreign_exam ON sed_foreign.id_state_exam = foreign_exam.id_state_exam
WHERE foreign_exam.name_state_exam = 'Экзамен по иностранному языку'
  AND NOT EXISTS (
    SELECT 1
    FROM State_Exam_Discipline sed_math
    JOIN State_Exam math_exam ON sed_math.id_state_exam = math_exam.id_state_exam
    WHERE math_exam.name_state_exam = 'Экзамен по математике'
      AND sed_math.id_discipline = d.id_discipline
);
  -- Using EXCEPT--
  SELECT DISTINCT d.id_discipline, d.name_discipline
FROM Discipline d
JOIN State_Exam_Discipline sed1 ON d.id_discipline = sed1.id_discipline
JOIN State_Exam se1 ON sed1.id_state_exam = se1.id_state_exam
WHERE se1.name_state_exam = 'Экзамен по иностранному языку'
EXCEPT
SELECT DISTINCT d2.id_discipline, d2.name_discipline
FROM Discipline d2
JOIN State_Exam_Discipline sed2 ON d2.id_discipline = sed2.id_discipline
JOIN State_Exam se2 ON sed2.id_state_exam = se2.id_state_exam
WHERE se2.name_state_exam = 'Экзамен по математике';
  
  
  
  
  
  
  
  /*
  SELECT DISTINCT d.name_discipline
FROM Discipline d
JOIN State_Exam_Discipline sed_foreign ON d.id_discipline = sed_foreign.id_discipline
RIGHT JOIN State_Exam foreign_exam ON sed_foreign.id_state_exam = foreign_exam.id_state_exam
  AND foreign_exam.name_state_exam = 'Экзамен по иностранному языку'
LEFT JOIN State_Exam_Discipline sed_math ON d.id_discipline = sed_math.id_discipline
LEFT JOIN State_Exam math_exam ON sed_math.id_state_exam = math_exam.id_state_exam
  AND math_exam.name_state_exam = 'Экзамен по математике'
WHERE foreign_exam.id_state_exam IS NOT NULL
  AND math_exam.id_state_exam IS NULL;
*/