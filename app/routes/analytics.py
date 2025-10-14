from fastapi import APIRouter, HTTPException
from database.connection import call_procedure, execute_query

router = APIRouter()

@router.get("/movie/{movie_id}")
def get_movie_analytics(movie_id: int):
    """Get complete analytics for a movie using stored procedure"""
    try:
        results = call_procedure('GetMovieAnalytics', (movie_id,))
        if not results:
            raise HTTPException(status_code=404, detail="Movie not found")
        return results[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/genres/performance")
def get_genre_performance():
    """Get genre performance statistics"""
    try:
        query = """
            SELECT 
                g.genre_name,
                COUNT(m.movie_id) as movie_count,
                AVG(m.imdb_rating) as avg_rating,
                AVG(m.budget) as avg_budget,
                AVG(b.total_collection) as avg_collection
            FROM GENRES g
            LEFT JOIN MOVIE_GENRES mg ON g.genre_id = mg.genre_id
            LEFT JOIN MOVIES m ON mg.movie_id = m.movie_id
            LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
            GROUP BY g.genre_id, g.genre_name
            HAVING movie_count > 0
            ORDER BY avg_collection DESC
        """
        return execute_query(query)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/producers/success")
def get_producer_success():
    """Get producer success analysis"""
    try:
        query = """
            SELECT 
                p.name as producer_name,
                p.company,
                COUNT(m.movie_id) as total_movies,
                AVG(m.imdb_rating) as avg_rating,
                SUM(b.total_collection) as total_earnings,
                SUM(m.budget) as total_investment
            FROM PRODUCERS p
            LEFT JOIN MOVIES m ON p.producer_id = m.producer_id
            LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
            GROUP BY p.producer_id
            HAVING total_movies > 0
            ORDER BY total_earnings DESC
        """
        return execute_query(query)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/top-grossing/{genre}")
def get_top_grossing_by_genre(genre: str):
    """Get top grossing movies by genre"""
    try:
        query = """
            SELECT m.title, b.total_collection, m.imdb_rating
            FROM MOVIES m
            JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
            JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
            JOIN GENRES g ON mg.genre_id = g.genre_id
            WHERE g.genre_name = %s
            ORDER BY b.total_collection DESC
            LIMIT 10
        """
        return execute_query(query, (genre,))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))