# Indian Cinema DBMS - Complete Startup Guide

## Prerequisites

- **Python 3.10 or higher**
- **MySQL 8.0 or higher**
- **pip** (Python package manager)
- **Modern web browser** (Chrome, Firefox, Edge, Safari)

## Step 1: Database Setup

### 1.1 Start MySQL Server

Ensure your MySQL server is running on `localhost:3306`

### 1.2 Create Database

```sql
CREATE DATABASE indianmovies;
```

### 1.3 Update Configuration

Edit the `.env` file in the project root:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=YOUR_PASSWORD_HERE
DB_NAME=indianmovies
APP_HOST=0.0.0.0
APP_PORT=8000
DEBUG=True
```

**Important:** Replace `YOUR_PASSWORD_HERE` with your MySQL root password.

### 1.4 Execute SQL Scripts

Run the following SQL scripts in order using MySQL Workbench or command line:

```bash
# Navigate to database/schema directory
cd database/schema

# Execute scripts in order
mysql -u root -p indianmovies < 01_create_tables.sql
mysql -u root -p indianmovies < 02_insert_data.sql
mysql -u root -p indianmovies < 03_create_triggers.sql
mysql -u root -p indianmovies < 04_create_procedures.sql
mysql -u root -p indianmovies < 05_create_functions.sql
mysql -u root -p indianmovies < 06_create_views.sql
```

**OR** use the automated setup script:

```bash
# From project root
python scripts/setup_database.py
```

## Step 2: Backend Setup

### 2.1 Install Python Dependencies

```bash
# Navigate to project root
cd c:\Users\Aaron\Documents\aaronswork\IndianMovieAnalytics

# Install dependencies
pip install -r requirements.txt
```

### 2.2 Verify Installation

```bash
pip list
```

You should see:
- fastapi==0.104.1
- uvicorn==0.24.0
- mysql-connector-python==8.2.0
- pydantic==2.5.0
- python-dotenv==1.0.0

### 2.3 Start Backend Server

```bash
# Method 1: Using uvicorn directly
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Method 2: Using Python
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 2.4 Verify Backend is Running

Open your browser and visit:
- **API Docs (Swagger):** http://localhost:8000/docs
- **Health Check:** http://localhost:8000/health

You should see:
```json
{
  "status": "healthy",
  "service": "Indian Cinema DBMS Backend"
}
```

## Step 3: Frontend Setup

### 3.1 Open Frontend

Simply open the HTML file in your browser:

**Option 1 - Direct File:**
```
File Explorer → Navigate to frontend/index.html → Double-click to open
```

**Option 2 - Using Python HTTP Server (Recommended):**
```bash
# Navigate to frontend directory
cd frontend

# Start simple HTTP server
python -m http.server 3000
```

Then open: http://localhost:3000

**Option 3 - Using Live Server (VS Code):**
- Install "Live Server" extension in VS Code
- Right-click on `frontend/index.html`
- Select "Open with Live Server"

### 3.2 Verify Frontend is Working

You should see:
- ✅ Navigation bar with all menu items
- ✅ Dashboard with 4 statistics cards
- ✅ Charts displaying data
- ✅ Recent movies table

## Step 4: Testing the Application

### 4.1 Test CRUD Operations

#### Create a Movie
1. Go to **Movies** page
2. Click **"Add New Movie"** button
3. Fill in the form:
   - Title: "Test Movie"
   - Release Date: Any date
   - Language: Select from dropdown
   - Duration: 120 (minutes)
   - Budget: 50000000
   - Producer: Select from dropdown
   - Rating: 7.5
4. Click **"Save Movie"**
5. Verify success notification appears
6. Check that movie appears in the table

#### Read/View Movies
1. Click on any movie's **eye icon** (👁️)
2. Verify detailed information modal opens
3. Check cast and crew information displays

#### Update a Movie
1. Click on **pencil icon** (✏️) for any movie
2. Modify any field (e.g., change rating)
3. Click **"Save Movie"**
4. Verify update success notification
5. Confirm changes appear in table

#### Delete a Movie
1. Click on **trash icon** (🗑️) for test movie
2. Confirm deletion in dialog
3. Verify success notification
4. Confirm movie removed from table

### 4.2 Test Other Entities

Repeat similar CRUD operations for:
- **Producers** page
- **Box Office** page
- **Actors** page (once implemented)
- **Crew** page (once implemented)

### 4.3 Test Analytics

1. Go to **Analytics** page
2. Verify tables display:
   - Top 10 Movies by Collection
   - Most Profitable Movies
3. Verify charts render:
   - Collection Trends Chart
   - Profit Margin Distribution Chart

### 4.4 Test Stored Procedures

1. Go to **Procedures** page
2. Click **"View Details"** on any procedure
3. Verify modal shows:
   - Procedure name
   - Description
   - Parameters
   - Features

## Step 5: Common Issues & Troubleshooting

### Issue 1: Backend Won't Start

**Error:** `ModuleNotFoundError: No module named 'fastapi'`

**Solution:**
```bash
pip install -r requirements.txt
```

### Issue 2: Database Connection Error

**Error:** `Access denied for user 'root'@'localhost'`

**Solution:**
- Check `.env` file has correct password
- Verify MySQL server is running
- Test connection: `mysql -u root -p`

### Issue 3: CORS Error in Browser

**Error:** `Access to fetch at 'http://localhost:8000' blocked by CORS policy`

**Solution:**
- Verify backend is running on port 8000
- Check CORS middleware is enabled in `app/main.py` (already configured)
- Clear browser cache and reload

### Issue 4: Frontend Not Loading Data

**Error:** Tables show "Loading..." indefinitely

**Solution:**
1. Open browser Developer Tools (F12)
2. Check Console for errors
3. Verify API URL in `frontend/js/config.js` is correct:
   ```javascript
   BASE_URL: 'http://localhost:8000'
   ```
4. Test API manually: http://localhost:8000/api/movies
5. Check Network tab for failed requests

### Issue 5: Charts Not Displaying

**Solution:**
- Ensure Chart.js CDN is loading (check Network tab)
- Verify data exists in database
- Check browser console for JavaScript errors

## Step 6: Accessing Different Pages

| Page | URL (if using HTTP server) | Description |
|------|---------------------------|-------------|
| Dashboard | http://localhost:3000 | Statistics, charts, recent movies |
| Movies | http://localhost:3000#movies | Movie CRUD operations |
| Producers | http://localhost:3000#producers | Producer management |
| Actors | http://localhost:3000#actors | Actor management |
| Crew | http://localhost:3000#crew | Crew management |
| Box Office | http://localhost:3000#box-office | Box office tracking |
| Analytics | http://localhost:3000#analytics | Advanced analytics & insights |
| Procedures | http://localhost:3000#procedures | Stored procedures & functions info |

## Step 7: Stopping the Application

### Stop Backend
Press `Ctrl + C` in the terminal running uvicorn

### Stop Frontend HTTP Server
Press `Ctrl + C` in the terminal running Python HTTP server

## Step 8: Project Demonstration Checklist

For your DBMS project demo, ensure you can show:

### ✅ Database Design
- [x] ER Diagram (if created)
- [x] 15 Tables with constraints
- [x] Foreign key relationships
- [x] Indexes

### ✅ SQL Components
- [x] 14 Triggers (audit, validation, business rules)
- [x] 10 Stored Procedures (CRUD, complex queries)
- [x] 10 Functions (calculations, status, counts)
- [x] 4 Views (reporting, analysis)

### ✅ CRUD Operations
- [x] Create operations (all entities)
- [x] Read operations with filters
- [x] Update operations
- [x] Delete operations
- [x] Screenshots of each operation

### ✅ Web Application
- [x] Running web interface
- [x] Dashboard with statistics
- [x] Data visualization (charts)
- [x] Responsive UI
- [x] CRUD forms

### ✅ Complex Queries
- [x] Nested queries (sp_get_movie_details)
- [x] JOIN queries (sp_get_profit_analysis)
- [x] Aggregate queries (sp_get_language_box_office_summary)
- [x] Analytics queries

### ✅ Advanced Features
- [x] Audit trail (Movie_Audit, Box_Office_Audit)
- [x] Activity logging
- [x] Data validation triggers
- [x] Transaction management
- [x] Error handling

## Quick Start (TL;DR)

```bash
# 1. Setup database
mysql -u root -p indianmovies < database/schema/01_create_tables.sql
mysql -u root -p indianmovies < database/schema/02_insert_data.sql
mysql -u root -p indianmovies < database/schema/03_create_triggers.sql
mysql -u root -p indianmovies < database/schema/04_create_procedures.sql
mysql -u root -p indianmovies < database/schema/05_create_functions.sql
mysql -u root -p indianmovies < database/schema/06_create_views.sql

# 2. Install dependencies
pip install -r requirements.txt

# 3. Update .env file with your MySQL password

# 4. Start backend
uvicorn app.main:app --reload

# 5. Start frontend (in new terminal)
cd frontend
python -m http.server 3000

# 6. Open browser
http://localhost:3000
```

## Support

For issues or questions:
- Check the [README.md](README.md)
- Review API documentation at http://localhost:8000/docs
- Check browser console for JavaScript errors
- Check backend terminal for Python errors

---

**Project Authors:**
- Aaron Thomas Mathew
- Aashlesh Lokesh

**Course:** Database Management System (UE23CS351A)

**Institution:** PES University
