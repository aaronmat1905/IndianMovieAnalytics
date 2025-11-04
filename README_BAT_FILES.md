# Batch Files Guide

## 📁 Available Batch Files

This project includes several `.bat` files to automate setup and startup tasks on Windows.

---

## 🚀 Quick Start (Recommended)

### **For First Time Setup:**

1. **Install Dependencies**
   ```
   Double-click: install_dependencies.bat
   ```
   This installs all Python packages needed.

2. **Setup Database**
   ```
   Double-click: setup_database.bat
   ```
   This creates the database, tables, triggers, procedures, functions, and views.

3. **Start Everything**
   ```
   Double-click: start_all.bat
   ```
   This starts both backend and frontend servers and opens your browser.

---

## 📝 Detailed Batch File Descriptions

### 1. **install_dependencies.bat**
**Purpose:** Install all Python dependencies

**What it does:**
- Checks if Python is installed
- Verifies pip is available
- Installs all packages from `requirements.txt`
- Shows installed packages

**When to use:**
- First time setup
- After cloning the repository
- If you get "ModuleNotFoundError"

**Usage:**
```
Double-click the file OR
run: install_dependencies.bat
```

---

### 2. **setup_database.bat**
**Purpose:** Create and setup the MySQL database

**What it does:**
- Checks MySQL connection
- Creates `indianmovies` database
- Runs all 6 SQL scripts in order:
  1. Creates tables
  2. Inserts sample data
  3. Creates triggers
  4. Creates stored procedures
  5. Creates functions
  6. Creates views
- Updates `.env` file with your password

**When to use:**
- First time setup
- After deleting the database
- To reset database to initial state

**Usage:**
```
Double-click the file OR
run: setup_database.bat
```

**Note:** You'll be prompted for your MySQL root password

---

### 3. **start_backend.bat**
**Purpose:** Start the FastAPI backend server

**What it does:**
- Checks Python installation
- Verifies `.env` file exists
- Checks/installs dependencies if needed
- Starts uvicorn server on port 8000

**When to use:**
- Every time you want to run the backend
- For development/testing

**Usage:**
```
Double-click the file OR
run: start_backend.bat
```

**Endpoints available:**
- Backend: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Health Check: http://localhost:8000/health

**To stop:** Press `Ctrl+C` in the terminal

---

### 4. **start_frontend.bat**
**Purpose:** Start the frontend HTTP server

**What it does:**
- Checks Python installation
- Navigates to `frontend/` directory
- Starts Python HTTP server on port 3000

**When to use:**
- After starting the backend
- Every time you want to access the web UI

**Usage:**
```
Double-click the file OR
run: start_frontend.bat
```

**Important:** Make sure backend is running first!

**Frontend URL:** http://localhost:3000

**To stop:** Press `Ctrl+C` in the terminal

---

### 5. **start_all.bat** ⭐ (RECOMMENDED)
**Purpose:** Start both backend and frontend automatically

**What it does:**
- Checks if database is setup (runs setup if needed)
- Opens TWO terminal windows:
  - Window 1: Backend server
  - Window 2: Frontend server
- Waits for servers to initialize
- Opens your browser to http://localhost:3000

**When to use:**
- Most convenient way to start the application
- For demos/presentations
- For quick testing

**Usage:**
```
Double-click the file OR
run: start_all.bat
```

**To stop:** Close both terminal windows

---

### 6. **test_connection.bat**
**Purpose:** Test all connections and verify setup

**What it does:**
- Tests MySQL connection
- Checks if database exists
- Lists all tables
- Tests Python installation
- Checks pip packages (fastapi, uvicorn, etc.)
- Verifies `.env` file exists
- Tests if backend is running

**When to use:**
- Troubleshooting issues
- Verifying setup is complete
- Before demos to ensure everything works

**Usage:**
```
Double-click the file OR
run: test_connection.bat
```

---

## 🎯 Recommended Workflow

### **First Time Setup:**
```
1. install_dependencies.bat
2. setup_database.bat
3. start_all.bat
4. Open browser to: http://localhost:3000
```

### **Daily Development:**
```
1. start_all.bat
   (This opens backend + frontend + browser)
```

### **If Having Issues:**
```
1. test_connection.bat
   (This shows what's wrong)
```

---

## ⚠️ Troubleshooting

### "Python is not found"
**Solution:**
- Install Python 3.10+ from https://www.python.org/
- Make sure to check "Add Python to PATH" during installation

### "MySQL is not found"
**Solution:**
- Install MySQL 8.0+ from https://dev.mysql.com/downloads/
- Add MySQL to system PATH:
  - Usually: `C:\Program Files\MySQL\MySQL Server 8.0\bin`

### "Access Denied" or "Permission Denied"
**Solution:**
- Right-click the .bat file
- Select "Run as Administrator"

### "ModuleNotFoundError"
**Solution:**
- Run `install_dependencies.bat`

### Backend won't start
**Solution:**
1. Check if `.env` file exists
2. Run `test_connection.bat` to diagnose
3. Make sure MySQL is running
4. Verify password in `.env` is correct

### Frontend shows "Loading..." forever
**Solution:**
1. Make sure backend is running (check http://localhost:8000/health)
2. Open browser Developer Tools (F12) and check Console for errors
3. Clear browser cache

---

## 🔧 Advanced Usage

### Run Backend on Different Port
Edit `start_backend.bat` and change:
```batch
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

### Run Frontend on Different Port
Edit `start_frontend.bat` and change:
```batch
python -m http.server 3001
```

Don't forget to update `frontend/js/config.js` to point to the new backend port!

---

## 📋 Checklist for Demo Day

Before your presentation:

- [ ] Run `test_connection.bat` - verify everything is OK
- [ ] Run `start_all.bat` - start all services
- [ ] Open http://localhost:3000 - verify dashboard loads
- [ ] Test CRUD operations - create a test movie
- [ ] Check analytics page - verify charts display
- [ ] Open http://localhost:8000/docs - show API documentation
- [ ] Take screenshots for your report

---

## 💡 Tips

1. **Keep terminals open** - Don't close the backend/frontend terminal windows while using the app

2. **Use start_all.bat for demos** - It's the fastest way to get everything running

3. **Run test_connection.bat first** - Before any demo, verify everything is working

4. **Administrator privileges** - If you get permission errors, run as Administrator

5. **Antivirus** - Some antivirus software may block the batch files. Add an exception if needed.

---

## 📞 Need Help?

If batch files don't work:
- Check STARTUP_GUIDE.md for manual setup instructions
- Ensure all prerequisites are installed (Python, MySQL)
- Try running commands manually from Command Prompt
- Check Windows Firewall isn't blocking ports 8000 or 3000

---

**Happy Coding! 🚀**
