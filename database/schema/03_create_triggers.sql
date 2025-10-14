-- Trigger 1: Audit trail for movie updates
DELIMITER //

DROP TRIGGER IF EXISTS movie_update_audit//

CREATE TRIGGER movie_update_audit
    AFTER UPDATE ON MOVIES
    FOR EACH ROW
BEGIN
    IF OLD.title != NEW.title OR OLD.budget != NEW.budget THEN
        INSERT INTO MOVIE_AUDIT (movie_id, old_title, new_title, old_budget, new_budget, modified_by)
        VALUES (NEW.movie_id, OLD.title, NEW.title, OLD.budget, NEW.budget, USER());
    END IF;
END//

DELIMITER ;

-- Trigger 2: Validate movie budget before insert
DELIMITER //

DROP TRIGGER IF EXISTS validate_movie_budget//

CREATE TRIGGER validate_movie_budget
    BEFORE INSERT ON MOVIES
    FOR EACH ROW
BEGIN
    IF NEW.budget < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Movie budget cannot be negative';
    END IF;
    
    IF NEW.budget > 10000000000 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Movie budget seems unrealistic (> 1000 Cr)';
    END IF;
END//

DELIMITER ;

-- Trigger 3: Validate IMDB rating on update
DELIMITER //

DROP TRIGGER IF EXISTS validate_rating_update//

CREATE TRIGGER validate_rating_update
    BEFORE UPDATE ON MOVIES
    FOR EACH ROW
BEGIN
    IF NEW.imdb_rating IS NOT NULL THEN
        IF NEW.imdb_rating < 0 OR NEW.imdb_rating > 10 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'IMDB rating must be between 0 and 10';
        END IF;
    END IF;
END//

DELIMITER ;

-- Trigger 4: Prevent deletion of producers with movies
DELIMITER //

DROP TRIGGER IF EXISTS prevent_producer_delete//

CREATE TRIGGER prevent_producer_delete
    BEFORE DELETE ON PRODUCERS
    FOR EACH ROW
BEGIN
    DECLARE movie_count INT;
    
    SELECT COUNT(*) INTO movie_count
    FROM MOVIES
    WHERE producer_id = OLD.producer_id;
    
    IF movie_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete producer with existing movies';
    END IF;
END//

DELIMITER ;