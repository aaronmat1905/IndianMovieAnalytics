"""
Production Crew management routes
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from app.models.database_models import ProductionCrew, ProductionCrewCreate
from database.connection import execute_query
import logging

router = APIRouter(prefix="/api/crew", tags=["crew"])
logger = logging.getLogger(__name__)


@router.get("", response_model=List[ProductionCrew])
async def get_crew_members(
    name: Optional[str] = Query(None, description="Filter by crew member name"),
    role: Optional[str] = Query(None, description="Filter by role"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0)
):
    """Get all crew members with optional filters"""
    try:
        query = "SELECT * FROM PRODUCTION_CREW WHERE 1=1"
        params = []

        if name:
            query += " AND name LIKE %s"
            params.append(f"%{name}%")

        if role:
            query += " AND role = %s"
            params.append(role)

        query += " ORDER BY crew_id DESC LIMIT %s OFFSET %s"
        params.extend([limit, offset])

        result = execute_query(query, tuple(params), fetch=True)
        return result if result else []
    except Exception as e:
        logger.error(f"Error fetching crew members: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{crew_id}", response_model=ProductionCrew)
async def get_crew_member(crew_id: int):
    """Get a single crew member by ID"""
    try:
        query = "SELECT * FROM PRODUCTION_CREW WHERE crew_id = %s"
        result = execute_query(query, (crew_id,), fetch=True)

        if not result:
            raise HTTPException(status_code=404, detail="Crew member not found")

        return result[0]
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching crew member {crew_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("", status_code=201)
async def create_crew_member(crew: ProductionCrewCreate):
    """Create a new crew member"""
    try:
        query = """
        INSERT INTO PRODUCTION_CREW (name, role, specialty, experience_years, email)
        VALUES (%s, %s, %s, %s, %s)
        """
        params = (
            crew.name,
            crew.role,
            crew.specialty,
            crew.experience_years,
            crew.email
        )

        execute_query(query, params, fetch=False)

        # Get the last inserted ID
        result = execute_query("SELECT LAST_INSERT_ID() as crew_id", fetch=True)
        crew_id = result[0]['crew_id']

        return {"crew_id": crew_id, "message": "Crew member created successfully"}
    except Exception as e:
        logger.error(f"Error creating crew member: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{crew_id}")
async def update_crew_member(crew_id: int, crew: ProductionCrewCreate):
    """Update an existing crew member"""
    try:
        # Check if crew member exists
        check_query = "SELECT crew_id FROM PRODUCTION_CREW WHERE crew_id = %s"
        existing = execute_query(check_query, (crew_id,), fetch=True)

        if not existing:
            raise HTTPException(status_code=404, detail="Crew member not found")

        # Build dynamic update query
        update_fields = []
        params = []

        if crew.name is not None:
            update_fields.append("name = %s")
            params.append(crew.name)

        if crew.role is not None:
            update_fields.append("role = %s")
            params.append(crew.role)

        if crew.specialty is not None:
            update_fields.append("specialty = %s")
            params.append(crew.specialty)

        if crew.experience_years is not None:
            update_fields.append("experience_years = %s")
            params.append(crew.experience_years)

        if crew.email is not None:
            update_fields.append("email = %s")
            params.append(crew.email)

        if not update_fields:
            raise HTTPException(status_code=400, detail="No fields to update")

        params.append(crew_id)
        query = f"UPDATE PRODUCTION_CREW SET {', '.join(update_fields)} WHERE crew_id = %s"

        execute_query(query, tuple(params), fetch=False)

        return {"message": "Crew member updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating crew member {crew_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{crew_id}")
async def delete_crew_member(crew_id: int):
    """Delete a crew member"""
    try:
        # Check if crew member exists
        check_query = "SELECT crew_id FROM PRODUCTION_CREW WHERE crew_id = %s"
        existing = execute_query(check_query, (crew_id,), fetch=True)

        if not existing:
            raise HTTPException(status_code=404, detail="Crew member not found")

        # Delete crew member
        query = "DELETE FROM PRODUCTION_CREW WHERE crew_id = %s"
        execute_query(query, (crew_id,), fetch=False)

        return {"message": "Crew member deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting crew member {crew_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{crew_id}/projects")
async def get_crew_projects(crew_id: int):
    """Get crew member's project history using the view"""
    try:
        query = """
        SELECT * FROM vw_production_crew_projects
        WHERE crew_id = %s
        ORDER BY crew_id
        """
        result = execute_query(query, (crew_id,), fetch=True)

        return result if result else []
    except Exception as e:
        logger.error(f"Error fetching projects for crew member {crew_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
