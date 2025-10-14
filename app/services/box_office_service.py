from database.connection import execute_query, call_procedure
from app.models.database_models import BoxOfficeCreate, BoxOfficeUpdate
from typing import Optional

class BoxOfficeService:

    def get_box_office_by_movie_id(self, movie_id: int):
        query = """
            SELECT bo.*, m.title, m.budget,
                   (bo.total_collection - m.budget) as profit,
                   ROUND(((bo.total_collection - m.budget) / m.budget * 100), 2) as profit_percentage
            FROM BOX_OFFICE bo
            JOIN MOVIES m ON bo.movie_id = m.movie_id
            WHERE bo.movie_id = %s
        """
        results = execute_query(query, (movie_id,))
        return results[0] if results else None

    def create_box_office(self, box_office: BoxOfficeCreate):
        # Use stored procedure for box office creation
        try:
            result = call_procedure("sp_update_box_office", (
                box_office.movie_id, box_office.domestic_collection,
                box_office.intl_collection, box_office.opening_weekend,
                box_office.profit_margin, box_office.release_screens, 1  # 1 for updated_by (admin)
            ))
            return {"message": "Box office data created successfully", "movie_id": box_office.movie_id}
        except Exception as e:
            raise Exception(f"Failed to create box office data: {str(e)}")

    def update_box_office(self, movie_id: int, box_office: BoxOfficeUpdate):
        # Use stored procedure for box office updates
        try:
            result = call_procedure("sp_update_box_office", (
                movie_id, box_office.domestic_collection,
                box_office.intl_collection, box_office.opening_weekend,
                box_office.profit_margin, box_office.release_screens, 1  # 1 for updated_by (admin)
            ))
            return {"message": "Box office data updated successfully", "movie_id": movie_id}
        except Exception as e:
            raise Exception(f"Failed to update box office data: {str(e)}")

    def get_top_movies_by_collection(self, limit: int = 10):
        query = """
            SELECT m.title, l.language_name, m.release_date,
                   bo.total_collection, bo.domestic_collection, bo.intl_collection,
                   m.budget, ROUND(((bo.total_collection - m.budget) / m.budget * 100), 2) as profit_percentage,
                   m.imdb_rating
            FROM MOVIES m
            JOIN LANGUAGES l ON m.language_id = l.language_id
            JOIN BOX_OFFICE bo ON m.movie_id = bo.movie_id
            WHERE bo.total_collection IS NOT NULL
            ORDER BY bo.total_collection DESC
            LIMIT %s
        """
        return execute_query(query, (limit,))

    def get_profit_analysis(self, movie_id: int):
        """Get detailed profit analysis for a movie"""
        return call_procedure("sp_get_profit_analysis", (movie_id,))
