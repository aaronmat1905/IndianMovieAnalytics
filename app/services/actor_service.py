from database.connection import execute_query
from app.models.database_models import ActorCreate, ActorUpdate
from typing import Optional

class ActorService:

    def get_all_actors(self, skip: int = 0, limit: int = 100):
        query = """
            SELECT a.*
            FROM ACTORS a
            ORDER BY a.name
            LIMIT %s OFFSET %s
        """
        return execute_query(query, (limit, skip))

    def get_actor_by_id(self, actor_id: int):
        query = "SELECT * FROM ACTORS WHERE actor_id = %s"
        results = execute_query(query, (actor_id,))
        return results[0] if results else None

    def create_actor(self, actor: ActorCreate):
        query = """
            INSERT INTO ACTORS
            (name, gender, date_of_birth, nationality, popularity_score, email)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        params = (
            actor.name, actor.gender, actor.date_of_birth,
            actor.nationality, actor.popularity_score, actor.email
        )
        result = execute_query(query, params, fetch=False)
        return {"message": "Actor created successfully", "actor_id": result["last_id"]}

    def update_actor(self, actor_id: int, actor: ActorUpdate):
        update_fields = []
        params = []

        for field, value in actor.dict(exclude_unset=True).items():
            if value is not None:
                update_fields.append(f"{field} = %s")
                params.append(value)

        if not update_fields:
            return {"affected_rows": 0}

        params.append(actor_id)
        query = f"""
            UPDATE ACTORS
            SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP
            WHERE actor_id = %s
        """

        result = execute_query(query, tuple(params), fetch=False)
        return result

    def delete_actor(self, actor_id: int):
        query = "DELETE FROM ACTORS WHERE actor_id = %s"
        return execute_query(query, (actor_id,), fetch=False)

    def search_actors(self, name: Optional[str] = None, nationality: Optional[str] = None):
        query = """
            SELECT a.* FROM ACTORS a
            WHERE 1=1
        """
        params = []

        if name:
            query += " AND a.name LIKE %s"
            params.append(f"%{name}%")
        if nationality:
            query += " AND a.nationality LIKE %s"
            params.append(f"%{nationality}%")

        query += " ORDER BY a.name"
        return execute_query(query, tuple(params))
