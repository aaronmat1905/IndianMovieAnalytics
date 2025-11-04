# How to Run the Application

## One-Step Launch

### Windows
Simply **double-click `START.bat`** and you're done!

The application will:
1. Verify Python is installed
2. Check database connection
3. Start backend server (port 8001)
4. Start frontend server (port 3000)
5. Open your browser automatically

### Manual Launch (Alternative)

If you prefer to start servers manually:

**Terminal 1 - Backend:**
```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001
```

**Terminal 2 - Frontend:**
```bash
cd frontend
python -m http.server 3000
```

Then open http://localhost:3000 in your browser.

## Access Points

- **Frontend UI**: http://localhost:3000
- **Backend API**: http://localhost:8001
- **API Documentation**: http://localhost:8001/docs
- **Health Check**: http://localhost:8001/health

## Stopping the Application

- Close the backend and frontend server windows
- Or press `Ctrl+C` in each terminal window

## Prerequisites

- Python 3.10+
- MySQL 8.0+ running
- Database 'indianmovies' created with schema loaded
- `.env` file configured with your MySQL password

## Troubleshooting

**Database Connection Failed?**
- Make sure MySQL is running
- Check password in `.env` file
- Verify database 'indianmovies' exists

**Port Already in Use?**
- Close any existing server windows
- Or change ports in `START.bat`

**Browser Doesn't Open?**
- Manually navigate to http://localhost:3000
