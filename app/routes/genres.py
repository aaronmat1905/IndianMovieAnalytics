from fastapi import APIRouter, HTTPException
from typing import List, Optional
from ..models.database_models import Genre, GenreCreate
from database.connection import execute_query

router = APIRouter()

@router.get("/genres", response_model=List[Genre])
async def get_genres(
    skip: int = 0,
    limit: int = 100,
    genre_name: Optional[str] = None
):
    """Get all genres with optional filtering"""
    query = """
    SELECT g.genre_id, g.genre_name, g.description, g.created_at
    FROM GENRES g
    WHERE 1=1
    """
    params = []

    if genre_name:
        query += " AND g.genre_name LIKE %s"
        params.append(f"%{genre_name}%")

    query += " ORDER BY g.created_at DESC LIMIT %s OFFSET %s"
    params.extend([limit, skip])

    try:
        genres = execute_query(query, tuple(params))
        return genres
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/genres/{genre_id}", response_model=Genre)
async def get_genre(genre_id: int):
    """Get a specific genre by ID"""
    query = """
    SELECT g.genre_id, g.genre_name, g.description, g.created_at
    FROM GENRES g
    WHERE g.genre_id = %s
    """

    try:
        genre = execute_query(query, (genre_id,))
        if not genre:
            raise HTTPException(status_code=404, detail="Genre not found")
        return genre[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/genres", response_model=dict)
async def create_genre(genre: GenreCreate):
    """Create a new genre"""
    query = """
    INSERT INTO GENRES (genre_name, description)
    VALUES (%s, %s)
    """

    try:
        result = execute_query(query, (genre.genre_name, genre.description), fetch=False)
        return {"genre_id": result["last_id"], "message": "Genre created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/genres/{genre_id}", response_model=dict)
async def update_genre(genre_id: int, genre: GenreCreate):
    """Update an existing genre"""
    # Check if genre exists
    existing_genre = execute_query("SELECT genre_id FROM GENRES WHERE genre_id = %s", (genre_id,))
    if not existing_genre:
        raise HTTPException(status_code=404, detail="Genre not found")

    update_fields = []
    params = []

    # Build dynamic update query
    if genre.genre_name is not None:
        update_fields.append("genre_name = %s")
        params.append(genre.genre_name)
    if genre.description is not None:
        update_fields.append("description = %s")
        params.append(genre.description)

    if not update_fields:
        raise HTTPException(status_code=400, detail="No fields to update")

    params.append(genre_id)
    query = f"UPDATE GENRES SET {', '.join(update_fields)} WHERE genre_id = %s"

    try:
        execute_query(query, tuple(params), fetch=False)
        return {"message": "Genre updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/genres/{genre_id}", response_model=dict)
async def delete_genre(genre_id: int):
    """Delete a genre"""
    # Check if genre exists
    existing_genre = execute_query("SELECT genre_id FROM GENRES WHERE genre_id = %s", (genre_id,))
    if not existing_genre:
        raise HTTPException(status_code=404, detail="Genre not found")

    try:
        execute_query("DELETE FROM GENRES WHERE genre_id = %s", (genre_id,), fetch=False)
        return {"message": "Genre deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))