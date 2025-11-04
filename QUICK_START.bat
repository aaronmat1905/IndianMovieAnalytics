@echo off
title Indian Cinema DBMS - Quick Launcher
color 0A

echo ============================================================
echo    INDIAN CINEMA DBMS - QUICK START
echo ============================================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
    echo Please install Python 3.10+ from https://www.python.org/
    pause
    exit /b 1
)

echo [OK] Python found
python --version

REM Check if .env exists
if not exist ".env" (
    echo.
    echo ERROR: .env file not found!
    echo Please create .env file with your MySQL password.
    pause
    exit /b 1
)

echo [OK] .env file found
echo.

REM Test database connection first
echo Testing database connection...
python -c "from database.connection import get_db_connection; conn = get_db_connection(); print('[OK] Database connection successful!'); conn.close()" 2>error.log
if errorlevel 1 (
    echo.
    echo ============================================================
    echo    DATABASE CONNECTION FAILED!
    echo ============================================================
    echo.
    echo The error is usually one of these:
    echo   1. MySQL is not running
    echo   2. Wrong password in .env file
    echo   3. Database 'indianmovies' does not exist
    echo.
    echo Error details:
    type error.log
    echo.
    echo.
    echo TO FIX:
    echo   1. Make sure MySQL is running
    echo   2. Check your MySQL password is correct in .env file
    echo   3. Run: setup_database.bat to create the database
    echo.
    pause
    del error.log
    exit /b 1
)

del error.log 2>nul
echo [OK] Database connection successful!
echo.

echo ============================================================
echo    STARTING SERVERS...
echo ============================================================
echo.

REM Start backend in new window (clear environment variables first)
echo Starting Backend Server (Port 8000)...
start "DBMS Backend - http://localhost:8000" /MIN cmd /c "color 0B && title Backend Server && echo Starting Backend... && echo. && set DB_HOST= && set DB_PORT= && set DB_USER= && set DB_PASSWORD= && set DB_NAME= && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload && pause"

REM Wait for backend to start
echo Waiting for backend to initialize (10 seconds)...
timeout /t 10 /nobreak >nul

REM Test backend
echo Testing backend...
curl -s http://localhost:8000/health >nul 2>&1
if errorlevel 1 (
    echo WARNING: Backend may not have started yet
    echo Check the Backend window for errors
    timeout /t 5 /nobreak >nul
) else (
    echo [OK] Backend is running!
)

echo.

REM Start frontend in new window
echo Starting Frontend Server (Port 3000)...
cd frontend
start "DBMS Frontend - http://localhost:3000" /MIN cmd /c "color 0E && title Frontend Server && echo Starting Frontend... && echo. && python -m http.server 3000 && pause"
cd ..

REM Wait for frontend
echo Waiting for frontend to start (3 seconds)...
timeout /t 3 /nobreak >nul

echo.
echo ============================================================
echo    SERVERS STARTED!
echo ============================================================
echo.
echo Backend:      http://localhost:8000
echo API Docs:     http://localhost:8000/docs
echo Health:       http://localhost:8000/health
echo.
echo Frontend:     http://localhost:3000
echo.
echo Opening browser in 2 seconds...
timeout /t 2 /nobreak >nul

REM Open browser
start http://localhost:3000

echo.
echo Browser opened!
echo.
echo ============================================================
echo    APPLICATION IS RUNNING
echo ============================================================
echo.
echo Two windows are open:
echo   1. Backend Server (minimized)
echo   2. Frontend Server (minimized)
echo.
echo To STOP: Close both server windows
echo.
echo This window can be closed now.
echo.
pause
