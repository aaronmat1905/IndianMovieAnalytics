"""
Actor management routes
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from app.models.database_models import Actor, ActorCreate
from database.connection import execute_query, call_procedure
import logging

router = APIRouter(prefix="/api/actors", tags=["actors"])
logger = logging.getLogger(__name__)


@router.get("", response_model=List[Actor])
async def get_actors(
    name: Optional[str] = Query(None, description="Filter by actor name"),
    gender: Optional[str] = Query(None, description="Filter by gender"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0)
):
    """Get all actors with optional filters"""
    try:
        query = "SELECT * FROM ACTORS WHERE 1=1"
        params = []

        if name:
            query += " AND name LIKE %s"
            params.append(f"%{name}%")

        if gender:
            query += " AND gender = %s"
            params.append(gender)

        query += " ORDER BY actor_id DESC LIMIT %s OFFSET %s"
        params.extend([limit, offset])

        result = execute_query(query, tuple(params), fetch=True)
        return result if result else []
    except Exception as e:
        logger.error(f"Error fetching actors: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{actor_id}", response_model=Actor)
async def get_actor(actor_id: int):
    """Get a single actor by ID"""
    try:
        query = "SELECT * FROM ACTORS WHERE actor_id = %s"
        result = execute_query(query, (actor_id,), fetch=True)

        if not result:
            raise HTTPException(status_code=404, detail="Actor not found")

        return result[0]
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching actor {actor_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("", status_code=201)
async def create_actor(actor: ActorCreate):
    """Create a new actor"""
    try:
        query = """
        INSERT INTO ACTORS (name, gender, date_of_birth, nationality, popularity_score, email)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        params = (
            actor.name,
            actor.gender,
            actor.date_of_birth,
            actor.nationality,
            actor.popularity_score,
            actor.email
        )

        execute_query(query, params, fetch=False)

        # Get the last inserted ID
        result = execute_query("SELECT LAST_INSERT_ID() as actor_id", fetch=True)
        actor_id = result[0]['actor_id']

        return {"actor_id": actor_id, "message": "Actor created successfully"}
    except Exception as e:
        logger.error(f"Error creating actor: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{actor_id}")
async def update_actor(actor_id: int, actor: ActorCreate):
    """Update an existing actor"""
    try:
        # Check if actor exists
        check_query = "SELECT actor_id FROM ACTORS WHERE actor_id = %s"
        existing = execute_query(check_query, (actor_id,), fetch=True)

        if not existing:
            raise HTTPException(status_code=404, detail="Actor not found")

        # Build dynamic update query
        update_fields = []
        params = []

        if actor.name is not None:
            update_fields.append("name = %s")
            params.append(actor.name)

        if actor.gender is not None:
            update_fields.append("gender = %s")
            params.append(actor.gender)

        if actor.date_of_birth is not None:
            update_fields.append("date_of_birth = %s")
            params.append(actor.date_of_birth)

        if actor.nationality is not None:
            update_fields.append("nationality = %s")
            params.append(actor.nationality)

        if actor.popularity_score is not None:
            update_fields.append("popularity_score = %s")
            params.append(actor.popularity_score)

        if actor.email is not None:
            update_fields.append("email = %s")
            params.append(actor.email)

        if not update_fields:
            raise HTTPException(status_code=400, detail="No fields to update")

        params.append(actor_id)
        query = f"UPDATE ACTORS SET {', '.join(update_fields)} WHERE actor_id = %s"

        execute_query(query, tuple(params), fetch=False)

        return {"message": "Actor updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating actor {actor_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{actor_id}")
async def delete_actor(actor_id: int):
    """Delete an actor"""
    try:
        # Check if actor exists
        check_query = "SELECT actor_id FROM ACTORS WHERE actor_id = %s"
        existing = execute_query(check_query, (actor_id,), fetch=True)

        if not existing:
            raise HTTPException(status_code=404, detail="Actor not found")

        # Delete actor
        query = "DELETE FROM ACTORS WHERE actor_id = %s"
        execute_query(query, (actor_id,), fetch=False)

        return {"message": "Actor deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting actor {actor_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{actor_id}/filmography")
async def get_actor_filmography(actor_id: int):
    """Get actor's filmography using the view"""
    try:
        query = """
        SELECT * FROM vw_actor_filmography
        WHERE actor_id = %s
        ORDER BY release_date DESC
        """
        result = execute_query(query, (actor_id,), fetch=True)

        return result if result else []
    except Exception as e:
        logger.error(f"Error fetching filmography for actor {actor_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
