-- Insert Genres
INSERT INTO GENRES (genre_name, description) VALUES
('Action', 'High-energy films with physical stunts and chase scenes'),
('Drama', 'Character-driven stories with emotional depth'),
('Comedy', 'Humorous films designed to entertain and amuse'),
('Thriller', 'Suspenseful films that keep viewers on edge'),
('Romance', 'Love stories and romantic relationships'),
('Horror', 'Films designed to frighten and create suspense'),
('Sci-Fi', 'Science fiction with futuristic elements'),
('Biography', 'Based on real-life stories'),
('Crime', 'Films centered around criminal activities'),
('Musical', 'Films featuring songs and dance sequences');

-- Insert Producers
INSERT INTO PRODUCERS (name, company, phone, email, start_date) VALUES
('Karan Johar', 'Dharma Productions', '+91-9876543210', 'kjohar@dharma.com', '1995-01-15'),
('Yash Raj', 'Yash Raj Films', '+91-9876543211', 'contact@yrf.com', '1970-09-21'),
('Anurag Kashyap', 'Phantom Films', '+91-9876543212', 'anurag@phantom.com', '2000-03-10'),
('Sajid Nadiadwala', 'Nadiadwala Grandson', '+91-9876543213', 'sajid@ngef.com', '1993-06-15'),
('Aditya Chopra', 'Yash Raj Films', '+91-9876543214', 'aditya@yrf.com', '1992-08-20'),
('Sanjay Leela Bhansali', 'Bhansali Productions', '+91-9876543215', 'slb@bhansali.com', '1996-03-25'),
('Dinesh Vijan', 'Maddock Films', '+91-9876543216', 'dinesh@maddock.com', '2005-07-10'),
('Ronnie Screwvala', 'RSVP Movies', '+91-9876543217', 'ronnie@rsvp.com', '2017-01-05');

-- Insert Movies
INSERT INTO MOVIES (title, release_date, language, duration, certification, budget, ott_rights_value, imdb_rating, producer_id, plot_summary) VALUES
('Kabhi Khushi Kabhie Gham', '2001-12-14', 'Hindi', 210, 'U', 400000000, 150000000, 7.4, 1, 'A family drama about love, tradition, and relationships spanning across India and London'),
('Dilwale Dulhania Le Jayenge', '1995-10-20', 'Hindi', 181, 'U', 40000000, 80000000, 8.1, 2, 'A romantic story of two young Indians living in London who fall in love during a vacation'),
('Gangs of Wasseypur', '2012-06-22', 'Hindi', 321, 'A', 180000000, 90000000, 8.2, 3, 'A crime saga spanning three generations in the coal mafia of Dhanbad'),
('Baaghi 3', '2020-03-06', 'Hindi', 143, 'U/A', 950000000, 350000000, 5.3, 4, 'A man sets out to find his kidnapped brother in Syria'),
('War', '2019-10-02', 'Hindi', 156, 'U/A', 1750000000, 550000000, 6.5, 2, 'An Indian soldier is assigned to eliminate his former mentor who has gone rogue'),
('Padmaavat', '2018-01-25', 'Hindi', 164, 'U/A', 2150000000, 600000000, 7.0, 6, 'A legendary queen fights to protect her honor against a tyrant sultan'),
('Stree', '2018-08-31', 'Hindi', 128, 'U/A', 200000000, 100000000, 7.5, 7, 'A horror comedy set in a town terrorized by a mysterious female spirit'),
('Uri: The Surgical Strike', '2019-01-11', 'Hindi', 138, 'U/A', 450000000, 200000000, 8.3, 8, 'Dramatization of the 2016 surgical strikes by Indian army on terrorist camps'),
('Dangal', '2016-12-23', 'Hindi', 161, 'PG', 700000000, 350000000, 8.4, 2, 'The inspiring story of wrestler Mahavir Singh Phogat training his daughters'),
('3 Idiots', '2009-12-25', 'Hindi', 170, 'PG', 350000000, 180000000, 8.4, 1, 'Three engineering students challenge the conventional education system'),
('PK', '2014-12-19', 'Hindi', 153, 'U/A', 850000000, 400000000, 8.1, 1, 'An alien on Earth questions religious dogmas and superstitions'),
('Bajrangi Bhaijaan', '2015-07-17', 'Hindi', 163, 'U', 900000000, 450000000, 8.0, 4, 'An Indian man helps a mute Pakistani girl reunite with her family'),
('Gully Boy', '2019-02-14', 'Hindi', 154, 'U/A', 650000000, 300000000, 7.9, 3, 'A coming-of-age story about a street rapper from Mumbai slums'),
('Andhadhun', '2018-10-05', 'Hindi', 139, 'U/A', 320000000, 150000000, 8.2, 7, 'A blind pianist gets embroiled in a series of mysterious events'),
('Chhichhore', '2019-09-06', 'Hindi', 143, 'U/A', 570000000, 250000000, 8.3, 4, 'College friends reunite to help one of them cope with a personal tragedy');

-- Insert Movie-Genre relationships
INSERT INTO MOVIE_GENRES (movie_id, genre_id) VALUES
-- Kabhi Khushi Kabhie Gham
(1, 2), (1, 5),
-- DDLJ
(2, 2), (2, 5), (2, 3),
-- Gangs of Wasseypur
(3, 1), (3, 4), (3, 9),
-- Baaghi 3
(4, 1), (4, 4),
-- War
(5, 1), (5, 4),
-- Padmaavat
(6, 2), (6, 5), (6, 8),
-- Stree
(7, 3), (7, 6),
-- Uri
(8, 1), (8, 2), (8, 8),
-- Dangal
(9, 2), (9, 8),
-- 3 Idiots
(10, 3), (10, 2),
-- PK
(11, 3), (11, 2), (11, 7),
-- Bajrangi Bhaijaan
(12, 2), (12, 3), (12, 1),
-- Gully Boy
(13, 2), (13, 10),
-- Andhadhun
(14, 4), (14, 9), (14, 3),
-- Chhichhore
(15, 3), (15, 2);

-- Insert Box Office data
INSERT INTO BOX_OFFICE (movie_id, domestic_collection, intl_collection, opening_weekend, profit_margin, release_screens) VALUES
(1, 1350000000, 850000000, 250000000, 450.0, 1200),
(2, 890000000, 310000000, 45000000, 2900.0, 250),
(3, 680000000, 120000000, 85000000, 344.4, 1285),
(4, 900000000, 150000000, 530000000, 10.5, 4400),
(5, 2280000000, 950000000, 530000000, 84.6, 4000),
(6, 2820000000, 850000000, 320000000, 70.7, 4000),
(7, 1290000000, 320000000, 67000000, 705.0, 2600),
(8, 2450000000, 800000000, 350000000, 622.2, 2700),
(9, 3870000000, 5870000000, 290000000, 1291.4, 4300),
(10, 2660000000, 1400000000, 380000000, 1060.0, 2000),
(11, 4410000000, 3750000000, 950000000, 860.0, 6000),
(12, 3200000000, 6200000000, 270000000, 944.4, 5200),
(13, 1380000000, 670000000, 190000000, 215.4, 3300),
(14, 4560000000, 1290000000, 310000000, 1728.1, 1500),
(15, 1530000000, 620000000, 190000000, 277.2, 1650);