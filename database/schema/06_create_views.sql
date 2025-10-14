-- View 1: Movie Summary View
CREATE OR REPLACE VIEW MovieSummary AS
SELECT 
    m.movie_id,
    m.title,
    m.release_date,
    m.duration,
    m.certification,
    m.imdb_rating,
    p.name as producer,
    p.company as production_house,
    GROUP_CONCAT(DISTINCT g.genre_name ORDER BY g.genre_name) as genres,
    b.total_collection,
    GetRatingCategory(m.imdb_rating) as rating_category,
    CalculateProfitPercentage(m.budget, b.total_collection) as profit_percentage
FROM MOVIES m
LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
LEFT JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
GROUP BY m.movie_id;

-- View 2: High Performing Movies
CREATE OR REPLACE VIEW HighPerformingMovies AS
SELECT 
    m.movie_id,
    m.title,
    m.imdb_rating,
    b.total_collection,
    (b.total_collection - m.budget) as profit,
    p.name as producer_name
FROM MOVIES m
JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
JOIN PRODUCERS p ON m.producer_id = p.producer_id
WHERE m.imdb_rating >= 8.0 
  AND b.total_collection > m.budget * 2
ORDER BY b.total_collection DESC;

-- View 3: Genre Statistics
CREATE OR REPLACE VIEW GenreStatistics AS
SELECT 
    g.genre_name,
    COUNT(DISTINCT m.movie_id) as movie_count,
    AVG(m.imdb_rating) as avg_rating,
    SUM(b.total_collection) as total_collection,
    AVG(b.total_collection) as avg_collection_per_movie
FROM GENRES g
LEFT JOIN MOVIE_GENRES mg ON g.genre_id = mg.genre_id
LEFT JOIN MOVIES m ON mg.movie_id = m.movie_id
LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
GROUP BY g.genre_id, g.genre_name
HAVING movie_count > 0;