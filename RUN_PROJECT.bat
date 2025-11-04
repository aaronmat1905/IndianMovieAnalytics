@echo off
title Indian Cinema DBMS - Complete Setup and Launch
color 0A

:MENU
cls
echo ============================================================
echo    INDIAN CINEMA DBMS - ONE-CLICK LAUNCHER
echo ============================================================
echo.
echo    [1] FIRST TIME SETUP (Complete Installation)
echo    [2] START APPLICATION (Backend + Frontend)
echo    [3] INSTALL DEPENDENCIES ONLY
echo    [4] SETUP DATABASE ONLY
echo    [5] TEST CONNECTIONS
echo    [6] START BACKEND ONLY
echo    [7] START FRONTEND ONLY
echo    [8] OPEN BROWSER
echo    [9] EXIT
echo.
echo ============================================================
set /p choice="Enter your choice (1-9): "

if "%choice%"=="1" goto FULL_SETUP
if "%choice%"=="2" goto START_ALL
if "%choice%"=="3" goto INSTALL_DEPS
if "%choice%"=="4" goto SETUP_DB
if "%choice%"=="5" goto TEST_CONN
if "%choice%"=="6" goto START_BACKEND
if "%choice%"=="7" goto START_FRONTEND
if "%choice%"=="8" goto OPEN_BROWSER
if "%choice%"=="9" goto EXIT
goto MENU

REM ============================================================
REM FIRST TIME SETUP
REM ============================================================
:FULL_SETUP
cls
echo ============================================================
echo    FIRST TIME SETUP - COMPLETE INSTALLATION
echo ============================================================
echo.
echo This will:
echo   1. Check Python installation
echo   2. Install all Python dependencies
echo   3. Setup MySQL database
echo   4. Create all tables, triggers, procedures, functions
echo   5. Start the application
echo.
pause

REM Check Python
echo.
echo [1/5] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Python is not installed or not in PATH!
    echo.
    echo Please install Python 3.10+ from: https://www.python.org/
    echo Make sure to check "Add Python to PATH" during installation!
    pause
    goto MENU
)
python --version
echo Python: OK
timeout /t 2 /nobreak >nul

REM Install Dependencies
echo.
echo [2/5] Installing Python dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo.
    echo ERROR: Failed to install dependencies!
    pause
    goto MENU
)
echo Dependencies installed successfully!
timeout /t 2 /nobreak >nul

REM Check MySQL
echo.
echo [3/5] Checking MySQL installation...
mysql --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: MySQL is not installed or not in PATH!
    echo.
    echo Please install MySQL 8.0+ from: https://dev.mysql.com/downloads/
    echo And add MySQL bin folder to system PATH!
    pause
    goto MENU
)
mysql --version
echo MySQL: OK
timeout /t 2 /nobreak >nul

REM Setup Database
echo.
echo [4/5] Setting up database...
set /p MYSQL_PASSWORD="Enter your MySQL root password: "

echo Creating database...
mysql -u root -p%MYSQL_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS indianmovies;" 2>nul
if errorlevel 1 (
    echo.
    echo ERROR: Failed to create database. Please check your password!
    pause
    goto MENU
)

cd database\schema

echo Running SQL scripts...
echo   - Creating tables...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 01_create_tables.sql
if errorlevel 1 (
    echo ERROR: Failed to create tables!
    pause
    goto MENU
)

echo   - Inserting sample data...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 02_insert_data.sql

echo   - Creating triggers...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 03_create_triggers.sql

echo   - Creating stored procedures...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 04_create_procedures.sql

echo   - Creating functions...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 05_create_functions.sql

echo   - Creating views...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 06_create_views.sql

cd ..\..

echo.
echo Updating .env file...
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

echo.
echo ============================================================
echo    SETUP COMPLETE!
echo ============================================================
echo.
echo Database 'indianmovies' created with:
echo   - 15 Tables
echo   - 14 Triggers
echo   - 10 Stored Procedures
echo   - 10 Functions
echo   - 4 Views
echo.
echo [5/5] Starting the application...
timeout /t 3 /nobreak >nul
goto START_ALL

REM ============================================================
REM START ALL SERVICES
REM ============================================================
:START_ALL
cls
echo ============================================================
echo    STARTING APPLICATION
echo ============================================================
echo.

REM Check if .env exists
if not exist ".env" (
    echo WARNING: .env file not found!
    echo Please run FIRST TIME SETUP (Option 1) first.
    pause
    goto MENU
)

echo Starting Backend Server...
start "Indian Cinema DBMS - Backend" cmd /c "color 0B && echo Backend Server Starting... && echo. && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 && pause"

echo Waiting for backend to initialize...
timeout /t 5 /nobreak >nul

echo Starting Frontend Server...
cd frontend
start "Indian Cinema DBMS - Frontend" cmd /c "color 0E && echo Frontend Server Starting... && echo. && python -m http.server 3000 && pause"
cd ..

echo Waiting for frontend to start...
timeout /t 3 /nobreak >nul

echo.
echo ============================================================
echo    APPLICATION STARTED SUCCESSFULLY!
echo ============================================================
echo.
echo Backend:      http://localhost:8000
echo API Docs:     http://localhost:8000/docs
echo Health Check: http://localhost:8000/health
echo.
echo Frontend:     http://localhost:3000
echo.
echo Opening browser in 3 seconds...
timeout /t 3 /nobreak >nul

start http://localhost:3000

echo.
echo Browser opened!
echo.
echo To STOP servers: Close both terminal windows
echo.
pause
goto MENU

REM ============================================================
REM INSTALL DEPENDENCIES ONLY
REM ============================================================
:INSTALL_DEPS
cls
echo ============================================================
echo    INSTALLING DEPENDENCIES
echo ============================================================
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
    echo Please install Python 3.10+ from: https://www.python.org/
    pause
    goto MENU
)

echo Python version:
python --version
echo.

echo Installing packages from requirements.txt...
pip install -r requirements.txt

if errorlevel 1 (
    echo.
    echo ERROR: Installation failed!
    pause
    goto MENU
)

echo.
echo ============================================================
echo    INSTALLATION COMPLETE!
echo ============================================================
echo.
echo Installed packages:
pip list | findstr "fastapi uvicorn mysql pydantic dotenv"
echo.
pause
goto MENU

REM ============================================================
REM SETUP DATABASE ONLY
REM ============================================================
:SETUP_DB
cls
echo ============================================================
echo    DATABASE SETUP
echo ============================================================
echo.

mysql --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: MySQL not found in PATH!
    pause
    goto MENU
)

set /p MYSQL_PASSWORD="Enter your MySQL root password: "

echo.
echo Creating database 'indianmovies'...
mysql -u root -p%MYSQL_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS indianmovies;" 2>nul
if errorlevel 1 (
    echo ERROR: Failed to create database!
    pause
    goto MENU
)

echo Database created!
echo.

cd database\schema

echo Running SQL scripts...
echo [1/6] Creating tables...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 01_create_tables.sql

echo [2/6] Inserting sample data...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 02_insert_data.sql

echo [3/6] Creating triggers...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 03_create_triggers.sql

echo [4/6] Creating stored procedures...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 04_create_procedures.sql

echo [5/6] Creating functions...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 05_create_functions.sql

echo [6/6] Creating views...
mysql -u root -p%MYSQL_PASSWORD% indianmovies < 06_create_views.sql

cd ..\..

echo.
echo Updating .env file...
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

echo.
echo ============================================================
echo    DATABASE SETUP COMPLETE!
echo ============================================================
echo.
pause
goto MENU

REM ============================================================
REM TEST CONNECTIONS
REM ============================================================
:TEST_CONN
cls
echo ============================================================
echo    CONNECTION TESTS
echo ============================================================
echo.

echo [1] Testing Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo    Python: NOT FOUND
) else (
    python --version
    echo    Python: OK
)

echo.
echo [2] Testing MySQL...
mysql --version >nul 2>&1
if errorlevel 1 (
    echo    MySQL: NOT FOUND
) else (
    mysql --version
    echo    MySQL: OK
)

echo.
echo [3] Testing .env file...
if exist ".env" (
    echo    .env: EXISTS
) else (
    echo    .env: NOT FOUND
)

echo.
echo [4] Testing Python packages...
pip show fastapi >nul 2>&1
if errorlevel 1 (
    echo    FastAPI: NOT INSTALLED
) else (
    echo    FastAPI: OK
)

pip show uvicorn >nul 2>&1
if errorlevel 1 (
    echo    Uvicorn: NOT INSTALLED
) else (
    echo    Uvicorn: OK
)

pip show mysql-connector-python >nul 2>&1
if errorlevel 1 (
    echo    MySQL Connector: NOT INSTALLED
) else (
    echo    MySQL Connector: OK
)

echo.
echo [5] Testing Backend Server...
curl -s http://localhost:8000/health >nul 2>&1
if errorlevel 1 (
    echo    Backend: NOT RUNNING
) else (
    echo    Backend: RUNNING
    curl http://localhost:8000/health
)

echo.
echo ============================================================
echo    TEST COMPLETE
echo ============================================================
echo.
pause
goto MENU

REM ============================================================
REM START BACKEND ONLY
REM ============================================================
:START_BACKEND
cls
echo ============================================================
echo    STARTING BACKEND SERVER
echo ============================================================
echo.

if not exist ".env" (
    echo ERROR: .env file not found!
    echo Please run SETUP DATABASE (Option 4) first.
    pause
    goto MENU
)

echo Starting FastAPI Backend...
echo.
echo Backend will be available at:
echo   - http://localhost:8000
echo   - http://localhost:8000/docs (API Documentation)
echo.
echo Press Ctrl+C to stop the server
echo.

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

pause
goto MENU

REM ============================================================
REM START FRONTEND ONLY
REM ============================================================
:START_FRONTEND
cls
echo ============================================================
echo    STARTING FRONTEND SERVER
echo ============================================================
echo.

cd frontend

echo Starting Frontend HTTP Server...
echo.
echo Frontend will be available at: http://localhost:3000
echo.
echo IMPORTANT: Make sure backend is running first!
echo.
echo Press Ctrl+C to stop the server
echo.

python -m http.server 3000

cd ..
pause
goto MENU

REM ============================================================
REM OPEN BROWSER
REM ============================================================
:OPEN_BROWSER
cls
echo Opening browser...
start http://localhost:3000
timeout /t 2 /nobreak >nul
goto MENU

REM ============================================================
REM EXIT
REM ============================================================
:EXIT
cls
echo.
echo Thank you for using Indian Cinema DBMS!
echo.
timeout /t 2 /nobreak >nul
exit
