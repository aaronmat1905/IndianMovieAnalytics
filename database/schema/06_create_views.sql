
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