@echo off
title Indian Cinema DBMS - Application Launcher
color 0A

echo ============================================================
echo    INDIAN CINEMA DBMS - APPLICATION LAUNCHER
echo ============================================================
echo.

REM Clear environment variables to prevent override of .env file
set DB_HOST=
set DB_PORT=
set DB_USER=
set DB_PASSWORD=
set DB_NAME=

echo [INFO] Environment variables cleared
echo.

REM Start Backend Server
echo [1/2] Starting Backend Server (Port 8001)...
start "Backend API Server" cmd /c "cd /d %~dp0 && set DB_HOST= && set DB_PORT= && set DB_USER= && set DB_PASSWORD= && set DB_NAME= && python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 && pause"

REM Wait for backend to initialize
echo       Waiting for backend to start (8 seconds)...
timeout /t 8 /nobreak >nul

REM Start Frontend Server
echo.
echo [2/2] Starting Frontend Server (Port 3000)...
start "Frontend Web Server" cmd /c "cd /d %~dp0\frontend && python -m http.server 3000 && pause"

REM Wait for frontend
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
echo    SERVERS ARE RUNNING
echo ============================================================
echo.
echo Two command windows are open:
echo   1. Backend API Server (uvicorn on port 8001)
echo   2. Frontend Web Server (http.server on port 3000)
echo.
echo To STOP the application:
echo   - Close both server windows
echo   - Or press Ctrl+C in each window
echo.
echo This launcher window can be closed now.
echo The application will continue running.
echo.
pause
