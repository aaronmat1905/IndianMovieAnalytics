from database.connection import execute_query, call_procedure
from app.models.database_models import MovieCreate, MovieUpdate
from typing import Optional

class MovieService:
    
    def get_all_movies(self, skip: int = 0, limit: int = 100):
        query = """
            SELECT m.*, p.name as producer_name
            FROM MOVIES m
            LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
            LIMIT %s OFFSET %s
        """
        return execute_query(query, (limit, skip))
    
    def get_movie_by_id(self, movie_id: int):
        query = """
            SELECT m.*, p.name as producer_name,
                   GROUP_CONCAT(g.genre_name) as genres
            FROM MOVIES m
            LEFT JOIN PRODUCERS p ON m.producer_id = p.producer_id
            LEFT JOIN MOVIE_GENRES mg ON m.movie_id = mg.movie_id
            LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
            GROUP BY m.movie_id
        """
        results = execute_query(query, (movie_id,))
        return results[0] if results else None
    
    def create_movie(self, movie: MovieCreate):
        # Use stored procedure for movie creation
        try:
            result = call_procedure("sp_add_movie", (
                movie.title, movie.release_date, movie.language_id, movie.duration,
                movie.certification, movie.budget, movie.ott_rights_value,
                movie.plot_summary, movie.imdb_rating, movie.producer_id, 1  # 1 for created_by (admin)
            ))
            movie_id = result[0]['p_movie_id'] if result else None
            
            # Insert genres if provided
            if movie.genre_ids:
                for genre_id in movie.genre_ids:
                    genre_query = "INSERT INTO MOVIE_GENRES (movie_id, genre_id) VALUES (%s, %s)"
                    execute_query(genre_query, (movie_id, genre_id), fetch=False)
            
            return {"message": "Movie created successfully", "movie_id": movie_id}
        except Exception as e:
            raise Exception(f"Failed to create movie: {str(e)}")
    
    def update_movie(self, movie_id: int, movie: MovieUpdate):
        update_fields = []
        params = []
        
        for field, value in movie.dict(exclude_unset=True).items():
            if value is not None:
                update_fields.append(f"{field} = %s")
                params.append(value)
        
        if not update_fields:
            return {"affected_rows": 0}
        
        params.append(movie_id)
        query = f"UPDATE MOVIES SET {', '.join(update_fields)} WHERE movie_id = %s"
        return execute_query(query, tuple(params), fetch=False)
    
    def delete_movie(self, movie_id: int):
        query = "DELETE FROM MOVIES WHERE movie_id = %s"
        return execute_query(query, (movie_id,), fetch=False)
    
    def search_movies(self, title: Optional[str], genre: Optional[str], 
                      min_rating: Optional[float], max_budget: Optional[float]):
        """Call SearchMovies stored procedure"""
        return call_procedure('SearchMovies', (title, genre, min_rating, max_budget))