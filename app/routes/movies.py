from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from ..models.database_models import Movie, MovieCreate, MovieStatistics
from database.connection import execute_query, call_procedure

router = APIRouter()

@router.get("/movies", response_model=List[Movie])
async def get_movies(
    skip: int = 0,
    limit: int = 100,
    title: Optional[str] = None,
    language_id: Optional[int] = None,
    producer_id: Optional[int] = None
):
    """Get all movies with optional filtering"""
    query = """
    SELECT m.movie_id, m.title, m.release_date, m.language_id, m.duration,
           m.certification, m.budget, m.ott_rights_value, m.poster_url,
           m.plot_summary, m.imdb_rating, m.producer_id, m.created_by,
           m.created_at, m.updated_at
    FROM MOVIES m
    WHERE 1=1
    """
    params = []

    if title:
        query += " AND m.title LIKE %s"
        params.append(f"%{title}%")
    if language_id:
        query += " AND m.language_id = %s"
        params.append(language_id)
    if producer_id:
        query += " AND m.producer_id = %s"
        params.append(producer_id)

    query += " ORDER BY m.created_at DESC LIMIT %s OFFSET %s"
    params.extend([limit, skip])

    try:
        movies = execute_query(query, tuple(params))
        return movies
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/movies/{movie_id}", response_model=Movie)
async def get_movie(movie_id: int):
    """Get a specific movie by ID"""
    query = """
    SELECT m.movie_id, m.title, m.release_date, m.language_id, m.duration,
           m.certification, m.budget, m.ott_rights_value, m.poster_url,
           m.plot_summary, m.imdb_rating, m.producer_id, m.created_by,
           m.created_at, m.updated_at
    FROM MOVIES m
    WHERE m.movie_id = %s
    """

    try:
        movie = execute_query(query, (movie_id,))
        if not movie:
            raise HTTPException(status_code=404, detail="Movie not found")
        return movie[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/movies", response_model=dict)
async def create_movie(movie: MovieCreate):
    """Create a new movie"""
    try:
        # Use stored procedure to create movie
        result = call_procedure("sp_add_movie", (
            movie.title,
            movie.release_date,
            movie.language_id,
            movie.duration,
            movie.certification,
            movie.budget,
            movie.ott_rights_value,
            movie.plot_summary,
            movie.imdb_rating,
            movie.producer_id,
            movie.created_by
        ))

        if result and len(result) > 0:
            movie_id = result[0][0] if len(result[0]) > 0 else None
            return {"movie_id": movie_id, "message": "Movie created successfully"}
        else:
            raise HTTPException(status_code=500, detail="Failed to create movie")

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/movies/{movie_id}", response_model=dict)
async def update_movie(movie_id: int, movie: MovieCreate):
    """Update an existing movie"""
    # Check if movie exists
    existing_movie = execute_query("SELECT movie_id FROM MOVIES WHERE movie_id = %s", (movie_id,))
    if not existing_movie:
        raise HTTPException(status_code=404, detail="Movie not found")

    update_fields = []
    params = []

    # Build dynamic update query
    if movie.title is not None:
        update_fields.append("title = %s")
        params.append(movie.title)
    if movie.release_date is not None:
        update_fields.append("release_date = %s")
        params.append(movie.release_date)
    if movie.language_id is not None:
        update_fields.append("language_id = %s")
        params.append(movie.language_id)
    if movie.duration is not None:
        update_fields.append("duration = %s")
        params.append(movie.duration)
    if movie.certification is not None:
        update_fields.append("certification = %s")
        params.append(movie.certification)
    if movie.budget is not None:
        update_fields.append("budget = %s")
        params.append(movie.budget)
    if movie.ott_rights_value is not None:
        update_fields.append("ott_rights_value = %s")
        params.append(movie.ott_rights_value)
    if movie.poster_url is not None:
        update_fields.append("poster_url = %s")
        params.append(movie.poster_url)
    if movie.plot_summary is not None:
        update_fields.append("plot_summary = %s")
        params.append(movie.plot_summary)
    if movie.imdb_rating is not None:
        update_fields.append("imdb_rating = %s")
        params.append(movie.imdb_rating)
    if movie.producer_id is not None:
        update_fields.append("producer_id = %s")
        params.append(movie.producer_id)

    if not update_fields:
        raise HTTPException(status_code=400, detail="No fields to update")

    update_fields.append("updated_at = CURRENT_TIMESTAMP")
    params.append(movie_id)

    query = f"UPDATE MOVIES SET {', '.join(update_fields)} WHERE movie_id = %s"

    try:
        execute_query(query, tuple(params), fetch=False)
        return {"message": "Movie updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/movies/{movie_id}", response_model=dict)
async def delete_movie(movie_id: int):
    """Delete a movie"""
    # Check if movie exists
    existing_movie = execute_query("SELECT movie_id FROM MOVIES WHERE movie_id = %s", (movie_id,))
    if not existing_movie:
        raise HTTPException(status_code=404, detail="Movie not found")

    try:
        execute_query("DELETE FROM MOVIES WHERE movie_id = %s", (movie_id,), fetch=False)
        return {"message": "Movie deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/movies/{movie_id}/details", response_model=dict)
async def get_movie_details(movie_id: int):
    """Get detailed movie information including cast and crew"""
    try:
        # Use stored procedure to get movie details
        result = call_procedure("sp_get_movie_details", (movie_id,))

        if not result or len(result) == 0:
            raise HTTPException(status_code=404, detail="Movie not found")

        # The stored procedure returns 3 result sets: movie info, cast, crew
        movie_info = result[0] if len(result) > 0 else []
        cast_info = result[1] if len(result) > 1 else []
        crew_info = result[2] if len(result) > 2 else []

        return {
            "movie": movie_info[0] if movie_info else {},
            "cast": cast_info,
            "crew": crew_info
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/movies/{movie_id}/profit-analysis", response_model=dict)
async def get_profit_analysis(movie_id: int):
    """Get profit analysis for a movie"""
    try:
        # Use stored procedure to get profit analysis
        result = call_procedure("sp_get_profit_analysis", (movie_id,))

        if not result or len(result) == 0:
            raise HTTPException(status_code=404, detail="Movie not found")

        return result[0]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))