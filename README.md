# Indian Cinema Database Management System

## 🎬 DBMS Course Project - Level 2 (Orange Problem)

A comprehensive database management system for Indian cinema data with a modern web interface, designed to manage movies, producers, actors, crew, box office collections, and provide advanced analytics capabilities.

---

## 📋 Project Overview

This full-stack DBMS application provides complete lifecycle management of Indian cinema data, from pre-production to post-release analytics. The system covers 8 major Indian film languages and supports AI-driven predictive analytics for revenue forecasting and market analysis.

### **Key Highlights:**
- ✅ **15 Database Tables** (10 core + 3 audit + 2 junction) with comprehensive constraints
- ✅ **14 Triggers** for validation, audit logging, and business rules
- ✅ **10 Stored Procedures** for complex operations and transactions
- ✅ **10 User-Defined Functions** for calculations and derived data
- ✅ **4 Database Views** for reporting and analysis
- ✅ **Complete Web UI** with dashboard, charts, and CRUD operations
- ✅ **RESTful API** with FastAPI backend
- ✅ **Audit Trail** for data integrity and compliance

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Web Frontend (SPA)                      │
│  HTML5 + CSS3 + JavaScript + Bootstrap + Chart.js          │
└─────────────────────┬───────────────────────────────────────┘
                      │ REST API (JSON)
┌─────────────────────▼───────────────────────────────────────┐
│                  FastAPI Backend                            │
│  Python 3.10+ • Pydantic Models • Connection Pool          │
└─────────────────────┬───────────────────────────────────────┘
                      │ MySQL Connector
┌─────────────────────▼───────────────────────────────────────┐
│                  MySQL Database 8.0+                        │
│  Tables • Triggers • Procedures • Functions • Views         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### **One-Step Launch (Windows)**

Simply double-click **`START.bat`** to launch the entire application!

The script will:
- ✅ Verify Python installation
- ✅ Check database connection
- ✅ Start backend API server (port 8001)
- ✅ Start frontend web server (port 3000)
- ✅ Open your browser automatically

**That's it!** The application will be running at http://localhost:3000

### **Manual Setup (if needed)**

#### **1. Database Setup**
```bash
# Create database
mysql -u root -p
CREATE DATABASE indianmovies;

# Run SQL scripts in order
cd database/schema
mysql -u root -p indianmovies < 01_create_tables.sql
mysql -u root -p indianmovies < 02_insert_data.sql
mysql -u root -p indianmovies < 03_create_triggers.sql
mysql -u root -p indianmovies < 04_create_procedures.sql
mysql -u root -p indianmovies < 05_create_functions.sql
mysql -u root -p indianmovies < 06_create_views.sql
```

### **2. Backend Setup**
```bash
# Install dependencies
pip install -r requirements.txt

# Update .env file with your MySQL credentials
DB_HOST=localhost
DB_PASSWORD=YOUR_PASSWORD

# Start backend server
uvicorn app.main:app --reload
```

### **3. Frontend Setup**
```bash
# Navigate to frontend
cd frontend

# Start HTTP server
python -m http.server 3000

# Open browser
http://localhost:3000
```

**📖 For detailed setup instructions, see [STARTUP_GUIDE.md](STARTUP_GUIDE.md)**

---

## ✨ Features

### **Database Layer**
- **Comprehensive Schema:** 15 normalized tables (3NF) with full referential integrity
- **Automated Validation:** 14 triggers for data quality and business rules
- **Business Logic:** 10 stored procedures for complex operations
- **Calculations:** 10 UDFs for profit analysis, status checks, counts
- **Reporting:** 4 optimized views for analytics

### **Backend API**
- **RESTful Endpoints:** Complete CRUD for all entities
- **Authentication Ready:** User roles (admin, producer, analyst, viewer)
- **Data Validation:** Pydantic models with type checking
- **Error Handling:** Comprehensive exception management
- **Connection Pooling:** Efficient database connections
- **API Documentation:** Auto-generated Swagger docs at `/docs`

### **Web Frontend**
- **Modern UI:** Responsive Bootstrap 5.3 design
- **Dashboard:** Statistics cards, charts, recent movies
- **CRUD Operations:** User-friendly forms and tables for:
  - Movies (with cast & crew)
  - Producers
  - Actors
  - Production Crew
  - Box Office Collections
  - Genres & Languages
- **Analytics:** Top movies, profit analysis, collection trends
- **Visualizations:** Chart.js integration for insights
- **Real-time Feedback:** Toast notifications, loading states

### **Data Management**
- **Multi-Language Support:** 8 Indian film languages
- **Genre Classification:** Multi-genre movie support
- **Box Office Tracking:** Domestic, international, total collections
- **Profit Analysis:** Automated calculations and margins
- **Audit Trail:** Complete modification history
- **Activity Logging:** User action tracking

---

## 📊 Database Schema

### **Core Entities**
| Table | Description | Key Features |
|-------|-------------|--------------|
| MOVIES | Central movie information | Budget, ratings, OTT rights, certifications |
| PRODUCERS | Production companies | Regional categorization, experience tracking |
| ACTORS | Actor profiles | Popularity scores, demographics |
| PRODUCTION_CREW | Directors, cinematographers, etc. | Role-based, experience years |
| BOX_OFFICE | Collection data | Domestic/Intl split, profit margins |
| LANGUAGES | Film languages | 8 major Indian languages |
| GENRES | Movie genres | 8 predefined categories |

### **Junction Tables**
- MOVIE_GENRES: Many-to-many (Movies ↔ Genres)
- MOVIE_CAST: Many-to-many (Movies ↔ Actors) with role details
- MOVIE_CREW: Many-to-many (Movies ↔ Crew) with descriptions

### **Audit & Analytics**
- MOVIE_AUDIT: Tracks all movie modifications
- BOX_OFFICE_AUDIT: Tracks collection updates
- ACTIVITY_LOG: General activity logging
- MOVIE_STATISTICS: Performance metrics

---

## 🔧 Technology Stack

### **Backend**
- **Framework:** FastAPI 0.104.1
- **Server:** Uvicorn 0.24.0
- **Database Driver:** mysql-connector-python 8.2.0
- **Validation:** Pydantic 2.5.0
- **Environment:** python-dotenv 1.0.0
- **Language:** Python 3.10+

### **Frontend**
- **UI Framework:** Bootstrap 5.3
- **Icons:** Bootstrap Icons 1.11
- **Charts:** Chart.js 4.4
- **Architecture:** Single Page Application (SPA)
- **Languages:** HTML5, CSS3, JavaScript ES6+

### **Database**
- **RDBMS:** MySQL 8.0+
- **Design:** Normalized (3NF)
- **Features:** Triggers, Procedures, Functions, Views, Indexes

---

## 📁 Project Structure

```
IndianMovieAnalytics/
├── app/                          # FastAPI Backend
│   ├── main.py                   # Application entry point
│   ├── models/                   # Pydantic data models
│   ├── routes/                   # API endpoints
│   │   ├── movies.py
│   │   ├── producers.py
│   │   ├── actors.py
│   │   ├── crew.py
│   │   ├── box_office.py
│   │   ├── genres.py
│   │   └── languages.py
│   ├── services/                 # Business logic
│   └── utils/                    # Utilities
├── database/                     # Database layer
│   ├── connection.py             # MySQL connection pool
│   ├── schema/                   # SQL scripts
│   │   ├── 01_create_tables.sql
│   │   ├── 02_insert_data.sql
│   │   ├── 03_create_triggers.sql
│   │   ├── 04_create_procedures.sql
│   │   ├── 05_create_functions.sql
│   │   └── 06_create_views.sql
│   └── queries/                  # Predefined queries
├── frontend/                     # Web UI
│   ├── index.html                # Main HTML
│   ├── css/                      # Stylesheets
│   │   └── style.css
│   └── js/                       # JavaScript modules
│       ├── config.js
│       ├── api.js
│       ├── utils.js
│       ├── app.js
│       ├── dashboard.js
│       ├── movies.js
│       ├── producers.js
│       ├── actors.js
│       ├── crew.js
│       ├── boxoffice.js
│       ├── analytics.js
│       └── procedures.js
├── scripts/                      # Utility scripts
│   ├── setup_database.py
│   └── seed_data.py
├── tests/                        # Test suite
├── config.py                     # Configuration
├── requirements.txt              # Python dependencies
├── .env                          # Environment variables
├── .env.example                  # Template
├── README.md                     # This file
├── STARTUP_GUIDE.md              # Detailed setup instructions
└── USER_REQUIREMENT_SPECIFICATION.md  # Requirements doc
```

---

## 📸 Screenshots & Demonstration

### **Dashboard**
- Statistics cards (Total Movies, Collections, Producers, Avg Rating)
- Charts (Top Movies, Language-wise Collections, Profit Margins, Genres)
- Recent movies table

### **CRUD Operations**
- **Create:** Modal forms with validation
- **Read:** Paginated tables with filters
- **Update:** Pre-filled edit forms
- **Delete:** Confirmation dialogs

### **Analytics**
- Top 10 movies by collection
- Most profitable movies
- Collection trends chart
- Profit margin distribution

### **Procedures & Functions**
- Comprehensive documentation
- Parameter details
- Usage examples

---

## 🧪 API Endpoints

### **Movies**
```
GET    /api/movies              # List all movies
GET    /api/movies/{id}         # Get movie by ID
POST   /api/movies              # Create movie
PUT    /api/movies/{id}         # Update movie
DELETE /api/movies/{id}         # Delete movie
GET    /api/movies/{id}/details # Get complete details (cast, crew)
GET    /api/movies/{id}/profit-analysis  # Profit analysis
```

### **Similar endpoints for:**
- `/api/producers`
- `/api/actors`
- `/api/crew`
- `/api/box-office`
- `/api/genres`
- `/api/languages`

### **Analytics**
```
GET    /api/analytics/top-movies      # Top movies by collection
GET    /api/analytics/profit-analysis # Profitability analysis
```

**📚 Complete API docs:** http://localhost:8000/docs

---

## 🎯 DBMS Project Requirements Checklist

### ✅ **Review 1: Design**
- [x] User Requirement Specification (URS)
- [x] ER Diagram design
- [x] Relational Schema with constraints
- [x] Normalized to 3NF

### ✅ **Review 2: DDL & DML**
- [x] 15 tables created with all constraints
- [x] Primary keys, Foreign keys, Check constraints
- [x] Unique constraints, Default values
- [x] Indexes on frequently queried columns
- [x] Sample data insertion

### ✅ **Review 3: Triggers, Procedures, Functions**
- [x] 14 Triggers (audit, validation, business rules)
- [x] 10 Stored Procedures (CRUD, complex queries)
- [x] 10 Functions (calculations, status checks)
- [x] Transaction management
- [x] Error handling

### ✅ **Review 4: Complete Application**
- [x] Web-based UI (HTML/CSS/JavaScript)
- [x] CRUD operations for all entities
- [x] Complex queries (Nested, JOIN, Aggregate)
- [x] Analytics dashboard with charts
- [x] Audit trail implementation
- [x] Documentation (URS, Setup Guide, README)

---

## 📝 Documentation

- **[USER_REQUIREMENT_SPECIFICATION.md](USER_REQUIREMENT_SPECIFICATION.md)** - Complete functional & non-functional requirements
- **[STARTUP_GUIDE.md](STARTUP_GUIDE.md)** - Step-by-step setup and testing instructions
- **[README.md](README.md)** - This file (project overview)

---

## 🤝 Team

| Name | GitHub | Role |
|------|--------|------|
| **Aaron Thomas Mathew** | [@aaronmat1905](https://github.com/aaronmat1905) | Backend, Database Design |
| **Aashlesh Lokesh** | [@aashlesh-lokesh](https://github.com/aashlesh-lokesh) | Frontend, API Integration |

**Course:** Database Management System (UE23CS351A)
**Institution:** PES University
**Project Type:** Experiential Learning - Level 2 (Orange Problem)

---

## 📄 License

This project is developed for academic purposes as part of the DBMS course at PES University.

---

## 🙏 Acknowledgments

- **PES University** - For providing the opportunity and guidance
- **Course Instructor** - For project requirements and review
- **Open Source Community** - For amazing tools and frameworks

---

**Last Updated:** November 4, 2025
**Version:** 1.0.0
**Status:** ✅ Complete & Ready for Demo
