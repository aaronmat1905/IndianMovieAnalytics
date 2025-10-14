from fastapi import APIRouter, HTTPException
from typing import List, Optional
from ..models.database_models import Producer, ProducerCreate
from database.connection import execute_query

router = APIRouter()

@router.get("/producers", response_model=List[Producer])
async def get_producers(
    skip: int = 0,
    limit: int = 100,
    name: Optional[str] = None,
    company: Optional[str] = None,
    region: Optional[str] = None
):
    """Get all producers with optional filtering"""
    query = """
    SELECT p.producer_id, p.name, p.company, p.phone, p.email,
           p.start_date, p.region, p.created_by, p.created_at
    FROM PRODUCERS p
    WHERE 1=1
    """
    params = []

    if name:
        query += " AND p.name LIKE %s"
        params.append(f"%{name}%")
    if company:
        query += " AND p.company LIKE %s"
        params.append(f"%{company}%")
    if region:
        query += " AND p.region LIKE %s"
        params.append(f"%{region}%")

    query += " ORDER BY p.created_at DESC LIMIT %s OFFSET %s"
    params.extend([limit, skip])

    try:
        producers = execute_query(query, tuple(params))
        return producers
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/producers/{producer_id}", response_model=Producer)
async def get_producer(producer_id: int):
    """Get a specific producer by ID"""
    query = """
    SELECT p.producer_id, p.name, p.company, p.phone, p.email,
           p.start_date, p.region, p.created_by, p.created_at
    FROM PRODUCERS p
    WHERE p.producer_id = %s
    """

    try:
        producer = execute_query(query, (producer_id,))
        if not producer:
            raise HTTPException(status_code=404, detail="Producer not found")
        return producer[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/producers", response_model=dict)
async def create_producer(producer: ProducerCreate):
    """Create a new producer"""
    query = """
    INSERT INTO PRODUCERS (name, company, phone, email, start_date, region, created_by)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
    """

    try:
        result = execute_query(query, (
            producer.name,
            producer.company,
            producer.phone,
            producer.email,
            producer.start_date,
            producer.region,
            producer.created_by
        ), fetch=False)

        return {"producer_id": result["last_id"], "message": "Producer created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/producers/{producer_id}", response_model=dict)
async def update_producer(producer_id: int, producer: ProducerCreate):
    """Update an existing producer"""
    # Check if producer exists
    existing_producer = execute_query("SELECT producer_id FROM PRODUCERS WHERE producer_id = %s", (producer_id,))
    if not existing_producer:
        raise HTTPException(status_code=404, detail="Producer not found")

    update_fields = []
    params = []

    # Build dynamic update query
    if producer.name is not None:
        update_fields.append("name = %s")
        params.append(producer.name)
    if producer.company is not None:
        update_fields.append("company = %s")
        params.append(producer.company)
    if producer.phone is not None:
        update_fields.append("phone = %s")
        params.append(producer.phone)
    if producer.email is not None:
        update_fields.append("email = %s")
        params.append(producer.email)
    if producer.start_date is not None:
        update_fields.append("start_date = %s")
        params.append(producer.start_date)
    if producer.region is not None:
        update_fields.append("region = %s")
        params.append(producer.region)

    if not update_fields:
        raise HTTPException(status_code=400, detail="No fields to update")

    params.append(producer_id)
    query = f"UPDATE PRODUCERS SET {', '.join(update_fields)} WHERE producer_id = %s"

    try:
        execute_query(query, tuple(params), fetch=False)
        return {"message": "Producer updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/producers/{producer_id}", response_model=dict)
async def delete_producer(producer_id: int):
    """Delete a producer"""
    # Check if producer exists
    existing_producer = execute_query("SELECT producer_id FROM PRODUCERS WHERE producer_id = %s", (producer_id,))
    if not existing_producer:
        raise HTTPException(status_code=404, detail="Producer not found")

    try:
        execute_query("DELETE FROM PRODUCERS WHERE producer_id = %s", (producer_id,), fetch=False)
        return {"message": "Producer deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))