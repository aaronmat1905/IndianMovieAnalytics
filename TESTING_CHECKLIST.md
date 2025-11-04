# 🧪 Testing Checklist for Indian Cinema DBMS

## Pre-Testing Setup

- [ ] MySQL server is running
- [ ] Database `indianmovies` is created
- [ ] All 6 SQL scripts executed successfully
- [ ] `.env` file has correct MySQL password
- [ ] Python dependencies installed (`pip install -r requirements.txt`)
- [ ] Backend server is running (`uvicorn app.main:app --reload`)
- [ ] Frontend is accessible (http://localhost:3000)

---

## 1. Backend API Testing

### Test Health Check
```bash
curl http://localhost:8000/health
```
**Expected:** `{"status": "healthy", "service": "Indian Cinema DBMS Backend"}`

- [ ] Health check returns success

### Test API Documentation
- [ ] Open http://localhost:8000/docs
- [ ] Swagger UI loads successfully
- [ ] All endpoints are visible

### Test Movies Endpoints
```bash
# GET all movies
curl http://localhost:8000/api/movies

# GET single movie
curl http://localhost:8000/api/movies/1

# GET movie details
curl http://localhost:8000/api/movies/1/details
```

- [ ] GET /api/movies returns array of movies
- [ ] GET /api/movies/{id} returns single movie
- [ ] GET /api/movies/{id}/details returns cast and crew

### Test Other Endpoints
```bash
# Producers
curl http://localhost:8000/api/producers

# Genres
curl http://localhost:8000/api/genres

# Languages
curl http://localhost:8000/api/languages

# Box Office
curl http://localhost:8000/api/box-office

# Actors
curl http://localhost:8000/api/actors

# Crew
curl http://localhost:8000/api/crew

# Analytics
curl http://localhost:8000/api/analytics/top-movies
curl http://localhost:8000/api/analytics/profit-analysis
```

- [ ] All GET endpoints return data without errors

---

## 2. Frontend Testing

### Dashboard Page
- [ ] Navigate to http://localhost:3000
- [ ] Dashboard loads without errors
- [ ] 4 statistics cards display numbers
- [ ] "Top 10 Movies by Collection" chart renders
- [ ] "Collection by Language" chart renders
- [ ] "Top 10 Most Profitable Movies" chart renders
- [ ] "Movies by Genre" chart renders
- [ ] Recent movies table shows data
- [ ] No JavaScript errors in console (F12)

### Movies Page
- [ ] Click "Movies" in navigation
- [ ] Movies table loads with data
- [ ] Search by title works
- [ ] Filter by language works
- [ ] Filter by producer works
- [ ] "Clear" button resets filters

#### Create Movie
- [ ] Click "Add New Movie" button
- [ ] Modal opens
- [ ] Fill in all required fields:
  - Title: "Test Movie"
  - Release Date: Select any date
  - Language: Select from dropdown
  - Duration: 120
  - Producer: Select from dropdown
- [ ] Click "Save Movie"
- [ ] Success notification appears
- [ ] Movie appears in table
- [ ] Modal closes

#### View Movie Details
- [ ] Click eye icon (👁️) on any movie
- [ ] Details modal opens
- [ ] Movie information displays correctly
- [ ] Cast information shows (if available)
- [ ] Crew information shows (if available)
- [ ] Box office data shows (if available)

#### Edit Movie
- [ ] Click pencil icon (✏️) on test movie
- [ ] Edit modal opens with pre-filled data
- [ ] Change rating to 8.5
- [ ] Click "Save Movie"
- [ ] Success notification appears
- [ ] Updated rating shows in table

#### Delete Movie
- [ ] Click trash icon (🗑️) on test movie
- [ ] Confirmation dialog appears
- [ ] Click "OK"
- [ ] Success notification appears
- [ ] Movie disappears from table

### Producers Page
- [ ] Navigate to "Producers" page
- [ ] Producers table loads with data
- [ ] Search by name works

#### Create Producer
- [ ] Click "Add New Producer"
- [ ] Fill in form:
  - Name: "Test Producer"
  - Company: "Test Productions"
  - Phone: "1234567890"
  - Email: "test@test.com"
- [ ] Click "Save"
- [ ] Success notification appears
- [ ] Producer appears in table

#### Edit Producer
- [ ] Click edit button on test producer
- [ ] Modify any field
- [ ] Save successfully
- [ ] Changes reflect in table

#### Delete Producer
- [ ] Click delete button on test producer
- [ ] Confirm deletion
- [ ] Producer removed from table

### Box Office Page
- [ ] Navigate to "Box Office" page
- [ ] Box office records table loads
- [ ] All columns display correctly (Domestic, International, Total, etc.)

#### Create Box Office Record
- [ ] Click "Add Box Office Record"
- [ ] Fill in form:
  - Movie ID: Enter valid movie ID
  - Domestic Collection: 50000000
  - International Collection: 30000000
  - Opening Weekend: 20000000
  - Profit Margin: 60
  - Release Screens: 2000
  - Status: "Updated"
- [ ] Click "Save"
- [ ] Success notification appears
- [ ] Record appears in table
- [ ] Total collection calculated automatically

#### Edit Box Office Record
- [ ] Click edit on any record
- [ ] Modify collections
- [ ] Save successfully

#### Delete Box Office Record
- [ ] Click delete on test record
- [ ] Confirm deletion
- [ ] Record removed

### Analytics Page
- [ ] Navigate to "Analytics" page
- [ ] "Top 10 Movies by Collection" table loads
- [ ] Table shows: Rank, Title, Language, Collection, Profit %, Rating
- [ ] "Most Profitable Movies" table loads
- [ ] Table shows: Rank, Title, Budget, Collection, Profit, Margin
- [ ] "Collection Trends" chart renders
- [ ] "Profit Margin Distribution" chart renders

### Procedures Page
- [ ] Navigate to "Procedures" page
- [ ] Stored Procedures section displays 6+ procedures
- [ ] Functions section displays 10 functions
- [ ] Triggers section shows 14 triggers categorized
- [ ] Views section shows 4 views
- [ ] Click "View Details" on any procedure
- [ ] Modal opens with procedure information
- [ ] Parameters list displays
- [ ] Features list displays

### Actors Page
- [ ] Navigate to "Actors" page
- [ ] Warning message displays (API endpoint pending)
- [ ] Page renders without errors

### Crew Page
- [ ] Navigate to "Crew" page
- [ ] Warning message displays (API endpoint pending)
- [ ] Page renders without errors

---

## 3. Database Testing

### Test Tables
```sql
-- Verify all tables exist
SHOW TABLES;
```
- [ ] 15 tables listed

### Test Sample Data
```sql
-- Check movies
SELECT COUNT(*) FROM MOVIES;

-- Check producers
SELECT COUNT(*) FROM PRODUCERS;

-- Check box office
SELECT COUNT(*) FROM BOX_OFFICE;

-- Check languages
SELECT COUNT(*) FROM LANGUAGES;

-- Check genres
SELECT COUNT(*) FROM GENRES;
```
- [ ] All tables have data

### Test Triggers
```sql
-- Test movie audit trigger
INSERT INTO MOVIES (title, release_date, language_id, duration, producer_id, created_by)
VALUES ('Trigger Test Movie', '2025-12-01', 1, 120, 1, 1);

-- Check if audit was created
SELECT * FROM MOVIE_AUDIT WHERE new_title = 'Trigger Test Movie';

-- Cleanup
DELETE FROM MOVIES WHERE title = 'Trigger Test Movie';
```
- [ ] Audit record was created
- [ ] Trigger fired successfully

### Test Stored Procedures
```sql
-- Test sp_get_movie_details
CALL sp_get_movie_details(1);
```
- [ ] Returns 3 result sets (movie, cast, crew)

```sql
-- Test sp_get_profit_analysis
CALL sp_get_profit_analysis(1);
```
- [ ] Returns profit calculations

```sql
-- Test sp_get_language_box_office_summary
CALL sp_get_language_box_office_summary();
```
- [ ] Returns aggregated data by language

```sql
-- Test sp_get_top_actors
CALL sp_get_top_actors(10);
```
- [ ] Returns top actors list

### Test Functions
```sql
-- Test fn_get_movie_status
SELECT fn_get_movie_status(1);
```
- [ ] Returns status string

```sql
-- Test fn_calculate_profit_percentage
SELECT fn_calculate_profit_percentage(50000000, 100000000);
```
- [ ] Returns 100.00

```sql
-- Test fn_get_actor_movie_count
SELECT fn_get_actor_movie_count(1);
```
- [ ] Returns count

```sql
-- Test fn_is_profitable
SELECT fn_is_profitable(1);
```
- [ ] Returns 0 or 1

### Test Views
```sql
-- Test vw_movie_summary
SELECT * FROM vw_movie_summary LIMIT 5;
```
- [ ] Returns comprehensive movie data

```sql
-- Test vw_top_movies_by_collection
SELECT * FROM vw_top_movies_by_collection LIMIT 10;
```
- [ ] Returns top movies ordered by collection

```sql
-- Test vw_actor_filmography
SELECT * FROM vw_actor_filmography LIMIT 5;
```
- [ ] Returns actor filmography data

```sql
-- Test vw_production_crew_projects
SELECT * FROM vw_production_crew_projects LIMIT 5;
```
- [ ] Returns crew project history

---

## 4. Integration Testing

### Complete Workflow Test
1. [ ] Create a new movie via UI
2. [ ] Verify movie appears in database:
   ```sql
   SELECT * FROM MOVIES ORDER BY movie_id DESC LIMIT 1;
   ```
3. [ ] Add box office record for the movie via UI
4. [ ] Verify box office record in database:
   ```sql
   SELECT * FROM BOX_OFFICE ORDER BY box_id DESC LIMIT 1;
   ```
5. [ ] View movie details via UI
6. [ ] Verify profit analysis shows
7. [ ] Edit movie via UI
8. [ ] Verify audit log was created:
   ```sql
   SELECT * FROM MOVIE_AUDIT ORDER BY audit_id DESC LIMIT 1;
   ```
9. [ ] Delete movie via UI
10. [ ] Verify movie deleted from database

---

## 5. Error Handling Testing

### Test Invalid Data
- [ ] Try to create movie without required fields
- [ ] Verify validation error shows
- [ ] Try to submit invalid rating (>10)
- [ ] Verify validation prevents submission
- [ ] Try to create duplicate entry
- [ ] Verify error handling

### Test Network Errors
- [ ] Stop backend server
- [ ] Try to load a page
- [ ] Verify user-friendly error message
- [ ] Restart backend
- [ ] Verify application recovers

---

## 6. Browser Compatibility Testing

### Test in Different Browsers
- [ ] Chrome - Dashboard loads
- [ ] Chrome - CRUD operations work
- [ ] Firefox - Dashboard loads
- [ ] Firefox - CRUD operations work
- [ ] Edge - Dashboard loads
- [ ] Edge - CRUD operations work

---

## 7. Performance Testing

### Response Times
- [ ] API response < 2 seconds for simple queries
- [ ] Page load < 3 seconds
- [ ] Chart rendering < 1 second
- [ ] No lag when navigating between pages

### Data Volume
- [ ] Tables with 10+ records display correctly
- [ ] Filtering works with large datasets
- [ ] No browser freezing

---

## 8. Screenshot Capture (For Report)

Capture screenshots of:
- [ ] Dashboard page
- [ ] Movies table (READ)
- [ ] Create movie modal (CREATE)
- [ ] Edit movie modal (UPDATE)
- [ ] Delete confirmation dialog (DELETE)
- [ ] Movie details modal
- [ ] Producers table
- [ ] Box office table
- [ ] Analytics page with charts
- [ ] Top movies table
- [ ] Profit analysis table
- [ ] Procedures documentation page
- [ ] API documentation (Swagger)
- [ ] Database tables in MySQL Workbench

---

## 9. Documentation Review

- [ ] README.md is complete and accurate
- [ ] STARTUP_GUIDE.md has clear instructions
- [ ] USER_REQUIREMENT_SPECIFICATION.md is comprehensive
- [ ] PROJECT_SUMMARY.md summarizes everything
- [ ] Code has comments where necessary

---

## 10. Final Checks

- [ ] No console errors in browser (F12)
- [ ] No Python errors in backend terminal
- [ ] All SQL scripts run without errors
- [ ] .env file is properly configured
- [ ] All dependencies are installed
- [ ] Project can be cloned and set up fresh
- [ ] Git repository is up to date (if using)

---

## Demo Preparation

### Practice Demo Flow
1. [ ] Start with dashboard explanation
2. [ ] Show statistics and charts
3. [ ] Demonstrate CREATE operation (movie)
4. [ ] Show detailed view with cast/crew
5. [ ] Demonstrate UPDATE operation
6. [ ] Show analytics page
7. [ ] Explain stored procedures and triggers
8. [ ] Demonstrate DELETE operation
9. [ ] Show API documentation

### Prepare Talking Points
- [ ] Explain database design (15 tables)
- [ ] Discuss normalization (3NF)
- [ ] Explain triggers (validation, audit, business rules)
- [ ] Discuss stored procedures (complex queries)
- [ ] Explain functions (calculations)
- [ ] Talk about views (reporting)
- [ ] Discuss web architecture (SPA, REST API)

---

## Issues Found

Document any issues found during testing:

| Issue | Page/Feature | Severity | Status |
|-------|-------------|----------|--------|
| Example: Filter not working | Movies | Low | Fixed |
|  |  |  |  |
|  |  |  |  |

---

## Sign-off

- [ ] All critical tests passed
- [ ] All features working as expected
- [ ] Screenshots captured
- [ ] Documentation reviewed
- [ ] Demo prepared
- [ ] **PROJECT READY FOR SUBMISSION** ✅

---

**Tested By:** _________________
**Date:** _________________
**Status:** _________________

---

**Good luck with your demonstration! 🚀**
