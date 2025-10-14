-- Procedure 1: Get Movie Analytics
DELIMITER //

DROP PROCEDURE IF EXISTS GetMovieAnalytics//

CREATE PROCEDURE GetMovieAnalytics(IN movie_id_param INT)
BEGIN
    SELECT 
        m.title,
        m.budget,
        b.total_collection,
        (b.total_collection - m.budget) as profit,
        CASE 
            WHEN b.total_collection > m.budget THEN 'Profit'
            ELSE 'Loss'
        END as status,
        m.imdb_rating,
        GROUP_CONCAT(g.genre_name) as genres
    FROM MOVIES m
    LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
    LEFT JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
    LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
    WHERE m.movie_id = movie_id_param
    GROUP BY m.movie_id;
END//

DELIMITER ;

-- Procedure 2: Search Movies by Criteria
DELIMITER //

DROP PROCEDURE IF EXISTS SearchMovies//

CREATE PROCEDURE SearchMovies(
    IN search_title VARCHAR(200),
    IN search_genre VARCHAR(50),
    IN min_rating DECIMAL(3,1),
    IN max_budget DECIMAL(15,2)
)
BEGIN
    SELECT DISTINCT
        m.movie_id,
        m.title,
        m.release_date,
        m.imdb_rating,
        m.budget,
        p.name as producer_name,
        GROUP_CONCAT(DISTINCT g.genre_name) as genres
    FROM MOVIES m
    LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
    LEFT JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
    LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
    WHERE 
        (search_title IS NULL OR m.title LIKE CONCAT('%', search_title, '%'))
        AND (search_genre IS NULL OR g.genre_name = search_genre)
        AND (min_rating IS NULL OR m.imdb_rating >= min_rating)
        AND (max_budget IS NULL OR m.budget <= max_budget)
    GROUP BY m.movie_id
    ORDER BY m.imdb_rating DESC;
END//

DELIMITER ;

-- Procedure 3: Get Producer Statistics
DELIMITER //

DROP PROCEDURE IF EXISTS GetProducerStats//

CREATE PROCEDURE GetProducerStats(IN producer_id_param INT)
BEGIN
    SELECT 
        p.name,
        p.company,
        COUNT(m.movie_id) as total_movies,
        AVG(m.imdb_rating) as avg_rating,
        SUM(b.total_collection) as total_collection,
        SUM(m.budget) as total_budget,
        (SUM(b.total_collection) - SUM(m.budget)) as net_profit,
        MAX(b.total_collection) as highest_grosser
    FROM PRODUCERS p
    LEFT JOIN MOVIES m ON p.producer_id = m.producer_id
    LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
    WHERE p.producer_id = producer_id_param
    GROUP BY p.producer_id;
END//

DELIMITER ;

-- Procedure 4: Add Movie with Genres (Transaction example)
DELIMITER //

DROP PROCEDURE IF EXISTS AddMovieWithGenres//

CREATE PROCEDURE AddMovieWithGenres(
    IN movie_title VARCHAR(200),
    IN release_dt DATE,
    IN lang VARCHAR(50),
    IN dur INT,
    IN cert VARCHAR(10),
    IN budg DECIMAL(15,2),
    IN rating DECIMAL(3,1),
    IN prod_id INT,
    IN genre_ids VARCHAR(100)  -- comma-separated genre IDs
)
BEGIN
    DECLARE new_movie_id INT;
    DECLARE genre_id_val INT;
    DECLARE genre_pos INT;
    DECLARE genre_list VARCHAR(100);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error adding movie';
    END;
    
    START TRANSACTION;
    
    -- Insert movie
    INSERT INTO MOVIES (title, release_date, language, duration, certification, 
                       budget, imdb_rating, producer_id)
    VALUES (movie_title, release_dt, lang, dur, cert, budg, rating, prod_id);
    
    SET new_movie_id = LAST_INSERT_ID();
    
    -- Insert genres
    SET genre_list = CONCAT(genre_ids, ',');
    
    WHILE LENGTH(genre_list) > 0 DO
        SET genre_pos = LOCATE(',', genre_list);
        SET genre_id_val = CAST(SUBSTRING(genre_list, 1, genre_pos - 1) AS UNSIGNED);
        
        INSERT INTO MOVIE_GENRES (movie_id, genre_id)
        VALUES (new_movie_id, genre_id_val);
        
        SET genre_list = SUBSTRING(genre_list, genre_pos + 1);
    END WHILE;
    
    COMMIT;
    
    SELECT new_movie_id as movie_id, 'Movie added successfully' as message;
END//

DELIMITER ;