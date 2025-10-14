"""
setup_database.py
Reads SQL files from the project's database/schema and database/queries directories and executes them
against the MySQL server configured via config.get_settings().
This implementation uses mysql.connector and supports DELIMITER sections (simple handling).
"""
import mysql.connector
from config import get_settings
import os
from pathlib import Path

settings = get_settings()

def execute_sql_file(cursor, filepath):
    """Execute SQL commands from a file. Supports simple DELIMITER handling used for procedures/functions."""
    print(f"Executing {filepath}...")
    with open(filepath, 'r', encoding='utf-8') as file:
        sql = file.read()

    # Normalize line endings
    sql = sql.replace('\r\n', '\n').replace('\r', '\n')

    # If file uses DELIMITER to define procedures, handle it.
    if 'DELIMITER' in sql:
        lines = sql.split('\n')
        parts = []
        cur = []
        delim = ';'  # default
        for line in lines:
            stripped = line.strip()
            if stripped.upper().startswith('DELIMITER'):
                # flush current buffer if exists
                if cur:
                    parts.append('\n'.join(cur).strip())
                    cur = []
                # set new delimiter
                tokens = stripped.split()
                if len(tokens) >= 2:
                    delim = tokens[1]
                else:
                    delim = ';'
                continue
            # append line to current buffer
            cur.append(line)
            # check if buffer ends with delimiter
            if cur and ''.join(cur).rstrip().endswith(delim):
                # remove delimiter from end
                combined = '\n'.join(cur).rstrip()
                combined = combined[:-len(delim)].strip()
                if combined:
                    parts.append(combined)
                cur = []
        # any remaining buffer
        if cur:
            remaining = '\n'.join(cur).strip()
            if remaining:
                parts.append(remaining)
        # Execute collected parts
        for part in parts:
            if not part.strip():
                continue
            try:
                # mysql.connector supports multi statements via cursor.execute(part, multi=True)
                for res in cursor.execute(part, multi=True):
                    # consume results to ensure execution
                    pass
            except mysql.connector.Error as e:
                print(f"Error executing part from {filepath}: {e}")
                raise
    else:
        # simple: execute the whole file supporting multiple statements
        try:
            for res in cursor.execute(sql, multi=True):
                pass
        except mysql.connector.Error as e:
            print(f"Error executing {filepath}: {e}")
            raise

def setup_database():
    """Create / initialize database by executing schema and query files in order."""
    # Build paths relative to this script -> project root -> database/
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    db_dir = project_root / "database"

    schema_dir = db_dir / "schema"
    queries_dir = db_dir / "queries"

    try:
        connection = mysql.connector.connect(
            host=settings.DB_HOST,
            port=getattr(settings, "DB_PORT", 3306),
            user=settings.DB_USER,
            password=settings.DB_PASSWORD,
            database=settings.DB_NAME,
            autocommit=False,
        )
        cursor = connection.cursor()
        # Execute schema files in ascending order (prefix numbers ensure order)
        if schema_dir.exists():
            for sql_file in sorted(schema_dir.glob("*.sql")):
                execute_sql_file(cursor, str(sql_file))

        # Execute query files (optional)
        if queries_dir.exists():
            for sql_file in sorted(queries_dir.glob("*.sql")):
                execute_sql_file(cursor, str(sql_file))

        connection.commit()
        print("\n✅ Database setup completed successfully!")

    except mysql.connector.Error as err:
        print(f"❌ Error: {err}")
        try:
            connection.rollback()
        except Exception:
            pass
        raise
    finally:
        try:
            cursor.close()
        except Exception:
            pass
        try:
            connection.close()
        except Exception:
            pass

if __name__ == "__main__":
    setup_database()
