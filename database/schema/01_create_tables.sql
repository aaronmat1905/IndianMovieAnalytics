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
