-- =====================================================
-- INDIAN MOVIE DATABASE - FUNCTIONS
-- =====================================================
-- File 2 of 3: FUNCTIONS (3 Functions)
-- Run this file AFTER creating all tables
-- =====================================================

DELIMITER //

-- ========================================================
-- FUNCTION 1: fn_calculate_experience
-- Purpose: Calculate experience years from start date
-- Input: Start date
-- Output: Number of years
-- Returns: INT
-- ========================================================
CREATE FUNCTION fn_calculate_experience(p_start_date DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_experience INT;
    
    -- Calculate difference between current year and start year
    SET v_experience = YEAR(CURDATE()) - YEAR(p_start_date);
    
    -- Return experience years
    RETURN v_experience;
END //


-- ========================================================
-- FUNCTION 2: fn_get_movie_status
-- Purpose: Determine movie status based on release date
--          and collection data
-- Input: Movie ID
-- Output: Status string
-- Returns: VARCHAR(50)
-- Statuses: Not Scheduled, Upcoming, Releasing Today, 
--           Released (Collection Pending), Released
-- ========================================================
CREATE FUNCTION fn_get_movie_status(p_movie_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_status VARCHAR(50);
    DECLARE v_release_date DATE;
    DECLARE v_total_collection DECIMAL(15,2);
    
    -- Get release date from MOVIES table
    SELECT release_date INTO v_release_date 
    FROM MOVIES 
    WHERE movie_id = p_movie_id;
    
    -- Get total collection from BOX_OFFICE table
    SELECT total_collection INTO v_total_collection 
    FROM BOX_OFFICE 
    WHERE movie_id = p_movie_id;
    
    -- Determine status based on conditions
    IF v_release_date IS NULL THEN
        SET v_status = 'Not Scheduled';
    ELSEIF v_release_date > CURDATE() THEN
        SET v_status = 'Upcoming';
    ELSEIF v_release_date = CURDATE() THEN
        SET v_status = 'Releasing Today';
    ELSEIF v_release_date < CURDATE() AND v_total_collection IS NULL THEN
        SET v_status = 'Released (Collection Pending)';
    ELSE
        SET v_status = 'Released';
    END IF;
    
    RETURN v_status;
END //


-- ========================================================
-- FUNCTION 3: fn_calculate_profit_percentage
-- Purpose: Calculate profit percentage from budget 
--          and collection
-- Input: Budget, Collection Amount
-- Output: Profit percentage
-- Returns: DECIMAL(5,2)
-- Note: Returns 0 if budget is 0 or null (division by zero safety)
-- ========================================================
CREATE FUNCTION fn_calculate_profit_percentage(
    p_budget DECIMAL(15,2), 
    p_collection DECIMAL(15,2)
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_profit_percentage DECIMAL(5,2);
    
    -- Check for null or zero budget to avoid division by zero
    IF p_budget = 0 OR p_budget IS NULL THEN
        SET v_profit_percentage = 0;
    ELSE
        -- Calculate profit percentage: ((Collection - Budget) / Budget) * 100
        SET v_profit_percentage = ROUND(
            ((p_collection - p_budget) / p_budget * 100), 
            2
        );
    END IF;
    
    RETURN v_profit_percentage;
END //


-- ========================================================
-- ADDITIONAL HELPER FUNCTIONS (Optional - Advanced)
-- ========================================================

-- ========================================================
-- FUNCTION 4: fn_get_actor_movie_count
-- Purpose: Get total number of movies for an actor
-- Input: Actor ID
-- Output: Count of movies
-- Returns: INT
-- ========================================================
CREATE FUNCTION fn_get_actor_movie_count(p_actor_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(DISTINCT movie_id) INTO v_count
    FROM MOVIE_CAST
    WHERE actor_id = p_actor_id;
    
    RETURN COALESCE(v_count, 0);
END //


-- ========================================================
-- FUNCTION 5: fn_get_producer_movie_count
-- Purpose: Get total number of movies for a producer
-- Input: Producer ID
-- Output: Count of movies
-- Returns: INT
-- ========================================================
CREATE FUNCTION fn_get_producer_movie_count(p_producer_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(movie_id) INTO v_count
    FROM MOVIES
    WHERE producer_id = p_producer_id;
    
    RETURN COALESCE(v_count, 0);
END //


-- ========================================================
-- FUNCTION 6: fn_get_language_movie_count
-- Purpose: Get total number of movies in a language
-- Input: Language ID
-- Output: Count of movies
-- Returns: INT
-- ========================================================
CREATE FUNCTION fn_get_language_movie_count(p_language_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(movie_id) INTO v_count
    FROM MOVIES
    WHERE language_id = p_language_id;
    
    RETURN COALESCE(v_count, 0);
END //


-- ========================================================
-- FUNCTION 7: fn_calculate_total_profit
-- Purpose: Calculate total profit for a movie
-- Input: Movie ID
-- Output: Net profit amount
-- Returns: DECIMAL(15,2)
-- ========================================================
CREATE FUNCTION fn_calculate_total_profit(p_movie_id INT)
RETURNS DECIMAL(15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_budget DECIMAL(15,2);
    DECLARE v_collection DECIMAL(15,2);
    DECLARE v_profit DECIMAL(15,2);
    
    -- Get budget from MOVIES table
    SELECT budget INTO v_budget
    FROM MOVIES
    WHERE movie_id = p_movie_id;
    
    -- Get total collection from BOX_OFFICE table
    SELECT total_collection INTO v_collection
    FROM BOX_OFFICE
    WHERE movie_id = p_movie_id;
    
    -- Calculate profit (Collection - Budget)
    SET v_profit = COALESCE(v_collection, 0) - COALESCE(v_budget, 0);
    
    RETURN v_profit;
END //


-- ========================================================
-- FUNCTION 8: fn_is_profitable
-- Purpose: Check if a movie is profitable
-- Input: Movie ID
-- Output: Boolean (1 = Yes, 0 = No)
-- Returns: INT (0 or 1)
-- ========================================================
CREATE FUNCTION fn_is_profitable(p_movie_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_profit DECIMAL(15,2);
    
    -- Calculate profit using previous function
    SET v_profit = fn_calculate_total_profit(p_movie_id);
    
    -- Return 1 if profitable, 0 otherwise
    IF v_profit > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END //


-- ========================================================
-- FUNCTION 9: fn_get_actor_average_rating
-- Purpose: Get average IMDB rating of actor's movies
-- Input: Actor ID
-- Output: Average rating
-- Returns: DECIMAL(3,1)
-- ========================================================
CREATE FUNCTION fn_get_actor_average_rating(p_actor_id INT)
RETURNS DECIMAL(3,1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg_rating DECIMAL(3,1);
    
    SELECT AVG(m.imdb_rating) INTO v_avg_rating
    FROM MOVIES m
    JOIN MOVIE_CAST mc ON m.movie_id = mc.movie_id
    WHERE mc.actor_id = p_actor_id
    AND m.imdb_rating IS NOT NULL;
    
    RETURN COALESCE(v_avg_rating, 0);
END //


-- ========================================================
-- FUNCTION 10: fn_get_producer_total_budget
-- Purpose: Get total budget of all movies by producer
-- Input: Producer ID
-- Output: Total budget
-- Returns: DECIMAL(15,2)
-- ========================================================
CREATE FUNCTION fn_get_producer_total_budget(p_producer_id INT)
RETURNS DECIMAL(15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_budget DECIMAL(15,2);
    
    SELECT SUM(budget) INTO v_total_budget
    FROM MOVIES
    WHERE producer_id = p_producer_id
    AND budget IS NOT NULL;
    
    RETURN COALESCE(v_total_budget, 0);
END //

DELIMITER ;

-- ========================================================
-- FUNCTIONS CREATED SUCCESSFULLY
-- ========================================================
-- Core Functions: 3
-- Helper Functions: 7
-- Total Functions: 10
-- ========================================================
-- Usage Examples:
-- ========================================================

-- SELECT fn_calculate_experience('2015-01-01') AS years;
-- SELECT fn_get_movie_status(1) AS status;
-- SELECT fn_calculate_profit_percentage(10000000, 25000000) AS profit_pct;
-- SELECT fn_get_actor_movie_count(1) AS movie_count;
-- SELECT fn_calculate_total_profit(1) AS net_profit;
-- SELECT fn_is_profitable(1) AS is_profitable;

-- ========================================================