@echo off
echo ========================================
echo Indian Cinema DBMS - Starting All Services
echo ========================================
echo.

REM Check if .env file exists
if not exist ".env" (
    echo WARNING: .env file not found!
    echo Running database setup first...
    echo.
    call setup_database.bat
    if errorlevel 1 (
        echo Database setup failed!
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo Starting Backend and Frontend...
echo ========================================
echo.
echo This will open TWO windows:
echo   1. Backend Server (Port 8000)
echo   2. Frontend Server (Port 3000)
echo.
echo After both servers start, open your browser to:
echo http://localhost:3000
echo.

REM Start backend in new window
echo Starting Backend Server...
start "Indian Cinema DBMS - Backend" cmd /k "start_backend.bat"

REM Wait 5 seconds for backend to initialize
echo Waiting for backend to initialize...
timeout /t 5 /nobreak >nul

REM Start frontend in new window
echo Starting Frontend Server...
start "Indian Cinema DBMS - Frontend" cmd /k "start_frontend.bat"

REM Wait 2 seconds for frontend to start
timeout /t 2 /nobreak >nul

echo.
echo ========================================
echo All Services Started!
echo ========================================
echo.
echo Backend:  http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo Frontend: http://localhost:3000
echo.
echo Opening browser...
timeout /t 2 /nobreak >nul

REM Open browser
start http://localhost:3000

echo.
echo To stop all services, close both terminal windows.
echo.
pause
