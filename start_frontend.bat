@echo off
echo ========================================
echo Indian Cinema DBMS - Starting Frontend
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not found in PATH!
    echo Please ensure Python 3.10+ is installed.
    pause
    exit /b 1
)

echo Python found!
echo.

REM Navigate to frontend directory
cd frontend

echo ========================================
echo Starting Frontend HTTP Server...
echo ========================================
echo.
echo Frontend will be available at: http://localhost:3000
echo.
echo IMPORTANT: Make sure the backend is running first!
echo            (Run start_backend.bat in another window)
echo.
echo Press Ctrl+C to stop the server
echo.

python -m http.server 3000

pause
