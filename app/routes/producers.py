from fastapi import APIRouter, HTTPException, status
from typing import List
from app.models.database_models import ProducerCreate, ProducerResponse
from database.connection import execute_query, call_procedure

router = APIRouter()

@router.get("/", response_model=List[ProducerResponse])
def get_all_producers():
    """Get all producers"""
    try:
        query = "SELECT * FROM PRODUCERS ORDER BY name"
        return execute_query(query)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{producer_id}", response_model=ProducerResponse)
def get_producer(producer_id: int):
    """Get a specific producer by ID"""
    try:
        query = "SELECT * FROM PRODUCERS WHERE producer_id = %s"
        results = execute_query(query, (producer_id,))
        if not results:
            raise HTTPException(status_code=404, detail="Producer not found")
        return results[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/", status_code=status.HTTP_201_CREATED)
def create_producer(producer: ProducerCreate):
    """Create a new producer"""
    try:
        query = """
            INSERT INTO PRODUCERS (name, company, phone, email, start_date)
            VALUES (%s, %s, %s, %s, %s)
        """
        params = (
            producer.name,
            producer.company,
            producer.phone,
            producer.email,
            producer.start_date,
        )
        result = execute_query(query, params, fetch=False)
        return {
            "message": "Producer created successfully",
            "producer_id": result.get("last_id"),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{producer_id}/movies")
def get_producer_movies(producer_id: int):
    """Get all movies by a producer"""
    try:
        query = """
            SELECT m.*,
                   b.total_collection,
                   GROUP_CONCAT(g.genre_name) AS genres
            FROM MOVIES m
            LEFT JOIN BOX_OFFICE b ON m.movie_id = b.movie_id
            LEFT JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
            LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
            WHERE m.producer_id = %s
            GROUP BY m.movie_id
            ORDER BY m.release_date DESC
        """
        return execute_query(query, (producer_id,))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{producer_id}/statistics")
def get_producer_statistics(producer_id: int):
    """Get producer statistics using stored procedure"""
    try:
        results = call_procedure("GetProducerStats", (producer_id,))
        if not results:
            raise HTTPException(status_code=404, detail="Producer not found")
        return results[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
