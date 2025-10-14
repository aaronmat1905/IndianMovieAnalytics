from fastapi import APIRouter, HTTPException
from typing import List, Optional
from ..models.database_models import BoxOffice, BoxOfficeCreate
from database.connection import execute_query, call_procedure

router = APIRouter()

@router.get("/box-office", response_model=List[BoxOffice])
async def get_box_office_records(
    skip: int = 0,
    limit: int = 100,
    movie_id: Optional[int] = None,
    collection_status: Optional[str] = None
):
    """Get all box office records with optional filtering"""
    query = """
    SELECT bo.box_id, bo.movie_id, bo.domestic_collection, bo.intl_collection,
           bo.opening_weekend, bo.total_collection, bo.profit_margin,
           bo.release_screens, bo.collection_status, bo.updated_by,
           bo.created_at, bo.updated_at
    FROM BOX_OFFICE bo
    WHERE 1=1
    """
    params = []

    if movie_id:
        query += " AND bo.movie_id = %s"
        params.append(movie_id)
    if collection_status:
        query += " AND bo.collection_status = %s"
        params.append(collection_status)

    query += " ORDER BY bo.created_at DESC LIMIT %s OFFSET %s"
    params.extend([limit, skip])

    try:
        records = execute_query(query, tuple(params))
        return records
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/box-office/{box_id}", response_model=BoxOffice)
async def get_box_office_record(box_id: int):
    """Get a specific box office record by ID"""
    query = """
    SELECT bo.box_id, bo.movie_id, bo.domestic_collection, bo.intl_collection,
           bo.opening_weekend, bo.total_collection, bo.profit_margin,
           bo.release_screens, bo.collection_status, bo.updated_by,
           bo.created_at, bo.updated_at
    FROM BOX_OFFICE bo
    WHERE bo.box_id = %s
    """

    try:
        record = execute_query(query, (box_id,))
        if not record:
            raise HTTPException(status_code=404, detail="Box office record not found")
        return record[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/box-office", response_model=dict)
async def create_box_office_record(box_office: BoxOfficeCreate):
    """Create a new box office record"""
    # Check if movie exists
    movie_exists = execute_query("SELECT movie_id FROM MOVIES WHERE movie_id = %s", (box_office.movie_id,))
    if not movie_exists:
        raise HTTPException(status_code=404, detail="Movie not found")

    # Check if box office record already exists for this movie
    existing_record = execute_query("SELECT box_id FROM BOX_OFFICE WHERE movie_id = %s", (box_office.movie_id,))
    if existing_record:
        raise HTTPException(status_code=400, detail="Box office record already exists for this movie")

    query = """
    INSERT INTO BOX_OFFICE (movie_id, domestic_collection, intl_collection,
                           opening_weekend, profit_margin, release_screens,
                           collection_status, updated_by)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """

    try:
        result = execute_query(query, (
            box_office.movie_id,
            box_office.domestic_collection,
            box_office.intl_collection,
            box_office.opening_weekend,
            box_office.profit_margin,
            box_office.release_screens,
            box_office.collection_status,
            box_office.updated_by
        ), fetch=False)

        return {"box_id": result["last_id"], "message": "Box office record created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/box-office/{box_id}", response_model=dict)
async def update_box_office_record(box_id: int, box_office: BoxOfficeCreate):
    """Update an existing box office record"""
    # Check if record exists
    existing_record = execute_query("SELECT box_id FROM BOX_OFFICE WHERE box_id = %s", (box_id,))
    if not existing_record:
        raise HTTPException(status_code=404, detail="Box office record not found")

    update_fields = []
    params = []

    # Build dynamic update query
    if box_office.domestic_collection is not None:
        update_fields.append("domestic_collection = %s")
        params.append(box_office.domestic_collection)
    if box_office.intl_collection is not None:
        update_fields.append("intl_collection = %s")
        params.append(box_office.intl_collection)
    if box_office.opening_weekend is not None:
        update_fields.append("opening_weekend = %s")
        params.append(box_office.opening_weekend)
    if box_office.profit_margin is not None:
        update_fields.append("profit_margin = %s")
        params.append(box_office.profit_margin)
    if box_office.release_screens is not None:
        update_fields.append("release_screens = %s")
        params.append(box_office.release_screens)
    if box_office.collection_status is not None:
        update_fields.append("collection_status = %s")
        params.append(box_office.collection_status)

    if not update_fields:
        raise HTTPException(status_code=400, detail="No fields to update")

    update_fields.append("updated_by = %s")
    params.append(box_office.updated_by)
    update_fields.append("updated_at = CURRENT_TIMESTAMP")
    params.append(box_id)

    query = f"UPDATE BOX_OFFICE SET {', '.join(update_fields)} WHERE box_id = %s"

    try:
        execute_query(query, tuple(params), fetch=False)
        return {"message": "Box office record updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/box-office/{box_id}", response_model=dict)
async def delete_box_office_record(box_id: int):
    """Delete a box office record"""
    # Check if record exists
    existing_record = execute_query("SELECT box_id FROM BOX_OFFICE WHERE box_id = %s", (box_id,))
    if not existing_record:
        raise HTTPException(status_code=404, detail="Box office record not found")

    try:
        execute_query("DELETE FROM BOX_OFFICE WHERE box_id = %s", (box_id,), fetch=False)
        return {"message": "Box office record deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/movies/{movie_id}/box-office", response_model=BoxOffice)
async def get_movie_box_office(movie_id: int):
    """Get box office record for a specific movie"""
    query = """
    SELECT bo.box_id, bo.movie_id, bo.domestic_collection, bo.intl_collection,
           bo.opening_weekend, bo.total_collection, bo.profit_margin,
           bo.release_screens, bo.collection_status, bo.updated_by,
           bo.created_at, bo.updated_at
    FROM BOX_OFFICE bo
    WHERE bo.movie_id = %s
    """

    try:
        record = execute_query(query, (movie_id,))
        if not record:
            raise HTTPException(status_code=404, detail="Box office record not found for this movie")
        return record[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/top-movies", response_model=List[dict])
async def get_top_movies_by_collection(limit: int = 10):
    """Get top movies by total collection"""
    query = """
    SELECT m.title, l.language_name, m.release_date, bo.total_collection,
           bo.domestic_collection, bo.intl_collection, m.budget,
           ROUND(((bo.total_collection - m.budget) / m.budget * 100), 2) AS profit_percentage,
           m.imdb_rating
    FROM MOVIES m
    JOIN LANGUAGES l ON m.language_id = l.language_id
    JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
    WHERE bo.total_collection IS NOT NULL
    ORDER BY bo.total_collection DESC
    LIMIT %s
    """

    try:
        movies = execute_query(query, (limit,))
        return movies
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/profit-analysis", response_model=List[dict])
async def get_profit_analysis(limit: int = 10):
    """Get movies with highest profit margins"""
    query = """
    SELECT m.title, m.budget, bo.total_collection,
           (bo.total_collection - m.budget) AS net_profit,
           ROUND(((bo.total_collection - m.budget) / m.budget * 100), 2) AS profit_percentage,
           bo.opening_weekend, bo.release_screens, bo.profit_margin
    FROM MOVIES m
    JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
    WHERE m.budget > 0 AND bo.total_collection IS NOT NULL
    ORDER BY profit_percentage DESC
    LIMIT %s
    """

    try:
        analysis = execute_query(query, (limit,))
        return analysis
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))