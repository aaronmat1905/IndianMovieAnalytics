@echo off
title Indian Cinema DBMS - Launcher
color 0A

echo ============================================================
echo    INDIAN CINEMA DBMS - DATABASE MANAGEMENT SYSTEM
echo ============================================================
echo.

REM Clear any environment variables that might override .env file
set DB_HOST=
set DB_PORT=
set DB_USER=
set DB_PASSWORD=
set DB_NAME=

REM Check Python installation
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found!
    echo Please install Python 3.10+ from https://www.python.org/
    echo.
    pause
    exit /b 1
)

echo [OK] Python found
python --version
echo.

REM Check if .env file exists
if not exist ".env" (
    echo [ERROR] .env file not found!
    echo.
    echo Please create .env file with your MySQL credentials:
    echo.
    echo DB_HOST=localhost
    echo DB_PORT=3306
    echo DB_USER=root
    echo DB_PASSWORD=your_mysql_password_here
    echo DB_NAME=indianmovies
    echo APP_HOST=0.0.0.0
    echo APP_PORT=8001
    echo DEBUG=True
    echo.
    pause
    exit /b 1
)

echo [OK] .env file found
echo.

REM Test database connection
echo Testing database connection...
python -c "import sys; sys.path.insert(0, '.'); from config import Settings; from database.connection import get_db_connection; conn = get_db_connection(); print('[OK] Database connection successful!'); conn.close()" 2>nul
if errorlevel 1 (
    echo.
    echo [ERROR] Database connection failed!
    echo.
    echo Common issues:
    echo   1. MySQL is not running
    echo   2. Wrong password in .env file
    echo   3. Database 'indianmovies' does not exist
    echo.
    echo To fix:
    echo   - Start MySQL (check MySQL Workbench or Services)
    echo   - Verify password in .env file
    echo   - Create database if needed: CREATE DATABASE indianmovies;
    echo.
    pause
    exit /b 1
)

echo [OK] Database connection successful!
echo.

echo ============================================================
echo    STARTING APPLICATION SERVERS
echo ============================================================
echo.

REM Start Backend Server on port 8001
echo [1/2] Starting Backend API Server (Port 8001)...
start "Backend API - http://localhost:8001" cmd /c "color 0B && title Backend Server && echo Indian Cinema DBMS - Backend Server && echo. && echo Starting backend on port 8001... && echo. && set DB_HOST= && set DB_PORT= && set DB_USER= && set DB_PASSWORD= && set DB_NAME= && python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 && pause"

echo       Waiting for backend to start (8 seconds)...
timeout /t 8 /nobreak >nul

REM Test if backend is running
curl -s http://localhost:8001/health >nul 2>&1
if errorlevel 1 (
    echo       [WARNING] Backend may not have started yet
    echo       Check the Backend window for errors
    timeout /t 3 /nobreak >nul
) else (
    echo       [OK] Backend is running!
)

echo.

REM Start Frontend Server on port 3000
echo [2/2] Starting Frontend Web Server (Port 3000)...
start "Frontend UI - http://localhost:3000" cmd /c "color 0E && title Frontend Server && echo Indian Cinema DBMS - Frontend Server && echo. && echo Starting frontend on port 3000... && echo. && cd frontend && python -m http.server 3000 && pause"

echo       Waiting for frontend to start (3 seconds)...
timeout /t 3 /nobreak >nul

echo.
echo ============================================================
echo    APPLICATION STARTED SUCCESSFULLY!
echo ============================================================
echo.
echo Backend API:      http://localhost:8001
echo API Docs:         http://localhost:8001/docs
echo Health Check:     http://localhost:8001/health
echo.
echo Frontend UI:      http://localhost:3000
echo.
echo Opening browser in 2 seconds...
timeout /t 2 /nobreak >nul

REM Open browser
start http://localhost:3000

echo.
echo ============================================================
echo    APPLICATION IS RUNNING
echo ============================================================
echo.
echo Two server windows are now open:
echo   [1] Backend Server - FastAPI on port 8001
echo   [2] Frontend Server - HTTP Server on port 3000
echo.
echo To STOP the application:
echo   - Close both server windows
echo   - Or press Ctrl+C in each window
echo.
echo This launcher window can be closed now.
echo The application will continue running in the other windows.
echo.
echo Enjoy using Indian Cinema DBMS!
echo.
pause
