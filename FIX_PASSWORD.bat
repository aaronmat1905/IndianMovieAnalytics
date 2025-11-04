@echo off
title Fix MySQL Password
color 0C

echo ============================================================
echo    FIX MYSQL PASSWORD IN .ENV FILE
echo ============================================================
echo.

echo Current .env file contents:
echo ----------------------------------------
if exist ".env" (
    type .env
) else (
    echo .env file does not exist!
)
echo ----------------------------------------
echo.

echo.
echo Enter your MySQL root password:
set /p NEW_PASSWORD="> "

echo.
echo Creating/Updating .env file with new password...
echo.

(
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=%NEW_PASSWORD%
echo DB_NAME=indianmovies
echo APP_HOST=0.0.0.0
echo APP_PORT=8000
echo DEBUG=True
) > .env

echo.
echo .env file updated!
echo.
echo New contents:
echo ----------------------------------------
type .env
echo ----------------------------------------
echo.

echo Testing connection with new password...
echo.

python -c "from database.connection import get_db_connection; conn = get_db_connection(); print('SUCCESS! Password works!'); conn.close()" 2>error.log

if errorlevel 1 (
    echo.
    echo CONNECTION STILL FAILED!
    echo.
    type error.log
    echo.
    echo Please try again with the correct password.
    del error.log
    pause
    exit /b 1
)

del error.log 2>nul

echo.
echo ============================================================
echo    PASSWORD FIXED!
echo ============================================================
echo.
echo Your .env file is now correct!
echo You can run: QUICK_START.bat
echo.
pause
