from database.connection import execute_query
from app.models.database_models import GenreCreate
from typing import Optional

class GenreService:

    def get_all_genres(self, skip: int = 0, limit: int = 100):
        query = """
            SELECT g.*
            FROM GENRES g
            ORDER BY g.genre_name
            LIMIT %s OFFSET %s
        """
        return execute_query(query, (limit, skip))

    def get_genre_by_id(self, genre_id: int):
        query = "SELECT * FROM GENRES WHERE genre_id = %s"
        results = execute_query(query, (genre_id,))
        return results[0] if results else None

    def create_genre(self, genre: GenreCreate):
        query = """
            INSERT INTO GENRES
            (genre_name, description)
            VALUES (%s, %s)
        """
        params = (genre.genre_name, genre.description)
        result = execute_query(query, params, fetch=False)
        return {"message": "Genre created successfully", "genre_id": result["last_id"]}

    def update_genre(self, genre_id: int, genre_data):
        update_fields = []
        params = []

        for field, value in genre_data.items():
            if value is not None:
                update_fields.append(f"{field} = %s")
                params.append(value)

        if not update_fields:
            return {"affected_rows": 0}

        params.append(genre_id)
        query = f"""
            UPDATE GENRES
            SET {', '.join(update_fields)}
            WHERE genre_id = %s
        """

        result = execute_query(query, tuple(params), fetch=False)
        return result

    def delete_genre(self, genre_id: int):
        query = "DELETE FROM GENRES WHERE genre_id = %s"
        return execute_query(query, (genre_id,), fetch=False)

    def search_genres(self, name: Optional[str] = None):
        query = """
            SELECT g.* FROM GENRES g
            WHERE 1=1
        """
        params = []

        if name:
            query += " AND g.genre_name LIKE %s"
            params.append(f"%{name}%")

        query += " ORDER BY g.genre_name"
        return execute_query(query, tuple(params))
