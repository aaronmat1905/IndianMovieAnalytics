-- =====================================================
-- INDIAN MOVIE DATABASE APPLICATION - COMPLETE SCHEMA
-- =====================================================
-- This script creates all 10 tables with procedures, 
-- triggers, functions, and views for a movie database app

-- Drop existing tables if they exist (optional - comment out if not needed)
-- SET FOREIGN_KEY_CHECKS = 0;
-- DROP TABLE IF EXISTS ACTIVITY_LOG;
-- DROP TABLE IF EXISTS MOVIE_AUDIT;
-- DROP TABLE IF EXISTS BOX_OFFICE_AUDIT;
-- DROP TABLE IF EXISTS MOVIE_STATISTICS;
-- DROP TABLE IF EXISTS MOVIE_CREW;
-- DROP TABLE IF EXISTS PRODUCTION_CREW;
-- DROP TABLE IF EXISTS MOVIE_CAST;
-- DROP TABLE IF EXISTS ACTORS;
-- DROP TABLE IF EXISTS BOX_OFFICE;
-- DROP TABLE IF EXISTS MOVIE_GENRES;
-- DROP TABLE IF EXISTS MOVIES;
-- DROP TABLE IF EXISTS GENRES;
-- DROP TABLE IF EXISTS LANGUAGES;
-- DROP TABLE IF EXISTS PRODUCERS;
-- DROP TABLE IF EXISTS USERS;
-- SET FOREIGN_KEY_CHECKS = 1;

-- ========================================================
-- TABLE 1: USERS - User Management & Role-Based Access
-- ========================================================
CREATE TABLE USERS (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    CHECK(role IN ('admin', 'producer', 'analyst', 'viewer'))
);

INSERT INTO USERS (username, password, email, role) VALUES 
('admin_user', MD5('admin123'), 'admin@movie.com', 'admin'),
('producer_user', MD5('producer123'), 'producer@movie.com', 'producer'),
('analyst_user', MD5('analyst123'), 'analyst@movie.com', 'analyst'),
('viewer_user', MD5('viewer123'), 'viewer@movie.com', 'viewer');

CREATE INDEX idx_user_role ON USERS(role);


-- ========================================================
-- TABLE 2: PRODUCERS - Movie Producers Information
-- ========================================================
CREATE TABLE PRODUCERS (
    producer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    company VARCHAR(150),
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    start_date DATE NOT NULL,
    region VARCHAR(50),
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK(phone REGEXP '^[0-9+\-\s()]*$' OR phone IS NULL),
    FOREIGN KEY (created_by) REFERENCES USERS(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_producer_name ON PRODUCERS(name);
CREATE INDEX idx_company ON PRODUCERS(company);


-- ========================================================
-- TABLE 3: LANGUAGES - Film Industry Languages
-- ========================================================
CREATE TABLE LANGUAGES (
    language_id INT PRIMARY KEY AUTO_INCREMENT,
    language_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO LANGUAGES (language_name, description) VALUES 
('Hindi', 'Bollywood - Hindi cinema'),
('Tamil', 'Kollywood - Tamil cinema'),
('Telugu', 'Tollywood - Telugu cinema'),
('Kannada', 'Kannada cinema'),
('Malayalam', 'Malayalam cinema'),
('Marathi', 'Marathi cinema'),
('Punjabi', 'Punjabi cinema'),
('English', 'English cinema in India');


-- ========================================================
-- TABLE 4: GENRES - Movie Genres
-- ========================================================
CREATE TABLE GENRES (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO GENRES (genre_name, description) VALUES 
('Drama', 'Dramatic films'),
('Action', 'Action-packed films'),
('Comedy', 'Comedic films'),
('Romance', 'Romantic films'),
('Thriller', 'Thriller films'),
('Family', 'Family-friendly films'),
('Horror', 'Horror films'),
('Musical', 'Films with music and dance');


-- ========================================================
-- TABLE 5: MOVIES - Core Movie Information
-- ========================================================
CREATE TABLE MOVIES (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    release_date DATE,
    language_id INT NOT NULL,
    duration INT CHECK(duration > 0),
    certification VARCHAR(10),
    budget DECIMAL(15,2) CHECK(budget >= 0),
    ott_rights_value DECIMAL(15,2) CHECK(ott_rights_value >= 0),
    poster_url VARCHAR(500),
    plot_summary TEXT,
    imdb_rating DECIMAL(3,1) CHECK(imdb_rating >= 0 AND imdb_rating <= 10),
    producer_id INT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (producer_id) REFERENCES PRODUCERS(producer_id) ON DELETE SET NULL,
    FOREIGN KEY (language_id) REFERENCES LANGUAGES(language_id),
    FOREIGN KEY (created_by) REFERENCES USERS(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_title ON MOVIES(title);
CREATE INDEX idx_release_date ON MOVIES(release_date);
CREATE INDEX idx_language ON MOVIES(language_id);
CREATE INDEX idx_producer ON MOVIES(producer_id);


-- ========================================================
-- TABLE 6: MOVIE_GENRES - Many-to-Many: Movies & Genres
-- ========================================================
CREATE TABLE MOVIE_GENRES (
    movie_id INT,
    genre_id INT,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES GENRES(genre_id) ON DELETE CASCADE
);


-- ========================================================
-- TABLE 7: BOX_OFFICE - Box Office Collections
-- ========================================================
CREATE TABLE BOX_OFFICE (
    box_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT UNIQUE NOT NULL,
    domestic_collection DECIMAL(15,2) CHECK(domestic_collection >= 0),
    intl_collection DECIMAL(15,2) CHECK(intl_collection >= 0),
    opening_weekend DECIMAL(15,2) CHECK(opening_weekend >= 0),
    total_collection DECIMAL(15,2) AS (COALESCE(domestic_collection, 0) + COALESCE(intl_collection, 0)) STORED,
    profit_margin DECIMAL(5,2) CHECK(profit_margin >= 0),
    release_screens INT CHECK(release_screens > 0),
    collection_status VARCHAR(30) DEFAULT 'pending',
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES USERS(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_box_office_movie ON BOX_OFFICE(movie_id);


-- ========================================================
-- TABLE 8: ACTORS - Actor Information
-- ========================================================
CREATE TABLE ACTORS (
    actor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(20),
    date_of_birth DATE,
    nationality VARCHAR(50),
    popularity_score DECIMAL(3,1) CHECK(popularity_score >= 0 AND popularity_score <= 10),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_actor_name ON ACTORS(name);


-- ========================================================
-- TABLE 9: MOVIE_CAST - Many-to-Many: Movies & Actors
-- ========================================================
CREATE TABLE MOVIE_CAST (
    cast_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    actor_id INT NOT NULL,
    role_name VARCHAR(100),
    role_type VARCHAR(20),
    screen_time_minutes INT CHECK(screen_time_minutes >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES ACTORS(actor_id) ON DELETE CASCADE,
    UNIQUE(movie_id, actor_id),
    CHECK(role_type IN ('Lead', 'Supporting', 'Cameo'))
);

CREATE INDEX idx_cast_movie ON MOVIE_CAST(movie_id);
CREATE INDEX idx_cast_actor ON MOVIE_CAST(actor_id);


-- ========================================================
-- TABLE 10: PRODUCTION_CREW - Production Crew Members
-- ========================================================
CREATE TABLE PRODUCTION_CREW (
    crew_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(100) NOT NULL,
    specialty VARCHAR(150),
    experience_years INT CHECK(experience_years >= 0),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK(role IN ('Director', 'Cinematographer', 'Music Director', 'Editor', 'Producer', 'Writer', 'Choreographer', 'Other'))
);

CREATE INDEX idx_crew_name ON PRODUCTION_CREW(name);
CREATE INDEX idx_crew_role ON PRODUCTION_CREW(role);


-- ========================================================
-- SUPPORTING TABLE: MOVIE_CREW - Many-to-Many: Movies & Crew
-- ========================================================
CREATE TABLE MOVIE_CREW (
    movie_crew_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    crew_id INT NOT NULL,
    role_description VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (crew_id) REFERENCES PRODUCTION_CREW(crew_id) ON DELETE CASCADE,
    UNIQUE(movie_id, crew_id)
);

CREATE INDEX idx_movie_crew_movie ON MOVIE_CREW(movie_id);
CREATE INDEX idx_movie_crew_crew ON MOVIE_CREW(crew_id);


-- ========================================================
-- SUPPORTING TABLE: MOVIE_STATISTICS - Movie Performance Stats
-- ========================================================
CREATE TABLE MOVIE_STATISTICS (
    stat_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT UNIQUE NOT NULL,
    total_reviews INT DEFAULT 0,
    average_rating DECIMAL(3,1),
    viewer_count INT DEFAULT 0,
    weekly_collection DECIMAL(15,2),
    monthly_collection DECIMAL(15,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE
);

CREATE INDEX idx_stat_movie ON MOVIE_STATISTICS(movie_id);


-- ========================================================
-- AUDIT TABLE: MOVIE_AUDIT - Movie Modification Tracking
-- ========================================================
CREATE TABLE MOVIE_AUDIT (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    old_title VARCHAR(200),
    new_title VARCHAR(200),
    old_budget DECIMAL(15,2),
    new_budget DECIMAL(15,2),
    old_release_date DATE,
    new_release_date DATE,
    modified_by VARCHAR(100),
    modification_reason VARCHAR(255),
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation_type VARCHAR(20),
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE,
    CHECK(operation_type IN ('INSERT', 'UPDATE', 'DELETE'))
);

CREATE INDEX idx_audit_movie ON MOVIE_AUDIT(movie_id);
CREATE INDEX idx_audit_date ON MOVIE_AUDIT(modified_at);


-- ========================================================
-- AUDIT TABLE: BOX_OFFICE_AUDIT - Box Office Change Tracking
-- ========================================================
CREATE TABLE BOX_OFFICE_AUDIT (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    box_id INT NOT NULL,
    movie_id INT NOT NULL,
    old_domestic DECIMAL(15,2),
    new_domestic DECIMAL(15,2),
    old_intl DECIMAL(15,2),
    new_intl DECIMAL(15,2),
    old_margin DECIMAL(5,2),
    new_margin DECIMAL(5,2),
    modified_by VARCHAR(100),
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation_type VARCHAR(20),
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE,
    CHECK(operation_type IN ('INSERT', 'UPDATE', 'DELETE'))
);

CREATE INDEX idx_box_audit_movie ON BOX_OFFICE_AUDIT(movie_id);
CREATE INDEX idx_box_audit_date ON BOX_OFFICE_AUDIT(modified_at);


-- ========================================================
-- AUDIT TABLE: ACTIVITY_LOG - User Activity Tracking
-- ========================================================
CREATE TABLE ACTIVITY_LOG (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id INT,
    details TEXT,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_activity_user ON ACTIVITY_LOG(user_id);
CREATE INDEX idx_activity_timestamp ON ACTIVITY_LOG(action_timestamp);


-- ========================================================
-- STORED PROCEDURES
-- ========================================================

DELIMITER //

-- PROCEDURE 1: Add New Movie with Transaction
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
    OUT p_movie_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Unable to add movie' AS error_message;
    END;
    
    START TRANSACTION;
    
    INSERT INTO MOVIES (title, release_date, language_id, duration, certification, budget, ott_rights_value, plot_summary, imdb_rating, producer_id, created_by)
    VALUES (p_title, p_release_date, p_language_id, p_duration, p_certification, p_budget, p_ott_value, p_plot, p_rating, p_producer_id, p_created_by);
    
    SET p_movie_id = LAST_INSERT_ID();
    
    INSERT INTO MOVIE_STATISTICS (movie_id, average_rating) VALUES (p_movie_id, p_rating);
    
    INSERT INTO BOX_OFFICE (movie_id, collection_status) VALUES (p_movie_id, 'pending');
    
    INSERT INTO ACTIVITY_LOG (user_id, action, table_name, record_id, details)
    VALUES (p_created_by, 'CREATE', 'MOVIES', p_movie_id, CONCAT('Movie added: ', p_title));
    
    COMMIT;
END //


-- PROCEDURE 2: Update Box Office Collections
CREATE PROCEDURE sp_update_box_office(
    IN p_movie_id INT,
    IN p_domestic DECIMAL(15,2),
    IN p_intl DECIMAL(15,2),
    IN p_opening_weekend DECIMAL(15,2),
    IN p_profit_margin DECIMAL(5,2),
    IN p_screens INT,
    IN p_updated_by INT
)
BEGIN
    DECLARE v_old_domestic DECIMAL(15,2);
    DECLARE v_old_intl DECIMAL(15,2);
    DECLARE v_old_margin DECIMAL(5,2);
    DECLARE v_box_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Unable to update box office' AS error_message;
    END;
    
    START TRANSACTION;
    
    SELECT box_id, domestic_collection, intl_collection, profit_margin 
    INTO v_box_id, v_old_domestic, v_old_intl, v_old_margin
    FROM BOX_OFFICE WHERE movie_id = p_movie_id;
    
    UPDATE BOX_OFFICE
    SET domestic_collection = p_domestic,
        intl_collection = p_intl,
        opening_weekend = p_opening_weekend,
        profit_margin = p_profit_margin,
        release_screens = p_screens,
        updated_by = p_updated_by,
        collection_status = 'updated'
    WHERE movie_id = p_movie_id;
    
    INSERT INTO BOX_OFFICE_AUDIT (box_id, movie_id, old_domestic, new_domestic, old_intl, new_intl, old_margin, new_margin, modified_by, operation_type)
    VALUES (v_box_id, p_movie_id, v_old_domestic, p_domestic, v_old_intl, p_intl, v_old_margin, p_profit_margin, (SELECT username FROM USERS WHERE user_id = p_updated_by), 'UPDATE');
    
    INSERT INTO ACTIVITY_LOG (user_id, action, table_name, record_id, details)
    VALUES (p_updated_by, 'UPDATE', 'BOX_OFFICE', p_movie_id, CONCAT('Box office updated: ', p_domestic, ' (Domestic), ', p_intl, ' (International)'));
    
    COMMIT;
END //


-- PROCEDURE 3: Add Cast to Movie
CREATE PROCEDURE sp_add_cast_to_movie(
    IN p_movie_id INT,
    IN p_actor_id INT,
    IN p_role_name VARCHAR(100),
    IN p_role_type VARCHAR(20),
    IN p_screen_time INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Unable to add cast' AS error_message;
    END;
    
    START TRANSACTION;
    
    INSERT INTO MOVIE_CAST (movie_id, actor_id, role_name, role_type, screen_time_minutes)
    VALUES (p_movie_id, p_actor_id, p_role_name, p_role_type, p_screen_time);
    
    COMMIT;
END //


-- PROCEDURE 4: Get Movie Details (Nested Query - 3 result sets)
CREATE PROCEDURE sp_get_movie_details(IN p_movie_id INT)
BEGIN
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
        GROUP_CONCAT(DISTINCT g.genre_name SEPARATOR ', ') AS genres
    FROM MOVIES m
    LEFT JOIN LANGUAGES l ON m.language_id = l.language_id
    LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
    LEFT JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
    LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
    WHERE m.movie_id = p_movie_id
    GROUP BY m.movie_id;
    
    SELECT 
        a.actor_id,
        a.name,
        mc.role_name,
        mc.role_type,
        mc.screen_time_minutes
    FROM MOVIE_CAST mc
    JOIN ACTORS a ON mc.actor_id = a.actor_id
    WHERE mc.movie_id = p_movie_id;
    
    SELECT 
        pc.crew_id,
        pc.name,
        pc.role,
        mc.role_description
    FROM MOVIE_CREW mc
    JOIN PRODUCTION_CREW pc ON mc.crew_id = pc.crew_id
    WHERE mc.movie_id = p_movie_id;
END //


-- PROCEDURE 5: Get Profit Analysis (Join Query)
CREATE PROCEDURE sp_get_profit_analysis(IN p_movie_id INT)
BEGIN
    SELECT 
        m.title,
        m.budget,
        bo.domestic_collection,
        bo.intl_collection,
        bo.total_collection,
        (bo.total_collection - m.budget) AS net_profit,
        ROUND(((bo.total_collection - m.budget) / m.budget * 100), 2) AS profit_percentage,
        bo.opening_weekend,
        bo.release_screens,
        bo.profit_margin
    FROM MOVIES m
    LEFT JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
    WHERE m.movie_id = p_movie_id;
END //


-- ========================================================
-- FUNCTIONS
-- ========================================================

-- FUNCTION 1: Calculate Experience Years
CREATE FUNCTION fn_calculate_experience(p_start_date DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN YEAR(CURDATE()) - YEAR(p_start_date);
END //


-- FUNCTION 2: Get Movie Status
CREATE FUNCTION fn_get_movie_status(p_movie_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_status VARCHAR(50);
    DECLARE v_release_date DATE;
    DECLARE v_total_collection DECIMAL(15,2);
    
    SELECT release_date INTO v_release_date FROM MOVIES WHERE movie_id = p_movie_id;
    SELECT total_collection INTO v_total_collection FROM BOX_OFFICE WHERE movie_id = p_movie_id;
    
    IF v_release_date IS NULL THEN
        SET v_status = 'Not Scheduled';
    ELSEIF v_release_date > CURDATE() THEN
        SET v_status = 'Upcoming';
    ELSEIF v_release_date = CURDATE() THEN
        SET v_status = 'Releasing Today';
    ELSEIF v_total_collection IS NULL THEN
        SET v_status = 'Released (Collection Pending)';
    ELSE
        SET v_status = 'Released';
    END IF;
    
    RETURN v_status;
END //


-- FUNCTION 3: Calculate Profit Percentage
CREATE FUNCTION fn_calculate_profit_percentage(p_budget DECIMAL(15,2), p_collection DECIMAL(15,2))
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    IF p_budget = 0 OR p_budget IS NULL THEN
        RETURN 0;
    END IF;
    RETURN ROUND(((p_collection - p_budget) / p_budget * 100), 2);
END //


-- ========================================================
-- TRIGGERS
-- ========================================================

-- TRIGGER 1: Log Movie Insertions
CREATE TRIGGER tr_movie_insert_audit
AFTER INSERT ON MOVIES
FOR EACH ROW
BEGIN
    INSERT INTO MOVIE_AUDIT (movie_id, new_title, new_budget, new_release_date, modified_by, modification_reason, operation_type)
    VALUES (NEW.movie_id, NEW.title, NEW.budget, NEW.release_date, 'System', 'Movie Created', 'INSERT');
    
    INSERT INTO ACTIVITY_LOG (user_id, action, table_name, record_id, details)
    VALUES (NEW.created_by, 'INSERT', 'MOVIES', NEW.movie_id, CONCAT('New movie created: ', NEW.title));
END //


-- TRIGGER 2: Log Movie Updates
CREATE TRIGGER tr_movie_update_audit
AFTER UPDATE ON MOVIES
FOR EACH ROW
BEGIN
    IF OLD.title != NEW.title OR OLD.budget != NEW.budget OR OLD.release_date != NEW.release_date THEN
        INSERT INTO MOVIE_AUDIT (movie_id, old_title, new_title, old_budget, new_budget, old_release_date, new_release_date, modified_by, operation_type)
        VALUES (NEW.movie_id, OLD.title, NEW.title, OLD.budget, NEW.budget, OLD.release_date, NEW.release_date, 'System', 'UPDATE');
    END IF;
END //


-- TRIGGER 3: Validate Box Office Data
CREATE TRIGGER tr_box_office_validation
BEFORE UPDATE ON BOX_OFFICE
FOR EACH ROW
BEGIN
    IF NEW.domestic_collection < 0 OR NEW.intl_collection < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Collection values cannot be negative!';
    END IF;
    
    IF NEW.profit_margin > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Profit margin cannot exceed 100%!';
    END IF;
END //


-- TRIGGER 4: Update Movie Statistics
CREATE TRIGGER tr_update_movie_stats
AFTER UPDATE ON BOX_OFFICE
FOR EACH ROW
BEGIN
    UPDATE MOVIE_STATISTICS
    SET monthly_collection = NEW.total_collection,
        last_updated = CURRENT_TIMESTAMP
    WHERE movie_id = NEW.movie_id;
END //


-- TRIGGER 5: Log Movie Deletions
CREATE TRIGGER tr_movie_delete_audit
BEFORE DELETE ON MOVIES
FOR EACH ROW
BEGIN
    INSERT INTO MOVIE_AUDIT (movie_id, old_title, old_budget, old_release_date, modified_by, modification_reason, operation_type)
    VALUES (OLD.movie_id, OLD.title, OLD.budget, OLD.release_date, 'System', 'Movie Deleted', 'DELETE');
END //

DELIMITER ;


-- ========================================================
-- VIEWS FOR REPORTING & ANALYSIS
-- ========================================================

-- VIEW 1: Movie Summary with Performance Metrics
CREATE VIEW vw_movie_summary AS
SELECT 
    m.movie_id,
    m.title,
    l.language_name,
    p.name AS producer_name,
    m.release_date,
    m.budget,
    bo.total_collection,
    bo.domestic_collection,
    bo.intl_collection,
    (bo.total_collection - m.budget) AS net_profit,
    m.imdb_rating,
    COUNT(DISTINCT mc.actor_id) AS actor_count,
    fn_get_movie_status(m.movie_id) AS movie_status
FROM MOVIES m
LEFT JOIN LANGUAGES l ON m.language_id = l.language_id
LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
LEFT JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
LEFT JOIN MOVIE_CAST mc ON m.movie_id = mc.movie_id
GROUP BY m.movie_id;


-- VIEW 2: Top Movies by Collection
CREATE VIEW vw_top_movies_by_collection AS
SELECT 
    m.title,
    l.language_name,
    m.release_date,
    bo.total_collection,
    bo.domestic_collection,
    bo.intl_collection,
    m.budget,
    ROUND(((bo.total_collection - m.budget) / m.budget * 100), 2) AS profit_percentage,
    m.imdb_rating
FROM MOVIES m
JOIN LANGUAGES l ON m.language_id = l.language_id
JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
WHERE bo.total_collection IS NOT NULL
ORDER BY bo.total_collection DESC;


-- VIEW 3: Actor Filmography
CREATE VIEW vw_actor_filmography AS
SELECT 
    a.actor_id,
    a.name,
    a.popularity_score,
    m.title AS movie_name,
    mc.role_name,
    mc.role_type,
    m.release_date,
    l.language_name
FROM ACTORS a
JOIN MOVIE_CAST mc ON a.actor_id = mc.actor_id
JOIN MOVIES m ON mc.movie_id = m.movie_id
JOIN LANGUAGES l ON m.language_id = l.language_id
ORDER BY a.actor_id, m.release_date DESC;


-- VIEW 4: Production Crew Projects
CREATE VIEW vw_production_crew_projects AS
SELECT 
    pc.crew_id,
    pc.name,
    pc.role,
    pc.experience_years,
    m.title AS movie_name,
    m.release_date,
    COUNT(DISTINCT mc.movie_id) AS total_projects
FROM PRODUCTION_CREW pc
LEFT JOIN MOVIE_CREW mc ON pc.crew_id = mc.crew_id
LEFT JOIN MOVIES m ON mc.movie_id = m.movie_id
GROUP BY pc.crew_id
ORDER BY pc.crew_id;

-- ========================================================
-- Database Created Successfully!
-- ========================================================
-- Tables: 10 main tables + supporting audit/stat tables
-- Procedures: 5 (with transactions, nested queries, joins)
-- Functions: 3 (business logic calculations)
-- Triggers: 5 (audit logging, validation, updates)
-- Views: 4 (reporting and analysis)
-- ========================================================