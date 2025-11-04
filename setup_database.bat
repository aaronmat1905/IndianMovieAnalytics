@echo off
echo ========================================
echo Indian Cinema DBMS - Database Setup
echo ========================================
echo.

REM Check if MySQL is accessible
echo Checking MySQL connection...
mysql --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: MySQL is not found in PATH!
    echo Please ensure MySQL is installed and added to system PATH.
    pause
    exit /b 1
)

echo MySQL found!
echo.

REM Prompt for MySQL password
set /p MYSQL_PASSWORD="Enter your MySQL root password: "

echo.
echo Creating database 'indianmovies'...
mysql -u root -p%MYSQL_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS indianmovies;" 2>nul
if errorlevel 1 (
    echo ERROR: Failed to create database. Please check your password.
    pause
    exit /b 1
)

echo Database created successfully!
echo.

REM Navigate to schema directory
cd database\schema

echo ========================================
echo Running SQL Scripts...
echo ========================================
echo.

echo [1/6] Creating tables...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 01_create_tables.sql
if errorlevel 1 (
    echo ERROR: Failed to create tables!
    pause
    exit /b 1
)
echo Tables created successfully!

echo [2/6] Inserting sample data...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 02_insert_data.sql
if errorlevel 1 (
    echo ERROR: Failed to insert data!
    pause
    exit /b 1
)
echo Sample data inserted successfully!

echo [3/6] Creating triggers...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 03_create_triggers.sql
if errorlevel 1 (
    echo ERROR: Failed to create triggers!
    pause
    exit /b 1
)
echo Triggers created successfully!

echo [4/6] Creating stored procedures...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 04_create_procedures.sql
if errorlevel 1 (
    echo ERROR: Failed to create procedures!
    pause
    exit /b 1
)
echo Procedures created successfully!

echo [5/6] Creating functions...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 05_create_functions.sql
if errorlevel 1 (
    echo ERROR: Failed to create functions!
    pause
    exit /b 1
)
echo Functions created successfully!

echo [6/6] Creating views...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 06_create_views.sql
if errorlevel 1 (
    echo ERROR: Failed to create views!
    pause
    exit /b 1
)
echo Views created successfully!

cd ..\..

echo.
echo ========================================
echo Database Setup Complete!
echo ========================================
echo.
echo Database 'indianmovies' has been created with:
echo   - 15 Tables
echo   - 14 Triggers
echo   - 10 Stored Procedures
echo   - 10 Functions
echo   - 4 Views
echo.

REM Update .env file
echo Updating .env file with database password...
(
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=%MYSQL_PASSWORD%
echo DB_NAME=indianmovies
echo APP_HOST=0.0.0.0
echo APP_PORT=8000
echo DEBUG=True
) > .env

echo .env file updated!
echo.

echo You can now run 'start_backend.bat' to start the backend server.
echo.
pause
