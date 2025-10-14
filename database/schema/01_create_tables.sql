-- Drop existing tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS MOVIE_AUDIT;
DROP TABLE IF EXISTS BOX_OFFICE;
DROP TABLE IF EXISTS MOVIE_GENRES;
DROP TABLE IF EXISTS MOVIES;
DROP TABLE IF EXISTS GENRES;
DROP TABLE IF EXISTS PRODUCERS;

-- Create PRODUCERS table
CREATE TABLE PRODUCERS (
    producer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    company VARCHAR(150),
    phone VARCHAR(15),
    email VARCHAR(100),
    start_date DATE,
    experience_years INT AS (YEAR(CURRENT_DATE) - YEAR(start_date)) STORED,
    UNIQUE(email),
    CHECK(phone REGEXP '^[0-9+\\-\\s()]+$')
);

CREATE INDEX idx_producer_name ON PRODUCERS(name);
CREATE INDEX idx_company ON PRODUCERS(company);

-- Create GENRES table
CREATE TABLE GENRES (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Create MOVIES table
CREATE TABLE MOVIES (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    release_date DATE,
    language VARCHAR(50),
    duration INT CHECK(duration > 0),
    certification VARCHAR(10),
    budget DECIMAL(15,2),
    ott_rights_value DECIMAL(15,2),
    poster_url VARCHAR(500),
    plot_summary TEXT,
    imdb_rating DECIMAL(3,1) CHECK(imdb_rating >= 0 AND imdb_rating <= 10),
    producer_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producer_id) REFERENCES PRODUCERS(producer_id)
);

CREATE INDEX idx_title ON MOVIES(title);
CREATE INDEX idx_release_date ON MOVIES(release_date);

-- Create MOVIE_GENRES junction table
CREATE TABLE MOVIE_GENRES (
    movie_id INT,
    genre_id INT,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES GENRES(genre_id)
);

-- Create BOX_OFFICE table
CREATE TABLE BOX_OFFICE (
    box_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT UNIQUE NOT NULL,
    domestic_collection DECIMAL(15,2),
    intl_collection DECIMAL(15,2),
    opening_weekend DECIMAL(15,2),
    total_collection DECIMAL(15,2) AS (domestic_collection + intl_collection) STORED,
    profit_margin DECIMAL(5,2),
    release_screens INT,
    FOREIGN KEY (movie_id) REFERENCES MOVIES(movie_id) ON DELETE CASCADE
);

-- Create MOVIE_AUDIT table for triggers
CREATE TABLE MOVIE_AUDIT (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT,
    old_title VARCHAR(200),
    new_title VARCHAR(200),
    old_budget DECIMAL(15,2),
    new_budget DECIMAL(15,2),
    modified_by VARCHAR(100),
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);