from database.connection import execute_query
from app.models.database_models import LanguageCreate
from typing import Optional

class LanguageService:

    def get_all_languages(self, skip: int = 0, limit: int = 100):
        query = """
            SELECT l.*
            FROM LANGUAGES l
            ORDER BY l.language_name
            LIMIT %s OFFSET %s
        """
        return execute_query(query, (limit, skip))

    def get_language_by_id(self, language_id: int):
        query = "SELECT * FROM LANGUAGES WHERE language_id = %s"
        results = execute_query(query, (language_id,))
        return results[0] if results else None

    def create_language(self, language: LanguageCreate):
        query = """
            INSERT INTO LANGUAGES
            (language_name, description)
            VALUES (%s, %s)
        """
        params = (language.language_name, language.description)
        result = execute_query(query, params, fetch=False)
        return {"message": "Language created successfully", "language_id": result["last_id"]}

    def update_language(self, language_id: int, language_data):
        update_fields = []
        params = []

        for field, value in language_data.items():
            if value is not None:
                update_fields.append(f"{field} = %s")
                params.append(value)

        if not update_fields:
            return {"affected_rows": 0}

        params.append(language_id)
        query = f"""
            UPDATE LANGUAGES
            SET {', '.join(update_fields)}
            WHERE language_id = %s
        """

        result = execute_query(query, tuple(params), fetch=False)
        return result

    def delete_language(self, language_id: int):
        query = "DELETE FROM LANGUAGES WHERE language_id = %s"
        return execute_query(query, (language_id,), fetch=False)

    def search_languages(self, name: Optional[str] = None):
        query = """
            SELECT l.* FROM LANGUAGES l
            WHERE 1=1
        """
        params = []

        if name:
            query += " AND l.language_name LIKE %s"
            params.append(f"%{name}%")

        query += " ORDER BY l.language_name"
        return execute_query(query, tuple(params))
