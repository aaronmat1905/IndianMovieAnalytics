@echo off
title Test Database Connection
color 0E

echo ============================================================
echo    TESTING DATABASE CONNECTION
echo ============================================================
echo.

REM Check if .env exists
if not exist ".env" (
    echo ERROR: .env file not found!
    echo.
    echo Please create it with:
    echo.
    echo DB_HOST=localhost
    echo DB_PORT=3306
    echo DB_USER=root
    echo DB_PASSWORD=YOUR_MYSQL_PASSWORD
    echo DB_NAME=indianmovies
    echo APP_HOST=0.0.0.0
    echo APP_PORT=8000
    echo DEBUG=True
    echo.
    pause
    exit /b 1
)

echo Current .env contents:
echo ----------------------------------------
type .env
echo ----------------------------------------
echo.

echo Testing connection with these settings...
echo.

python -c "import sys; from config import Settings; settings = Settings(); print(f'Host: {settings.DB_HOST}'); print(f'Port: {settings.DB_PORT}'); print(f'User: {settings.DB_USER}'); print(f'Database: {settings.DB_NAME}'); print(f'Password: {\"*\" * len(settings.DB_PASSWORD)}')" 2>nul

echo.
echo Attempting to connect...
echo.

python -c "from database.connection import get_db_connection; conn = get_db_connection(); print('SUCCESS! Database connection works!'); print(); result = conn.cursor().execute('SHOW TABLES'); tables = conn.cursor().fetchall() if result else []; print(f'Found {len(tables)} tables in database'); conn.close()" 2>error.log

if errorlevel 1 (
    echo.
    echo ============================================================
    echo    CONNECTION FAILED!
    echo ============================================================
    echo.
    type error.log
    echo.
    echo.
    echo COMMON FIXES:
    echo.
    echo 1. Check MySQL is running:
    echo    - Open MySQL Workbench
    echo    - Or open Services and start MySQL80
    echo.
    echo 2. Verify password in .env file:
    echo    - Open .env file
    echo    - Make sure DB_PASSWORD matches your MySQL password
    echo.
    echo 3. Create database if it doesn't exist:
    echo    - Run: setup_database.bat
    echo.
    del error.log
    pause
    exit /b 1
)

del error.log 2>nul

echo.
echo ============================================================
echo    CONNECTION SUCCESSFUL!
echo ============================================================
echo.
echo Your database is configured correctly!
echo You can now run: QUICK_START.bat
echo.
pause
