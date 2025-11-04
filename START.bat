@echo off
title Indian Cinema DBMS - Launcher
color 0A

echo ============================================================
echo    INDIAN CINEMA DBMS - DATABASE MANAGEMENT SYSTEM
echo ============================================================
echo.

REM Clear environment variables to prevent .env override
set DB_HOST=
set DB_PORT=
set DB_USER=
set DB_PASSWORD=
set DB_NAME=

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found! Install Python 3.10+ from https://www.python.org/
    timeout /t 10
    exit /b 1
)

echo [OK] Python found
python --version
echo.

REM Check .env file
if not exist ".env" (
    echo [ERROR] .env file not found!
    echo.
    echo Create .env file with:
    echo DB_HOST=localhost
    echo DB_PORT=3306
    echo DB_USER=root
    echo DB_PASSWORD=your_password
    echo DB_NAME=indianmovies
    echo APP_HOST=0.0.0.0
    echo APP_PORT=8001
    echo.
    timeout /t 10
    exit /b 1
)

echo [OK] .env file found
echo.

REM Test database connection
echo Testing database connection...
python -c "import sys; sys.path.insert(0, '.'); from database.connection import get_db_connection; get_db_connection().close()" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Database connection failed!
    echo - Make sure MySQL is running
    echo - Check password in .env file
    echo - Verify database 'indianmovies' exists
    echo.
    timeout /t 10
    exit /b 1
)

echo [OK] Database connection successful!
echo.

echo ============================================================
echo    STARTING SERVERS
echo ============================================================
echo.

REM Start Backend
echo Starting Backend API (port 8001)...
start "Backend API" cmd /k "color 0B && title Backend Server && python -m uvicorn app.main:app --host 0.0.0.0 --port 8001"
timeout /t 5 /nobreak >nul

REM Start Frontend
echo Starting Frontend UI (port 3000)...
start "Frontend UI" cmd /k "color 0E && title Frontend Server && cd frontend && python -m http.server 3000"
timeout /t 3 /nobreak >nul

echo.
echo ============================================================
echo    APPLICATION RUNNING
echo ============================================================
echo.
echo Backend API:   http://localhost:8001
echo API Docs:      http://localhost:8001/docs
echo Frontend UI:   http://localhost:3000
echo.
echo Opening browser...
timeout /t 2 /nobreak >nul
start http://localhost:3000

echo.
echo Application is running in separate windows.
echo Close those windows to stop the servers.
echo.
echo Press any key to close this launcher window...
pause >nul
