-- Удаляем процедуру, если она уже существует
DROP PROCEDURE IF EXISTS add_university_with_city;
DROP Function count_faculties;
DELIMITER $$

-- Создаем процедуру для добавления университета с городом
CREATE PROCEDURE add_university_with_city(
    p_university_name VARCHAR(150), -- Имя университета
    p_city_name VARCHAR(20)         -- Имя города
)
BEGIN
    DECLARE city_id INT;            -- Переменная для хранения ID города
    DECLARE university_id INT;      -- Переменная для хранения ID университета

    -- Проверяем, существует ли город с указанным именем
    SELECT id_city INTO city_id
    FROM City
    WHERE name_city = p_city_name;

    -- Если город не существует, добавляем его в таблицу City
    IF city_id IS NULL THEN
        INSERT INTO City (name_city, status) 
        VALUES (p_city_name, 'active'); -- Добавляем город со статусом "active"
        SET city_id = LAST_INSERT_ID(); -- Получаем ID только что добавленного города
    END IF;

    -- Проверяем, существует ли университет с указанным именем
    SELECT id_university INTO university_id
    FROM University
    WHERE name_university = p_university_name;

    -- Если университет не существует, добавляем его в таблицу University
    IF university_id IS NULL THEN
        INSERT INTO University (name_university, id_city)
        VALUES (p_university_name, city_id); -- Связываем университет с городом
    END IF;
END$$

DELIMITER ;



DELIMITER $$

-- Создаем функцию для подсчета количества факультетов в университете
CREATE FUNCTION count_faculties(p_university_name VARCHAR(150))
RETURNS INT -- Возвращаемое значение типа INT
 reads sql data 
BEGIN
    DECLARE faculty_count INT; -- Переменная для хранения количества факультетов

    -- Выполняем подсчет факультетов для указанного университета
    SELECT COUNT(*)
    INTO faculty_count
    FROM Falculty f
    JOIN University u ON f.id_university = u.id_university
    WHERE u.name_university = p_university_name;

    -- Возвращаем количество факультетов
    RETURN faculty_count;
END$$

DELIMITER ;



DELIMITER $$
-- -- Процедура для удаления факультета по ID
CREATE PROCEDURE delete_falculty_by_id(
    IN p_falculty_id INT -- ID факультета
)
BEGIN
    DECLARE v_falculty_id INT;

    -- Получаем ID факультета по его имени
    SET v_falculty_id = p_falculty_id;

    -- Если факультет существует, выполняем удаление зависимых данных
    IF v_falculty_id IS NOT NULL THEN
        -- Удаляем специализации, связанные с департаментами факультета
        DELETE FROM Specialization
        WHERE id_department IN (
            SELECT id_department FROM Department WHERE id_falculty = v_falculty_id
        );

        -- Удаляем департаменты, связанные с факультетом
        DELETE FROM Department
        WHERE id_falculty = v_falculty_id;

        -- Удаляем сам факультет
        DELETE FROM Falculty
        WHERE id_falculty = v_falculty_id;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Faculty not found or ambiguous';
    END IF;
END$$

DELIMITER ;



DELIMITER $$

-- Процедура для удаления факультета по имени и ID университета
CREATE PROCEDURE delete_falculty_by_name_and_university(
    IN p_name_falculty VARCHAR(50), -- Имя факультета
    IN p_id_university INT          -- ID университета
)
BEGIN
    DECLARE v_falculty_id INT;

    -- Получаем ID факультета по имени и ID университета
    SELECT id_falculty INTO v_falculty_id
    FROM Falculty
    WHERE name_falculty = p_name_falculty AND id_university = p_id_university;

    -- Если факультет найден, удаляем связанные данные и сам факультет
    IF v_falculty_id IS NOT NULL THEN
        -- Удаляем специализации, связанные с департаментами факультета
        DELETE FROM Specialization
        WHERE id_department IN (
            SELECT id_department FROM Department WHERE id_falculty = v_falculty_id
        );

        -- Удаляем департаменты, связанные с факультетом
        DELETE FROM Department
        WHERE id_falculty = v_falculty_id;

        -- Удаляем сам факультет
        DELETE FROM Falculty
        WHERE id_falculty = v_falculty_id;
    ELSE
        -- Если факультет не найден, генерируем ошибку
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Факультет не найден или неверные параметры';
    END IF;
END$$

DELIMITER ;



DELIMITER $$

-- Создаем процедуру для удаления факультета и всех зависимых данных
-- работает только в том случае, если в названии этого факультета есть только одна строка
CREATE PROCEDURE delete_falculty_and_dependencies(
    IN p_falculty_name VARCHAR(50) -- Имя факультета
)
BEGIN
    DECLARE falculty_id INT; -- Переменная для хранения ID факультета

    -- Получаем ID факультета по его имени
    SELECT id_falculty INTO falculty_id
    FROM Falculty
    WHERE name_falculty = p_falculty_name;

    -- Если факультет существует, выполняем удаление зависимых данных
    IF falculty_id IS NOT NULL THEN
        -- Удаляем специализации, связанные с департаментами факультета
        DELETE FROM Specialization
        WHERE id_department IN (
            SELECT id_department FROM Department WHERE id_falculty = falculty_id
        );

        -- Удаляем департаменты, связанные с факультетом
        DELETE FROM Department
        WHERE id_falculty = falculty_id;

        -- Удаляем сам факультет
        DELETE FROM Falculty
        WHERE id_falculty = falculty_id;
    END IF;
END$$

DELIMITER ;



-- Шаг 1: Создание пользователя с указанным паролем
CREATE USER 'university_user'@'%' IDENTIFIED BY 'password123';
CREATE USER 'manager'@'%' IDENTIFIED BY 'password';
CREATE USER 'admin_role'@'%' IDENTIFIED BY 'admin_password';
CREATE USER 'root@localhost' IDENTIFIED BY 'Fumapaiwe@22';

-- Шаг 2: Отмена всех привилегий, чтобы пользователь не имел доступа по умолчанию
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'root@localhost';

-- Шаг 3: Предоставление пользователю привилегий EXECUTE только для определенных процедур и функций
GRANT EXECUTE ON PROCEDURE `add_university_with_city` TO 'university_user'@'%';
GRANT EXECUTE ON PROCEDURE `delete_falculty_and_dependencies` TO 'university_user'@'%';
GRANT EXECUTE ON PROCEDURE `delete_falculty_by_id` TO 'university_user'@'%';
GRANT EXECUTE ON FUNCTION `count_faculties` TO 'university_user'@'%';

-- Шаг 4: При необходимости предоставление привилегий SELECT для таблиц, которые могут потребоваться для выполнения процедур или функций
GRANT SELECT ON `City` TO 'university_user'@'%';
GRANT SELECT ON `University` TO 'university_user'@'%';
GRANT SELECT ON `Falculty` TO 'university_user'@'%';
GRANT SELECT ON `Department` TO 'university_user'@'%';
GRANT SELECT ON `Specialization` TO 'university_user'@'%';

-- Grant SELECT, INSERT, UPDATE, and DELETE privileges on the Falculty table
GRANT SELECT, INSERT, UPDATE, DELETE ON lab3.Falculty TO 'manager'@'%';

-- Grant SELECT, INSERT, UPDATE, and DELETE privileges on the Department table
GRANT SELECT, INSERT, UPDATE, DELETE ON lab3.Department TO 'manager'@'%';

-- Grant SELECT, INSERT, UPDATE, and DELETE privileges on the Specialization table
GRANT SELECT, INSERT, UPDATE, DELETE ON lab3.Specialization TO 'manager'@'%';

-- Привилегии для администратора
GRANT EXECUTE ON PROCEDURE `add_university_with_city` TO 'admin_role'@'%';
GRANT EXECUTE ON PROCEDURE `delete_falculty_and_dependencies` TO 'admin_role'@'%';
GRANT EXECUTE ON FUNCTION `count_faculties` TO 'admin_role'@'%';

-- Шаг 5: Применение изменений
FLUSH PRIVILEGES;

CALL add_university_with_city('Санкт-Петербургский Политехнический Университет', 'Санкт-Петербург');

CALL add_university_with_city('Новосибирский Государственный Университет', 'Новосибирск');

-- Для подсчета количества факультетов в Вузе
SELECT count_faculties('Санкт-Петербургский Государственный Университет Аэрокосмического Приборостроения') AS FacultyCount;

-- Удалим факультет "Факультет искусств":
CALL delete_falculty_and_dependencies('Факультет искусств');
CALL delete_falculty_by_id(4);



-- Проверка доступа к процедурам
SELECT 
    CONCAT(User, '@', Host) AS role_name,
    Db AS procedure_schema,
    Routine_name AS procedure_name,
    Routine_type AS procedure_type,
    Proc_priv AS privileges,
    CASE 
        WHEN FIND_IN_SET('Execute', Proc_priv) > 0 THEN 'Yes'
        ELSE 'No'
    END AS can_execute
FROM 
    mysql.procs_priv
WHERE 
    Db = 'lab3'
    AND Routine_name IN ('add_university_with_city', 'delete_falculty_and_dependencies');

-- Проверка доступа к функций
SELECT 
    CONCAT(User, '@', Host) AS role_name,
    Db AS function_schema,
    Routine_name AS function_name,
    Routine_type AS object_type,
    Proc_priv AS privileges,
    CASE 
        WHEN FIND_IN_SET('Execute', Proc_priv) > 0 THEN 'Yes'
        ELSE 'No'
    END AS can_execute
FROM 
    mysql.procs_priv
WHERE 
    Db = 'lab3'
    AND Routine_name = 'count_faculties';


-- Доступ к таблицам:
SELECT 
    grantee AS user,
    privilege_type,
    table_name AS name,
    'TABLE' AS object_type
FROM 
    information_schema.table_privileges
WHERE 
    table_schema = 'lab3';




SELECT 
    CONCAT(p.User, '@', p.Host) AS role_name,
    p.Db AS procedure_schema,
    p.Routine_name AS procedure_name,
    'PROCEDURE' AS object_type,
    CASE 
        WHEN FIND_IN_SET('Execute', p.Proc_priv) > 0 THEN 'Yes'
        ELSE 'No'
    END AS can_execute
FROM 
    mysql.procs_priv p
WHERE 
    p.Db = 'lab3'
    AND p.Routine_type = 'PROCEDURE'
    AND p.Routine_name IN ('add_university_with_city', 'delete_falculty_by_id');



