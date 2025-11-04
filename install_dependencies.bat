@echo off
echo ========================================
echo Indian Cinema DBMS - Install Dependencies
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not found in PATH!
    echo.
    echo Please install Python 3.10 or higher from:
    echo https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation!
    pause
    exit /b 1
)

echo Python version:
python --version
echo.

REM Check if pip is available
pip --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: pip is not found!
    echo Please reinstall Python with pip enabled.
    pause
    exit /b 1
)

echo pip version:
pip --version
echo.

echo ========================================
echo Installing Python Dependencies...
echo ========================================
echo.

pip install -r requirements.txt

if errorlevel 1 (
    echo.
    echo ERROR: Failed to install dependencies!
    echo.
    echo Try running as Administrator or check your internet connection.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Installed packages:
pip list | findstr "fastapi uvicorn mysql pydantic dotenv"
echo.
echo You can now run 'setup_database.bat' to set up the database.
echo.
pause
