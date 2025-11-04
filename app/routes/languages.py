"""
Language management routes
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from app.models.database_models import Language, LanguageCreate
from database.connection import execute_query
import logging

router = APIRouter(prefix="/api/languages", tags=["languages"])
logger = logging.getLogger(__name__)


@router.get("", response_model=List[Language])
async def get_languages(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0)
):
    """Get all languages"""
    try:
        query = "SELECT * FROM LANGUAGES ORDER BY language_name LIMIT %s OFFSET %s"
        result = execute_query(query, (limit, offset), fetch=True)
        return result if result else []
    except Exception as e:
        logger.error(f"Error fetching languages: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{language_id}", response_model=Language)
async def get_language(language_id: int):
    """Get a single language by ID"""
    try:
        query = "SELECT * FROM LANGUAGES WHERE language_id = %s"
        result = execute_query(query, (language_id,), fetch=True)

        if not result:
            raise HTTPException(status_code=404, detail="Language not found")

        return result[0]
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching language {language_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("", status_code=201)
async def create_language(language: LanguageCreate):
    """Create a new language"""
    try:
        query = "INSERT INTO LANGUAGES (language_name) VALUES (%s)"
        execute_query(query, (language.language_name,), fetch=False)

        # Get the last inserted ID
        result = execute_query("SELECT LAST_INSERT_ID() as language_id", fetch=True)
        language_id = result[0]['language_id']

        return {"language_id": language_id, "message": "Language created successfully"}
    except Exception as e:
        logger.error(f"Error creating language: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{language_id}")
async def update_language(language_id: int, language: LanguageCreate):
    """Update an existing language"""
    try:
        # Check if language exists
        check_query = "SELECT language_id FROM LANGUAGES WHERE language_id = %s"
        existing = execute_query(check_query, (language_id,), fetch=True)

        if not existing:
            raise HTTPException(status_code=404, detail="Language not found")

        query = "UPDATE LANGUAGES SET language_name = %s WHERE language_id = %s"
        execute_query(query, (language.language_name, language_id), fetch=False)

        return {"message": "Language updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating language {language_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{language_id}")
async def delete_language(language_id: int):
    """Delete a language"""
    try:
        # Check if language exists
        check_query = "SELECT language_id FROM LANGUAGES WHERE language_id = %s"
        existing = execute_query(check_query, (language_id,), fetch=True)

        if not existing:
            raise HTTPException(status_code=404, detail="Language not found")

        # Delete language
        query = "DELETE FROM LANGUAGES WHERE language_id = %s"
        execute_query(query, (language_id,), fetch=False)

        return {"message": "Language deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting language {language_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
