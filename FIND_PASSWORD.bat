@echo off
title Find MySQL Password
color 0E

echo ============================================================
echo    TESTING COMMON MYSQL PASSWORDS
echo ============================================================
echo.

echo Testing common passwords...
echo.

REM Test 1: root
echo [1/6] Testing password: root
(
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=root
echo DB_NAME=indianmovies
echo APP_HOST=0.0.0.0
echo APP_PORT=8000
echo DEBUG=True
) > .env.test
python -c "import sys; sys.path.insert(0, '.'); from config import Settings; settings = Settings(_env_file='.env.test'); from mysql.connector import connect; conn = connect(host=settings.DB_HOST, port=settings.DB_PORT, user=settings.DB_USER, password=settings.DB_PASSWORD); print('SUCCESS!'); conn.close(); exit(0)" 2>nul
if not errorlevel 1 (
    echo *** FOUND IT! Password is: root ***
    copy .env.test .env >nul
    del .env.test
    echo .env file updated!
    pause
    exit /b 0
)

REM Test 2: admin
echo [2/6] Testing password: admin
(
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=admin
echo DB_NAME=indianmovies
echo APP_HOST=0.0.0.0
echo APP_PORT=8000
echo DEBUG=True
) > .env.test
python -c "import sys; from mysql.connector import connect; conn = connect(host='localhost', user='root', password='admin'); print('SUCCESS!'); conn.close()" 2>nul
if not errorlevel 1 (
    echo *** FOUND IT! Password is: admin ***
    copy .env.test .env >nul
    del .env.test
    echo .env file updated!
    pause
    exit /b 0
)

REM Test 3: password
echo [3/6] Testing password: password
python -c "from mysql.connector import connect; conn = connect(host='localhost', user='root', password='password'); print('SUCCESS!'); conn.close()" 2>nul
if not errorlevel 1 (
    echo *** FOUND IT! Password is: password ***
    (
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=password
echo DB_NAME=indianmovies
echo APP_HOST=0.0.0.0
echo APP_PORT=8000
echo DEBUG=True
) > .env
    echo .env file updated!
    pause
    exit /b 0
)

REM Test 4: mysql
echo [4/6] Testing password: mysql
python -c "from mysql.connector import connect; conn = connect(host='localhost', user='root', password='mysql'); print('SUCCESS!'); conn.close()" 2>nul
if not errorlevel 1 (
    echo *** FOUND IT! Password is: mysql ***
    (
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=mysql
echo DB_NAME=indianmovies
echo APP_HOST=0.0.0.0
echo APP_PORT=8000
echo DEBUG=True
) > .env
    echo .env file updated!
    pause
    exit /b 0
)

REM Test 5: blank
echo [5/6] Testing password: (blank/empty)
python -c "from mysql.connector import connect; conn = connect(host='localhost', user='root', password=''); print('SUCCESS!'); conn.close()" 2>nul
if not errorlevel 1 (
    echo *** FOUND IT! Password is: (empty/blank) ***
    (
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=
echo DB_NAME=indianmovies
echo APP_HOST=0.0.0.0
echo APP_PORT=8000
echo DEBUG=True
) > .env
    echo .env file updated!
    pause
    exit /b 0
)

REM Test 6: 123456
echo [6/6] Testing password: 123456
python -c "from mysql.connector import connect; conn = connect(host='localhost', user='root', password='123456'); print('SUCCESS!'); conn.close()" 2>nul
if not errorlevel 1 (
    echo *** FOUND IT! Password is: 123456 ***
    (
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=123456
echo DB_NAME=indianmovies
echo APP_HOST=0.0.0.0
echo APP_PORT=8000
echo DEBUG=True
) > .env
    echo .env file updated!
    pause
    exit /b 0
)

del .env.test 2>nul

echo.
echo ============================================================
echo    NO COMMON PASSWORDS WORKED
echo ============================================================
echo.
echo None of the common passwords worked.
echo.
echo You need to:
echo   1. Remember your MySQL password
echo   2. Or reset it using MySQL documentation
echo   3. Or check MySQL Workbench saved passwords
echo.
echo Then run: FIX_PASSWORD.bat
echo.
pause
