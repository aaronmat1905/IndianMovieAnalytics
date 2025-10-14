-- =====================================================
-- INDIAN MOVIE DATABASE - TRIGGERS
-- =====================================================
-- File 3 of 3: TRIGGERS (10 Triggers)
-- Run this file AFTER creating all tables
-- =====================================================

DELIMITER //

-- ========================================================
-- TRIGGER 1: tr_movie_insert_audit
-- Purpose: Automatically create audit log when movie is added
-- Event: AFTER INSERT on MOVIES table
-- Action: Insert record into MOVIE_AUDIT
-- ========================================================
CREATE TRIGGER tr_movie_insert_audit
AFTER INSERT ON MOVIES
FOR EACH ROW
BEGIN
    INSERT INTO MOVIE_AUDIT (
        movie_id, 
        new_title, 
        new_budget, 
        new_release_date, 
        modified_by, 
        modification_reason, 
        operation_type
    )
    VALUES (
        NEW.movie_id, 
        NEW.title, 
        NEW.budget, 
        NEW.release_date, 
        'System', 
        'Movie Created', 
        'INSERT'
    );
END //


-- ========================================================
-- TRIGGER 2: tr_movie_update_audit
-- Purpose: Track all changes to movie records
-- Event: AFTER UPDATE on MOVIES table
-- Action: Insert audit record only if title, budget, 
--         or release_date changed
-- ========================================================
CREATE TRIGGER tr_movie_update_audit
AFTER UPDATE ON MOVIES
FOR EACH ROW
BEGIN
    IF (OLD.title != NEW.title OR 
        OLD.budget != NEW.budget OR 
        OLD.release_date != NEW.release_date) THEN
        INSERT INTO MOVIE_AUDIT (
            movie_id, 
            old_title, 
            new_title, 
            old_budget, 
            new_budget, 
            old_release_date, 
            new_release_date, 
            modified_by, 
            operation_type
        )
        VALUES (
            NEW.movie_id, 
            OLD.title, 
            NEW.title, 
            OLD.budget, 
            NEW.budget, 
            OLD.release_date, 
            NEW.release_date, 
            'System', 
            'UPDATE'
        );
    END IF;
END //


-- ========================================================
-- TRIGGER 3: tr_movie_delete_audit
-- Purpose: Create audit record before movie is deleted
-- Event: BEFORE DELETE on MOVIES table
-- Action: Insert deletion record into MOVIE_AUDIT
-- ========================================================
CREATE TRIGGER tr_movie_delete_audit
BEFORE DELETE ON MOVIES
FOR EACH ROW
BEGIN
    INSERT INTO MOVIE_AUDIT (
        movie_id, 
        old_title, 
        old_budget, 
        old_release_date, 
        modified_by, 
        modification_reason, 
        operation_type
    )
    VALUES (
        OLD.movie_id, 
        OLD.title, 
        OLD.budget, 
        OLD.release_date, 
        'System', 
        'Movie Deleted', 
        'DELETE'
    );
END //


-- ========================================================
-- TRIGGER 4: tr_box_office_validation
-- Purpose: Ensure data integrity for box office records
-- Event: BEFORE UPDATE on BOX_OFFICE table
-- Action: Validate values before update, raise errors if invalid
-- Validations: No negative collections, valid margins, valid screens
-- ========================================================
CREATE TRIGGER tr_box_office_validation
BEFORE UPDATE ON BOX_OFFICE
FOR EACH ROW
BEGIN
    -- Check for negative domestic collection
    IF NEW.domestic_collection < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Domestic collection cannot be negative!';
    END IF;
    
    -- Check for negative international collection
    IF NEW.intl_collection < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: International collection cannot be negative!';
    END IF;
    
    -- Check for invalid profit margin
    IF NEW.profit_margin > 100 OR NEW.profit_margin < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Profit margin must be between 0 and 100!';
    END IF;
    
    -- Check for valid screens (must be greater than 0)
    IF NEW.release_screens <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Release screens must be greater than 0!';
    END IF;
END //


-- ========================================================
-- TRIGGER 5: tr_update_movie_stats
-- Purpose: Automatically update statistics when collections change
-- Event: AFTER UPDATE on BOX_OFFICE table
-- Action: Update MOVIE_STATISTICS table with new collection values
-- ========================================================
CREATE TRIGGER tr_update_movie_stats
AFTER UPDATE ON BOX_OFFICE
FOR EACH ROW
BEGIN
    UPDATE MOVIE_STATISTICS
    SET 
        monthly_collection = NEW.total_collection,
        last_updated = CURRENT_TIMESTAMP
    WHERE movie_id = NEW.movie_id;
END //


-- ========================================================
-- TRIGGER 6: tr_prevent_duplicate_cast
-- Purpose: Prevent adding same actor to movie twice
-- Event: BEFORE INSERT on MOVIE_CAST table
-- Action: Check for duplicate and raise error if found
-- ========================================================
CREATE TRIGGER tr_prevent_duplicate_cast
BEFORE INSERT ON MOVIE_CAST
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    
    -- Count existing cast entries for this movie and actor
    SELECT COUNT(*) INTO v_count 
    FROM MOVIE_CAST 
    WHERE movie_id = NEW.movie_id 
    AND actor_id = NEW.actor_id;
    
    -- Raise error if duplicate found
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: This actor is already added to this movie!';
    END IF;
END //


-- ========================================================
-- TRIGGER 7: tr_prevent_duplicate_crew
-- Purpose: Prevent adding same crew member to movie twice
-- Event: BEFORE INSERT on MOVIE_CREW table
-- Action: Check for duplicate and raise error if found
-- ========================================================
CREATE TRIGGER tr_prevent_duplicate_crew
BEFORE INSERT ON MOVIE_CREW
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    
    -- Count existing crew entries for this movie and crew member
    SELECT COUNT(*) INTO v_count 
    FROM MOVIE_CREW 
    WHERE movie_id = NEW.movie_id 
    AND crew_id = NEW.crew_id;
    
    -- Raise error if duplicate found
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: This crew member is already added to this movie!';
    END IF;
END //


-- ========================================================
-- TRIGGER 8: tr_box_office_insert_audit
-- Purpose: Create audit trail for box office insertions
-- Event: AFTER INSERT on BOX_OFFICE table
-- Action: Insert record into BOX_OFFICE_AUDIT
-- ========================================================
CREATE TRIGGER tr_box_office_insert_audit
AFTER INSERT ON BOX_OFFICE
FOR EACH ROW
BEGIN
    INSERT INTO BOX_OFFICE_AUDIT (
        box_id, 
        movie_id, 
        new_domestic, 
        new_intl, 
        new_margin, 
        modified_by, 
        operation_type
    )
    VALUES (
        NEW.box_id, 
        NEW.movie_id, 
        NEW.domestic_collection, 
        NEW.intl_collection, 
        NEW.profit_margin, 
        'System', 
        'INSERT'
    );
END //


-- ========================================================
-- TRIGGER 9: tr_validate_actor_data
-- Purpose: Ensure valid actor information on insert/update
-- Event: BEFORE INSERT on ACTORS table
-- Action: Validate popularity score, birth date, and name
-- ========================================================
CREATE TRIGGER tr_validate_actor_data
BEFORE INSERT ON ACTORS
FOR EACH ROW
BEGIN
    -- Check for valid popularity score (0-10)
    IF NEW.popularity_score < 0 OR NEW.popularity_score > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Popularity score must be between 0 and 10!';
    END IF;
    
    -- Check for valid birth date (not in future)
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Date of birth cannot be in the future!';
    END IF;
    
    -- Check for valid actor name (not empty)
    IF LENGTH(TRIM(NEW.name)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Actor name cannot be empty!';
    END IF;
END //


-- ========================================================
-- TRIGGER 10: tr_validate_crew_data
-- Purpose: Ensure valid crew information on insert
-- Event: BEFORE INSERT on PRODUCTION_CREW table
-- Action: Validate experience, name, and role
-- ========================================================
CREATE TRIGGER tr_validate_crew_data
BEFORE INSERT ON PRODUCTION_CREW
FOR EACH ROW
BEGIN
    -- Check for valid experience years (non-negative)
    IF NEW.experience_years < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Experience years cannot be negative!';
    END IF;
    
    -- Check for valid name (not empty)
    IF LENGTH(TRIM(NEW.name)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Crew name cannot be empty!';
    END IF;
    
    -- Check for valid role (not empty)
    IF LENGTH(TRIM(NEW.role)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Crew role cannot be empty!';
    END IF;
END //


-- ========================================================
-- ADDITIONAL TRIGGERS (Optional - Advanced)
-- ========================================================

-- ========================================================
-- TRIGGER 11: tr_validate_movie_data
-- Purpose: Validate movie data before insertion
-- Event: BEFORE INSERT on MOVIES table
-- Action: Validate title, duration, and rating
-- ========================================================
CREATE TRIGGER tr_validate_movie_data
BEFORE INSERT ON MOVIES
FOR EACH ROW
BEGIN
    -- Check for valid movie title (not empty)
    IF LENGTH(TRIM(NEW.title)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Movie title cannot be empty!';
    END IF;
    
    -- Check for valid duration (positive)
    IF NEW.duration IS NOT NULL AND NEW.duration <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Movie duration must be greater than 0!';
    END IF;
    
    -- Check for valid IMDB rating (0-10)
    IF NEW.imdb_rating IS NOT NULL AND (NEW.imdb_rating < 0 OR NEW.imdb_rating > 10) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: IMDB rating must be between 0 and 10!';
    END IF;
END //


-- ========================================================
-- TRIGGER 12: tr_log_activity_on_actor_insert
-- Purpose: Log when new actor is added to system
-- Event: AFTER INSERT on ACTORS table
-- Action: Insert record into ACTIVITY_LOG
-- ========================================================
CREATE TRIGGER tr_log_activity_on_actor_insert
AFTER INSERT ON ACTORS
FOR EACH ROW
BEGIN
    INSERT INTO ACTIVITY_LOG (
        user_id, 
        action, 
        table_name, 
        record_id, 
        details
    )
    VALUES (
        1, 
        'CREATE', 
        'ACTORS', 
        NEW.actor_id, 
        CONCAT('New actor added: ', NEW.name, ' | Popularity: ', NEW.popularity_score)
    );
END //


-- ========================================================
-- TRIGGER 13: tr_log_activity_on_crew_insert
-- Purpose: Log when new crew member is added to system
-- Event: AFTER INSERT on PRODUCTION_CREW table
-- Action: Insert record into ACTIVITY_LOG
-- ========================================================
CREATE TRIGGER tr_log_activity_on_crew_insert
AFTER INSERT ON PRODUCTION_CREW
FOR EACH ROW
BEGIN
    INSERT INTO ACTIVITY_LOG (
        user_id, 
        action, 
        table_name, 
        record_id, 
        details
    )
    VALUES (
        1, 
        'CREATE', 
        'PRODUCTION_CREW', 
        NEW.crew_id, 
        CONCAT('New crew member added: ', NEW.name, ' | Role: ', NEW.role, ' | Experience: ', NEW.experience_years, ' years')
    );
END //


-- ========================================================
-- TRIGGER 14: tr_validate_movie_cast
-- Purpose: Validate movie cast data before insertion
-- Event: BEFORE INSERT on MOVIE_CAST table
-- Action: Validate screen time is non-negative
-- ========================================================
CREATE TRIGGER tr_validate_movie_cast
BEFORE INSERT ON MOVIE_CAST
FOR EACH ROW
BEGIN
    -- Check for negative screen time
    IF NEW.screen_time_minutes < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Screen time cannot be negative!';
    END IF;
    
    -- Check for valid role type
    IF NEW.role_type NOT IN ('Lead', 'Supporting', 'Cameo') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Invalid role type! Must be Lead, Supporting, or Cameo.';
    END IF;
END //

DELIMITER ;

-- ========================================================
-- TRIGGERS CREATED SUCCESSFULLY
-- ========================================================
-- Core Triggers: 10
-- Additional Triggers: 4
-- Total Triggers: 14
-- ========================================================
-- Trigger Categories:
-- - Audit Logging: tr_movie_insert_audit, tr_movie_update_audit, 
--                  tr_movie_delete_audit, tr_box_office_insert_audit,
--                  tr_log_activity_on_actor_insert, 
--                  tr_log_activity_on_crew_insert
-- - Data Validation: tr_box_office_validation, tr_validate_actor_data,
--                    tr_validate_crew_data, tr_validate_movie_data,
--                    tr_validate_movie_cast
-- - Business Rules: tr_prevent_duplicate_cast, tr_prevent_duplicate_crew
-- - Auto-update: tr_update_movie_stats
-- ========================================================