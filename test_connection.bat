@echo off
echo ========================================
echo Indian Cinema DBMS - Test Connection
echo ========================================
echo.

echo Testing MySQL connection...
set /p MYSQL_PASSWORD="Enter your MySQL root password: "

mysql -u root -p%MYSQL_PASSWORD% -e "SELECT 'MySQL Connection: SUCCESS' AS Status;" 2>nul
if errorlevel 1 (
    echo ERROR: MySQL connection failed!
    echo Please check:
    echo   1. MySQL is installed and running
    echo   2. Password is correct
    echo   3. MySQL is added to system PATH
    pause
    exit /b 1
)

echo.
echo Checking if database exists...
mysql -u root -p%MYSQL_PASSWORD% -e "USE indianmovies; SELECT 'Database exists: YES' AS Status;" 2>nul
if errorlevel 1 (
    echo WARNING: Database 'indianmovies' does not exist!
    echo Run 'setup_database.bat' to create it.
) else (
    echo Database 'indianmovies' found!
    echo.
    echo Checking tables...
    mysql -u root -p%MYSQL_PASSWORD% indianmovies -e "SHOW TABLES;"
)

echo.
echo Testing Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
) else (
    python --version
    echo Python: OK
)

echo.
echo Testing pip packages...
pip show fastapi >nul 2>&1
if errorlevel 1 (
    echo WARNING: FastAPI not installed!
    echo Run 'install_dependencies.bat'
) else (
    echo FastAPI: OK
)

pip show uvicorn >nul 2>&1
if errorlevel 1 (
    echo WARNING: Uvicorn not installed!
) else (
    echo Uvicorn: OK
)

pip show mysql-connector-python >nul 2>&1
if errorlevel 1 (
    echo WARNING: MySQL Connector not installed!
) else (
    echo MySQL Connector: OK
)

echo.
echo Testing .env file...
if exist ".env" (
    echo .env file: EXISTS
) else (
    echo WARNING: .env file not found!
)

echo.
echo Testing backend accessibility...
curl -s http://localhost:8000/health >nul 2>&1
if errorlevel 1 (
    echo Backend: NOT RUNNING
    echo Run 'start_backend.bat' to start it
) else (
    echo Backend: RUNNING
    curl http://localhost:8000/health
)

echo.
echo ========================================
echo Connection Test Complete!
echo ========================================
echo.
pause
