from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from decimal import Decimal
from typing import Optional
from database.connection import execute_query

router = APIRouter()

class BoxOfficeCreate(BaseModel):
    movie_id: int
    domestic_collection: Optional[Decimal] = None
    intl_collection: Optional[Decimal] = None
    opening_weekend: Optional[Decimal] = None
    profit_margin: Optional[Decimal] = None
    release_screens: Optional[int] = None

@router.get("/{movie_id}")
def get_box_office(movie_id: int):
    """Get box office data for a movie"""
    try:
        query = """
            SELECT bo.*, m.title, m.budget,
                   (bo.total_collection - m.budget) as profit
            FROM BOX_OFFICE bo
            JOIN MOVIES m ON bo.movie_id = m.movie_id
            WHERE bo.movie_id = %s
        """
        results = execute_query(query, (movie_id,))
        if not results:
            raise HTTPException(status_code=404, detail="Box office data not found")
        return results[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", status_code=status.HTTP_201_CREATED)
def create_box_office(box_office: BoxOfficeCreate):
    """Add box office data for a movie"""
    try:
        query = """
            INSERT INTO BOX_OFFICE 
            (movie_id, domestic_collection, intl_collection, 
             opening_weekend, profit_margin, release_screens)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        params = (box_office.movie_id, box_office.domestic_collection,
                 box_office.intl_collection, box_office.opening_weekend,
                 box_office.profit_margin, box_office.release_screens)
        result = execute_query(query, params, fetch=False)
        return {"message": "Box office data added successfully", 
                "box_id": result["last_id"]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/top/domestic")
def get_top_domestic():
    """Get top movies by domestic collection"""
    try:
        query = """
            SELECT m.title, bo.domestic_collection, m.imdb_rating,
                   p.name as producer_name
            FROM BOX_OFFICE bo
            JOIN MOVIES m ON bo.movie_id = m.movie_id
            LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
            ORDER BY bo.domestic_collection DESC
            LIMIT 10
        """
        return execute_query(query)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/top/worldwide")
def get_top_worldwide():
    """Get top movies by total worldwide collection"""
    try:
        query = """
            SELECT m.title, bo.total_collection, m.budget,
                   (bo.total_collection - m.budget) as profit,
                   p.name as producer_name,
                   m.imdb_rating
            FROM BOX_OFFICE bo
            JOIN MOVIES m ON bo.movie_id = m.movie_id
            LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
            ORDER BY bo.total_collection DESC
            LIMIT 10
        """
        return execute_query(query)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))