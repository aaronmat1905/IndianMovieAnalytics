-- =====================================================
-- INDIAN MOVIE DATABASE - STORED PROCEDURES
-- =====================================================
-- File 1 of 3: STORED PROCEDURES (10 Procedures)
-- Run this file AFTER creating all tables
-- =====================================================

DELIMITER //

-- ========================================================
-- PROCEDURE 1: sp_add_movie
-- Purpose: Create a new movie with automatic statistics 
--          and box office record creation
-- Input: Movie details (title, language, budget, etc.)
-- Output: Movie ID and success message
-- ========================================================
CREATE PROCEDURE sp_add_movie(
    IN p_title VARCHAR(200),
    IN p_release_date DATE,
    IN p_language_id INT,
    IN p_duration INT,
    IN p_certification VARCHAR(10),
    IN p_budget DECIMAL(15,2),
    IN p_ott_value DECIMAL(15,2),
    IN p_plot TEXT,
    IN p_rating DECIMAL(3,1),
    IN p_producer_id INT,
    IN p_created_by INT,
    OUT p_movie_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Unable to add movie. Transaction rolled back.';
        SET p_movie_id = -1;
    END;
    
    START TRANSACTION;
    
    -- Insert into MOVIES table
    INSERT INTO MOVIES (title, release_date, language_id, duration, certification, 
                        budget, ott_rights_value, plot_summary, imdb_rating, 
                        producer_id, created_by)
    VALUES (p_title, p_release_date, p_language_id, p_duration, p_certification, 
            p_budget, p_ott_value, p_plot, p_rating, p_producer_id, p_created_by);
    
    SET p_movie_id = LAST_INSERT_ID();
    
    -- Create statistics record for the new movie
    INSERT INTO MOVIE_STATISTICS (movie_id, average_rating) 
    VALUES (p_movie_id, p_rating);
    
    -- Create box office record for the new movie
    INSERT INTO BOX_OFFICE (movie_id, collection_status) 
    VALUES (p_movie_id, 'pending');
    
    -- Log activity
    INSERT INTO ACTIVITY_LOG (user_id, action, table_name, record_id, details)
    VALUES (p_created_by, 'CREATE', 'MOVIES', p_movie_id, 
            CONCAT('Movie added: ', p_title, ' | Budget: ', p_budget, ' | Language ID: ', p_language_id));
    
    COMMIT;
    SET p_message = CONCAT('Movie successfully created with ID: ', p_movie_id);
END //


-- ========================================================
-- PROCEDURE 2: sp_update_box_office
-- Purpose: Update box office collections with audit trail
--          and automatic statistics update
-- Input: Box office data (domestic, international, margin, screens)
-- Output: Success message
-- ========================================================
CREATE PROCEDURE sp_update_box_office(
    IN p_movie_id INT,
    IN p_domestic DECIMAL(15,2),
    IN p_intl DECIMAL(15,2),
    IN p_opening_weekend DECIMAL(15,2),
    IN p_profit_margin DECIMAL(5,2),
    IN p_screens INT,
    IN p_updated_by INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_old_domestic DECIMAL(15,2);
    DECLARE v_old_intl DECIMAL(15,2);
    DECLARE v_old_margin DECIMAL(5,2);
    DECLARE v_box_id INT;
    DECLARE v_username VARCHAR(50);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Unable to update box office. Transaction rolled back.';
    END;
    
    START TRANSACTION;
    
    -- Get old values for audit
    SELECT box_id, domestic_collection, intl_collection, profit_margin 
    INTO v_box_id, v_old_domestic, v_old_intl, v_old_margin
    FROM BOX_OFFICE WHERE movie_id = p_movie_id;
    
    -- Get username
    SELECT username INTO v_username FROM USERS WHERE user_id = p_updated_by;
    
    -- Update box office record
    UPDATE BOX_OFFICE
    SET domestic_collection = p_domestic,
        intl_collection = p_intl,
        opening_weekend = p_opening_weekend,
        profit_margin = p_profit_margin,
        release_screens = p_screens,
        updated_by = p_updated_by,
        collection_status = 'updated'
    WHERE movie_id = p_movie_id;
    
    -- Log in audit table
    INSERT INTO BOX_OFFICE_AUDIT (box_id, movie_id, old_domestic, new_domestic, 
                                   old_intl, new_intl, old_margin, new_margin, 
                                   modified_by, operation_type)
    VALUES (v_box_id, p_movie_id, v_old_domestic, p_domestic, v_old_intl, p_intl, 
            v_old_margin, p_profit_margin, v_username, 'UPDATE');
    
    -- Log activity
    INSERT INTO ACTIVITY_LOG (user_id, action, table_name, record_id, details)
    VALUES (p_updated_by, 'UPDATE', 'BOX_OFFICE', p_movie_id, 
            CONCAT('Box office updated - Domestic: ', p_domestic, ' | International: ', p_intl, ' | Screens: ', p_screens));
    
    COMMIT;
    SET p_message = CONCAT('Box office successfully updated for Movie ID: ', p_movie_id);
END //


-- ========================================================
-- PROCEDURE 3: sp_add_cast_to_movie
-- Purpose: Add an actor to a movie with role details
-- Input: Movie ID, Actor ID, Role details
-- Output: Success message
-- ========================================================
CREATE PROCEDURE sp_add_cast_to_movie(
    IN p_movie_id INT,
    IN p_actor_id INT,
    IN p_role_name VARCHAR(100),
    IN p_role_type VARCHAR(20),
    IN p_screen_time INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_actor_name VARCHAR(100);
    DECLARE v_movie_title VARCHAR(200);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Unable to add cast. Transaction rolled back.';
    END;
    
    START TRANSACTION;
    
    -- Get actor name and movie title for logging
    SELECT name INTO v_actor_name FROM ACTORS WHERE actor_id = p_actor_id;
    SELECT title INTO v_movie_title FROM MOVIES WHERE movie_id = p_movie_id;
    
    -- Insert into MOVIE_CAST
    INSERT INTO MOVIE_CAST (movie_id, actor_id, role_name, role_type, screen_time_minutes)
    VALUES (p_movie_id, p_actor_id, p_role_name, p_role_type, p_screen_time);
    
    -- Log activity
    INSERT INTO ACTIVITY_LOG (user_id, action, table_name, record_id, details)
    VALUES (1, 'CREATE', 'MOVIE_CAST', p_movie_id, 
            CONCAT('Actor added to movie - Actor: ', v_actor_name, ' | Movie: ', v_movie_title, 
                   ' | Role: ', p_role_name, ' | Type: ', p_role_type));
    
    COMMIT;
    SET p_message = CONCAT('Cast successfully added - Actor: ', v_actor_name, ' | Role: ', p_role_name);
END //


-- ========================================================
-- PROCEDURE 4: sp_add_crew_to_movie
-- Purpose: Add production crew member to a movie
-- Input: Movie ID, Crew ID, Role description
-- Output: Success message
-- ========================================================
CREATE PROCEDURE sp_add_crew_to_movie(
    IN p_movie_id INT,
    IN p_crew_id INT,
    IN p_role_description VARCHAR(150),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_crew_name VARCHAR(100);
    DECLARE v_crew_role VARCHAR(100);
    DECLARE v_movie_title VARCHAR(200);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Unable to add crew. Transaction rolled back.';
    END;
    
    START TRANSACTION;
    
    -- Get crew details and movie title
    SELECT name, role INTO v_crew_name, v_crew_role FROM PRODUCTION_CREW WHERE crew_id = p_crew_id;
    SELECT title INTO v_movie_title FROM MOVIES WHERE movie_id = p_movie_id;
    
    -- Insert into MOVIE_CREW
    INSERT INTO MOVIE_CREW (movie_id, crew_id, role_description)
    VALUES (p_movie_id, p_crew_id, p_role_description);
    
    -- Log activity
    INSERT INTO ACTIVITY_LOG (user_id, action, table_name, record_id, details)
    VALUES (1, 'CREATE', 'MOVIE_CREW', p_movie_id, 
            CONCAT('Crew added to movie - Crew: ', v_crew_name, ' | Role: ', v_crew_role, 
                   ' | Movie: ', v_movie_title));
    
    COMMIT;
    SET p_message = CONCAT('Crew successfully added - ', v_crew_name, ' as ', v_crew_role);
END //


-- ========================================================
-- PROCEDURE 5: sp_get_movie_details (NESTED QUERY)
-- Purpose: Retrieve complete movie details including 
--          cast, crew, and genres (3 result sets)
-- Input: Movie ID
-- Output: 3 result sets (movie info, cast, crew)
-- ========================================================
CREATE PROCEDURE sp_get_movie_details(IN p_movie_id INT)
BEGIN
    -- Result Set 1: Movie Information
    SELECT 
        m.movie_id,
        m.title,
        m.release_date,
        l.language_name,
        m.duration,
        m.certification,
        m.budget,
        m.ott_rights_value,
        m.imdb_rating,
        p.name AS producer_name,
        p.company AS producer_company,
        GROUP_CONCAT(DISTINCT g.genre_name SEPARATOR ', ') AS genres,
        fn_get_movie_status(m.movie_id) AS movie_status
    FROM MOVIES m
    LEFT JOIN LANGUAGES l ON m.language_id = l.language_id
    LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
    LEFT JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
    LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
    WHERE m.movie_id = p_movie_id
    GROUP BY m.movie_id;
    
    -- Result Set 2: Cast Information
    SELECT 
        a.actor_id,
        a.name,
        a.gender,
        a.popularity_score,
        mc.role_name,
        mc.role_type,
        mc.screen_time_minutes
    FROM MOVIE_CAST mc
    JOIN ACTORS a ON mc.actor_id = a.actor_id
    WHERE mc.movie_id = p_movie_id;
    
    -- Result Set 3: Crew Information
    SELECT 
        pc.crew_id,
        pc.name,
        pc.role,
        pc.specialty,
        pc.experience_years,
        mc.role_description
    FROM MOVIE_CREW mc
    JOIN PRODUCTION_CREW pc ON mc.crew_id = pc.crew_id
    WHERE mc.movie_id = p_movie_id;
END //


-- ========================================================
-- PROCEDURE 6: sp_get_profit_analysis (JOIN QUERY)
-- Purpose: Analyze movie profitability with calculations
-- Input: Movie ID
-- Output: Profit analysis details
-- ========================================================
CREATE PROCEDURE sp_get_profit_analysis(IN p_movie_id INT)
BEGIN
    SELECT 
        m.movie_id,
        m.title,
        l.language_name,
        m.budget,
        bo.domestic_collection,
        bo.intl_collection,
        bo.total_collection,
        (bo.total_collection - m.budget) AS net_profit,
        fn_calculate_profit_percentage(m.budget, bo.total_collection) AS profit_percentage,
        bo.opening_weekend,
        bo.release_screens,
        bo.profit_margin,
        m.imdb_rating,
        COUNT(DISTINCT mc.actor_id) AS actor_count
    FROM MOVIES m
    LEFT JOIN LANGUAGES l ON m.language_id = l.language_id
    LEFT JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
    LEFT JOIN MOVIE_CAST mc ON m.movie_id = mc.movie_id
    WHERE m.movie_id = p_movie_id
    GROUP BY m.movie_id;
END //


-- ========================================================
-- PROCEDURE 7: sp_get_language_box_office_summary (AGGREGATE QUERY)
-- Purpose: Compare collections by language with aggregation
-- Input: None
-- Output: Summary statistics by language
-- ========================================================
CREATE PROCEDURE sp_get_language_box_office_summary()
BEGIN
    SELECT 
        l.language_name,
        COUNT(m.movie_id) AS total_movies,
        SUM(m.budget) AS total_budget,
        SUM(bo.total_collection) AS total_collection,
        AVG(bo.total_collection) AS avg_collection,
        MAX(bo.total_collection) AS highest_collection,
        AVG(m.imdb_rating) AS avg_rating
    FROM LANGUAGES l
    LEFT JOIN MOVIES m ON l.language_id = m.language_id
    LEFT JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
    GROUP BY l.language_id, l.language_name
    ORDER BY total_collection DESC;
END //


-- ========================================================
-- PROCEDURE 8: sp_get_top_actors (RANKING QUERY)
-- Purpose: List actors sorted by popularity with movie count
-- Input: Limit (number of top actors)
-- Output: Actor rankings with filmography
-- ========================================================
CREATE PROCEDURE sp_get_top_actors(IN p_limit INT)
BEGIN
    SELECT 
        a.actor_id,
        a.name,
        a.gender,
        a.popularity_score,
        COUNT(DISTINCT mc.movie_id) AS movie_count,
        GROUP_CONCAT(DISTINCT m.title SEPARATOR ', ') AS movies
    FROM ACTORS a
    LEFT JOIN MOVIE_CAST mc ON a.actor_id = mc.actor_id
    LEFT JOIN MOVIES m ON mc.movie_id = m.movie_id
    GROUP BY a.actor_id
    ORDER BY a.popularity_score DESC
    LIMIT p_limit;
END //


-- ========================================================
-- PROCEDURE 9: sp_delete_movie
-- Purpose: Safely delete a movie and all related records
-- Input: Movie ID, Deleted by User ID
-- Output: Success message
-- ========================================================
CREATE PROCEDURE sp_delete_movie(
    IN p_movie_id INT,
    IN p_deleted_by INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_movie_title VARCHAR(200);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Unable to delete movie. Transaction rolled back.';
    END;
    
    START TRANSACTION;
    
    -- Get movie title for logging
    SELECT title INTO v_movie_title FROM MOVIES WHERE movie_id = p_movie_id;
    
    -- Delete from dependent tables
    DELETE FROM MOVIE_CAST WHERE movie_id = p_movie_id;
    DELETE FROM MOVIE_CREW WHERE movie_id = p_movie_id;
    DELETE FROM MOVIE_GENRES WHERE movie_id = p_movie_id;
    DELETE FROM BOX_OFFICE WHERE movie_id = p_movie_id;
    DELETE FROM MOVIE_STATISTICS WHERE movie_id = p_movie_id;
    
    -- Delete from main table
    DELETE FROM MOVIES WHERE movie_id = p_movie_id;
    
    -- Log activity
    INSERT INTO ACTIVITY_LOG (user_id, action, table_name, record_id, details)
    VALUES (p_deleted_by, 'DELETE', 'MOVIES', p_movie_id, 
            CONCAT('Movie deleted: ', v_movie_title));
    
    COMMIT;
    SET p_message = CONCAT('Movie successfully deleted: ', v_movie_title);
END //


-- ========================================================
-- PROCEDURE 10: sp_get_movie_report_by_year (ANALYTICAL QUERY)
-- Purpose: Movies grouped by release year with analysis
-- Input: Year
-- Output: Movie report for specific year
-- ========================================================
CREATE PROCEDURE sp_get_movie_report_by_year(IN p_year INT)
BEGIN
    SELECT 
        YEAR(m.release_date) AS release_year,
        m.title,
        l.language_name,
        p.name AS producer_name,
        m.budget,
        bo.total_collection,
        (bo.total_collection - m.budget) AS net_profit,
        m.imdb_rating,
        COUNT(DISTINCT mc.actor_id) AS actor_count
    FROM MOVIES m
    LEFT JOIN LANGUAGES l ON m.language_id = l.language_id
    LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
    LEFT JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
    LEFT JOIN MOVIE_CAST mc ON m.movie_id = mc.movie_id
    WHERE YEAR(m.release_date) = p_year
    GROUP BY m.movie_id
    ORDER BY m.release_date;
END //

DELIMITER ;

-- ========================================================
-- STORED PROCEDURES CREATED SUCCESSFULLY
-- ========================================================
-- Total Procedures: 10
-- Types: CRUD, Nested Queries, Join Queries, 
--        Aggregate Queries, Analytical Queries
-- ========================================================