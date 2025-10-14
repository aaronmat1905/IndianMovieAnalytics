-- Function 1: Calculate Profit Percentage
DELIMITER //

DROP FUNCTION IF EXISTS CalculateProfitPercentage//

CREATE FUNCTION CalculateProfitPercentage(budget DECIMAL(15,2), collection DECIMAL(15,2))
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE profit_pct DECIMAL(5,2);
    
    IF budget = 0 OR budget IS NULL THEN
        RETURN 0;
    END IF;
    
    SET profit_pct = ((collection - budget) / budget) * 100;
    RETURN profit_pct;
END//

DELIMITER ;

-- Function 2: Get Movie Rating Category
DELIMITER //

DROP FUNCTION IF EXISTS GetRatingCategory//

CREATE FUNCTION GetRatingCategory(rating DECIMAL(3,1))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    CASE
        WHEN rating >= 9.0 THEN RETURN 'Masterpiece';
        WHEN rating >= 8.0 THEN RETURN 'Excellent';
        WHEN rating >= 7.0 THEN RETURN 'Good';
        WHEN rating >= 6.0 THEN RETURN 'Average';
        WHEN rating >= 5.0 THEN RETURN 'Below Average';
        ELSE RETURN 'Poor';
    END CASE;
END//

DELIMITER ;

-- Function 3: Get Movie Age in Years
DELIMITER //

DROP FUNCTION IF EXISTS GetMovieAge//

CREATE FUNCTION GetMovieAge(release_dt DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, release_dt, CURDATE());
END//

DELIMITER ;

-- Function 4: Calculate ROI (Return on Investment)
DELIMITER //

DROP FUNCTION IF EXISTS CalculateROI//

CREATE FUNCTION CalculateROI(movie_id_param INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE roi DECIMAL(10,2);
    DECLARE movie_budget DECIMAL(15,2);
    DECLARE movie_collection DECIMAL(15,2);
    
    SELECT m.budget, b.total_collection
    INTO movie_budget, movie_collection
    FROM MOVIES m
    LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
    WHERE m.movie_id = movie_id_param;
    
    IF movie_budget IS NULL OR movie_budget = 0 THEN
        RETURN 0;
    END IF;
    
    SET roi = ((movie_collection - movie_budget) / movie_budget) * 100;
    RETURN roi;
END//

DELIMITER ;