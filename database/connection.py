import mysql.connector
from mysql.connector import pooling
from config import get_settings
import logging

settings = get_settings()
logger = logging.getLogger(__name__)

# Create connection pool
connection_pool = pooling.MySQLConnectionPool(
    pool_name="movie_db_pool",
    pool_size=5,
    pool_reset_session=True,
    host=settings.DB_HOST,
    port=settings.DB_PORT,
    user=settings.DB_USER,
    password=settings.DB_PASSWORD,
    database=settings.DB_NAME,
    ssl_disabled=True
)

def get_db_connection():
    """Get a connection from the pool"""
    try:
        connection = connection_pool.get_connection()
        return connection
    except mysql.connector.Error as err:
        logger.error(f"Error getting connection: {err}")
        raise

def execute_query(query, params=None, fetch=True):
    """Execute a query and return results"""
    connection = get_db_connection()
    cursor = None
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute(query, params or ())
        
        if fetch:
            result = cursor.fetchall()
            return result
        else:
            connection.commit()
            return {"affected_rows": cursor.rowcount, "last_id": cursor.lastrowid}
    except mysql.connector.Error as err:
        logger.error(f"Database error: {err}")
        connection.rollback()
        raise
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

def call_procedure(proc_name, params=None):
    """Call a stored procedure"""
    connection = get_db_connection()
    cursor = None
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc(proc_name, params or ())
        
        # Fetch all result sets
        results = []
        for result in cursor.stored_results():
            results.extend(result.fetchall())
        
        return results
    except mysql.connector.Error as err:
        logger.error(f"Procedure error: {err}")
        raise
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()