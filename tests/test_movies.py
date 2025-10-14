import pytest
from database.connection import execute_query

def test_get_all_movies():
    """Test retrieving all movies"""
    query = "SELECT COUNT(*) as count FROM MOVIES"
    result = execute_query(query)
    assert result[0]['count'] > 0

def test_get_movie_by_id():
    """Test retrieving a specific movie"""
    query = "SELECT * FROM MOVIES WHERE movie_id = 1"
    result = execute_query(query)
    assert len(result) == 1
    assert result[0]['title'] is not None

def test_profit_calculation():
    """Test profit calculation function"""
    query = "SELECT CalculateProfitPercentage(1000000, 2000000) as profit_pct"
    result = execute_query(query)
    # allow float comparison tolerance
    assert abs(float(result[0]['profit_pct']) - 100.0) < 1e-6

def test_rating_category():
    """Test rating categorization function"""
    query = "SELECT GetRatingCategory(8.5) as category"
    result = execute_query(query)
    assert result[0]['category'] == 'Excellent'

if __name__ == "__main__":
    pytest.main([__file__])
