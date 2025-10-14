from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from app.models.database_models import MovieCreate, MovieResponse, MovieUpdate
from app.services.movie_service import MovieService

router = APIRouter()
movie_service = MovieService()

@router.get("/", response_model=List[MovieResponse])
def get_all_movies(skip: int = 0, limit: int = 100):
    """Get all movies with pagination"""
    try:
        movies = movie_service.get_all_movies(skip, limit)
        return movies
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{movie_id}", response_model=MovieResponse)
def get_movie(movie_id: int):
    """Get a specific movie by ID"""
    try:
        movie = movie_service.get_movie_by_id(movie_id)
        if not movie:
            raise HTTPException(status_code=404, detail="Movie not found")
        return movie
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_movie(movie: MovieCreate):
    """Create a new movie"""
    try:
        result = movie_service.create_movie(movie)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{movie_id}", response_model=dict)
def update_movie(movie_id: int, movie: MovieUpdate):
    """Update a movie"""
    try:
        result = movie_service.update_movie(movie_id, movie)
        if result["affected_rows"] == 0:
            raise HTTPException(status_code=404, detail="Movie not found")
        return {"message": "Movie updated successfully", "movie_id": movie_id}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{movie_id}", response_model=dict)
def delete_movie(movie_id: int):
    """Delete a movie"""
    try:
        result = movie_service.delete_movie(movie_id)
        if result["affected_rows"] == 0:
            raise HTTPException(status_code=404, detail="Movie not found")
        return {"message": "Movie deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/search/advanced")
def search_movies(
    title: Optional[str] = None,
    genre: Optional[str] = None,
    min_rating: Optional[float] = None,
    max_budget: Optional[float] = None
):
    """Search movies using stored procedure"""
    try:
        results = movie_service.search_movies(title, genre, min_rating, max_budget)
        return results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))