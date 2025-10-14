-- Complex Query 1: Top Grossing Movies by Genre
SELECT g.genre_name, m.title, b.total_collection
FROM MOVIES m
JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
JOIN GENRES g ON mg.genre_id = g.genre_id
WHERE b.total_collection = (
    SELECT MAX(b2.total_collection)
    FROM BOX_OFFICE b2
    JOIN MOVIE_GENRES mg2 ON b2.movie_id = mg2.movie_id
    WHERE mg2.genre_id = mg.genre_id
);

-- Complex Query 2: Producer Success Analysis with Rankings
SELECT 
    p.name as producer_name,
    p.company,
    COUNT(m.movie_id) as total_movies,
    AVG(m.imdb_rating) as avg_rating,
    SUM(b.total_collection) as total_earnings,
    SUM(m.budget) as total_investment,
    (SUM(b.total_collection) - SUM(m.budget)) as net_profit,
    RANK() OVER (ORDER BY SUM(b.total_collection) DESC) as earnings_rank
FROM PRODUCERS p
LEFT JOIN MOVIES m ON p.producer_id = m.producer_id
LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
GROUP BY p.producer_id, p.name, p.company
HAVING total_movies > 0
ORDER BY net_profit DESC;

-- Complex Query 3: Movies with Above Average Performance
SELECT 
    m.title,
    m.budget,
    b.total_collection,
    CalculateProfitPercentage(m.budget, b.total_collection) as profit_pct,
    m.imdb_rating
FROM MOVIES m
JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
WHERE b.total_collection > (
    SELECT AVG(total_collection) FROM BOX_OFFICE
)
AND m.imdb_rating > (
    SELECT AVG(imdb_rating) FROM MOVIES WHERE imdb_rating IS NOT NULL
)
ORDER BY profit_pct DESC;

-- Complex Query 4: Genre Co-occurrence Analysis
SELECT 
    g1.genre_name as genre1,
    g2.genre_name as genre2,
    COUNT(*) as co_occurrence_count,
    AVG(m.imdb_rating) as avg_rating
FROM MOVIE_GENRES mg1
JOIN MOVIE_GENRES mg2 ON mg1.movie_id = mg2.movie_id AND mg1.genre_id < mg2.genre_id
JOIN GENRES g1 ON mg1.genre_id = g1.genre_id
JOIN GENRES g2 ON mg2.genre_id = g2.genre_id
JOIN MOVIES m ON mg1.movie_id = m.movie_id
GROUP BY g1.genre_id, g2.genre_id
HAVING co_occurrence_count > 1
ORDER BY co_occurrence_count DESC;

-- Complex Query 5: Year-wise Box Office Trends
SELECT 
    YEAR(m.release_date) as release_year,
    COUNT(m.movie_id) as movies_released,
    AVG(m.imdb_rating) as avg_rating,
    SUM(b.total_collection) as total_collection,
    AVG(b.total_collection) as avg_collection_per_movie,
    MAX(b.total_collection) as highest_grosser
FROM MOVIES m
LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
WHERE m.release_date IS NOT NULL
GROUP BY YEAR(m.release_date)
ORDER BY release_year DESC;

-- Complex Query 6: Movies with Multiple Genres Performance
SELECT 
    m.title,
    COUNT(DISTINCT mg.genre_id) as genre_count,
    GROUP_CONCAT(DISTINCT g.genre_name) as genres,
    m.imdb_rating,
    b.total_collection,
    GetRatingCategory(m.imdb_rating) as rating_category
FROM MOVIES m
JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
JOIN GENRES g ON mg.genre_id = g.genre_id
LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
GROUP BY m.movie_id
HAVING genre_count >= 2
ORDER BY b.total_collection DESC;