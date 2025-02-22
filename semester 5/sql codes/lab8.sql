use lab3; 
SET SQL_SAFE_UPDATES = 0;


-- University Table Triggers
drop table if exists univ_log;
CREATE TABLE IF NOT EXISTS univ_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    university_id INT NOT NULL,
    action VARCHAR(10) NOT NULL,
    changetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 1. Before Inserting
DELIMITER $$

CREATE TRIGGER before_university_insert
BEFORE INSERT ON University
FOR EACH ROW
BEGIN
    IF NEW.name_university = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'University name cannot be empty.';
    END IF;
    IF NEW.id_city > 5 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid city ID';
    END IF;
END$$

DELIMITER ;

-- 2. Before Updating
DELIMITER $$

CREATE TRIGGER before_university_update
BEFORE UPDATE ON University
FOR EACH ROW
BEGIN
    IF NEW.name_university = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'University name cannot be empty.';
    END IF;
    IF NEW.id_city > 5 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid city ID';
    END IF;
END$$

DELIMITER ;

DROP TRIGGER IF EXISTS before_university_delete;
-- 3. Before Deleting
DELIMITER $$

CREATE TRIGGER before_university_delete
BEFORE DELETE ON University
FOR EACH ROW
BEGIN
    -- Cascade delete related Falculty records
    DELETE FROM Falculty WHERE id_university = OLD.id_university;

    -- Cascade delete related Admission_com records
    DELETE FROM Admission_com WHERE id_university = OLD.id_university;

    -- Cascade delete related Department records
    DELETE FROM Department WHERE id_falculty IN (
        SELECT id_falculty FROM Falculty WHERE id_university = OLD.id_university
    );

    -- Cascade delete related Specialization records
    DELETE FROM Specialization WHERE id_department IN (
        SELECT id_department FROM Department WHERE id_falculty IN (
            SELECT id_falculty FROM Falculty WHERE id_university = OLD.id_university
        )
    );

END$$

DELIMITER ;




-- 4. After Inserting
DROP TRIGGER IF EXISTS after_university_insert;
DELIMITER $$

CREATE TRIGGER after_university_insert
AFTER INSERT ON University
FOR EACH ROW
BEGIN
    INSERT INTO univ_log (university_id, action, changetime)
    VALUES (NEW.id_university, 'INSERT', CURRENT_TIMESTAMP);
END$$

DELIMITER ;

DROP TRIGGER IF EXISTS after_university_update;

-- 5. After Update
DELIMITER $$

CREATE TRIGGER after_university_update
AFTER UPDATE ON University
FOR EACH ROW
BEGIN
    INSERT INTO univ_log (university_id, action, changetime)
    VALUES (NEW.id_university, 'UPDATE', CURRENT_TIMESTAMP);
END$$

DELIMITER ;

-- 6. After Delete
DROP TRIGGER IF EXISTS after_university_delete;
DELIMITER $$

CREATE TRIGGER after_university_delete
AFTER DELETE ON University
FOR EACH ROW
BEGIN
    INSERT INTO univ_log (university_id, action, changetime)
    VALUES (OLD.id_university, 'DELETE', CURRENT_TIMESTAMP);
END$$

DELIMITER ;


drop table specializ_log;
-- Specialization Table Triggers
CREATE TABLE IF NOT EXISTS specializ_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    specialization_id INT NOT NULL,
    action VARCHAR(10) NOT NULL,
    changetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 1. Before Insert
DELIMITER $$

CREATE TRIGGER before_specialization_insert
BEFORE INSERT ON Specialization
FOR EACH ROW
BEGIN
    IF NEW.name_specialization = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Specialization name cannot be empty.';
    END IF;
END$$

DELIMITER ;


-- 2. Before Update
DELIMITER $$

CREATE TRIGGER before_specialization_update
BEFORE UPDATE ON Specialization
FOR EACH ROW
BEGIN
    IF NEW.name_specialization = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Specialization name cannot be empty.';
    END IF;
END$$

DELIMITER ;


-- 3. Before Delete
DELIMITER $$

CREATE TRIGGER before_specialization_delete
BEFORE DELETE ON Specialization
FOR EACH ROW
BEGIN
    DELETE FROM State_Exam_Discipline WHERE id_discipline = OLD.id_discipline;
END$$

DELIMITER ;

drop trigger if exists after_specialization_insert;
-- 4. After Insert
DELIMITER $$

CREATE TRIGGER after_specialization_insert
AFTER INSERT ON Specialization
FOR EACH ROW
BEGIN
    INSERT INTO specializ_log (specialization_id, action, changetime)
    VALUES (NEW.id_specialization, 'INSERT', CURRENT_TIMESTAMP);
END$$

DELIMITER ;

drop trigger if exists after_specialization_update;
-- 5. After Update
DELIMITER $$

CREATE TRIGGER after_specialization_update
AFTER UPDATE ON Specialization
FOR EACH ROW
BEGIN
    INSERT INTO specializ_log (specialization_id, action, changetime)
    VALUES (NEW.id_specialization, 'UPDATE', CURRENT_TIMESTAMP);
END$$

DELIMITER ;


-- 6. After Delete
DROP TRIGGER IF EXISTS after_specialization_delete;

DELIMITER $$

CREATE TRIGGER after_specialization_delete
AFTER DELETE ON Specialization
FOR EACH ROW
BEGIN
    INSERT INTO specializ_log (specialization_id, action, changetime)
    VALUES (OLD.id_specialization, 'DELETE', CURRENT_TIMESTAMP);
END$$

DELIMITER ;

SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, ACTION_STATEMENT, ACTION_TIMING 
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'lab3';
