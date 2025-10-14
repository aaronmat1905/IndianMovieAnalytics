from database.connection import execute_query
from app.models.database_models import ProducerCreate, ProducerResponse
from typing import Optional

class ProducerService:
    
    def get_all_producers(self, skip: int = 0, limit: int = 100):
        query = """
            SELECT p.*, YEAR(CURDATE()) - YEAR(p.start_date) as experience_years
            FROM PRODUCERS p
            ORDER BY p.name
            LIMIT %s OFFSET %s
        """
        return execute_query(query, (limit, skip))
    
    def get_producer_by_id(self, producer_id: int):
        query = """
            SELECT p.*, YEAR(CURDATE()) - YEAR(p.start_date) as experience_years
            FROM PRODUCERS p
            WHERE p.producer_id = %s
        """
        results = execute_query(query, (producer_id,))
        return results[0] if results else None
    
    def create_producer(self, producer: ProducerCreate):
        query = """
            INSERT INTO PRODUCERS
            (name, company, phone, email, start_date, region, created_by)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        params = (
            producer.name, producer.company, producer.phone,
            producer.email, producer.start_date, 'India', 1  # 1 for created_by (admin)
        )
        result = execute_query(query, params, fetch=False)
        return {"message": "Producer created successfully", "producer_id": result["last_id"]}
    
    def update_producer(self, producer_id: int, producer_data):
        update_fields = []
        params = []
        
        for field, value in producer_data.items():
            if value is not None:
                update_fields.append(f"{field} = %s")
                params.append(value)
        
        if not update_fields:
            return {"affected_rows": 0}
        
        params.append(producer_id)
        query = f"""
            UPDATE PRODUCERS
            SET {', '.join(update_fields)}
            WHERE producer_id = %s
        """
        
        result = execute_query(query, tuple(params), fetch=False)
        return result
    
    def delete_producer(self, producer_id: int):
        query = "DELETE FROM PRODUCERS WHERE producer_id = %s"
        return execute_query(query, (producer_id,), fetch=False)
    
    def search_producers(self, name: Optional[str] = None, company: Optional[str] = None):
        query = """
            SELECT p.*, YEAR(CURDATE()) - YEAR(p.start_date) as experience_years
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
        
        query += " ORDER BY p.name"
        return execute_query(query, tuple(params))