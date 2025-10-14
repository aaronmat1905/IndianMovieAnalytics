from fastapi import APIRouter, HTTPException
from typing import List
from database.connection import execute_query

router = APIRouter()

@router.get("/")
def get_all_genres():
    """Get all genres"""
    try:
        query = "SELECT * FROM GENRES ORDER BY genre_name"
        return execute_query(query)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{genre_id}")
def get_genre(genre_id: int):
    """Get a specific genre by ID"""
    try:
        query = "SELECT * FROM GENRES WHERE genre_id = %s"
        results = execute_query(query, (genre_id,))
        if not results:
            raise HTTPException(status_code=404, detail="Genre not found")
        return results[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{genre_id}/movies")
def get_genre_movies(genre_id: int):
    """Get all movies of a specific genre"""
    try:
        query = """
            SELECT m.*, b.total_collection,
                   GROUP_CONCAT(DISTINCT g2.genre_name) as all_genres
            FROM MOVIES m
            JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
            LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
            LEFT JOIN MOVIE_GENRES mg2 ON m.movie_id = mg2.movie_id
            LEFT JOIN GENRES g2 ON mg2.genre_id = g2.genre_id
            WHERE mg.genre_id = %s
            GROUP BY m.movie_id
            ORDER BY b.total_collection DESC
        """
        return execute_query(query, (genre_id,))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/statistics/all")
def get_genre_statistics():
    """Get statistics for all genres"""
    try:
        query = "SELECT * FROM GenreStatistics ORDER BY total_collection DESC"
        return execute_query(query)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))