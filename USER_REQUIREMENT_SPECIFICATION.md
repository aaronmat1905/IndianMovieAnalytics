## # Indian Cinema Database Management System
# User Requirement Specification (URS)

---

## Team Details

**Team Members:**
1. Aaron Thomas Mathew - [GitHub](https://github.com/aaronmat1905)
2. Aashlesh Lokesh - [GitHub](https://github.com/aashlesh-lokesh)

**Course:** Database Management System (UE23CS351A)
**Institution:** PES University
**Project Type:** Experiential Learning Level 2 (Orange Problem)

---

## 1. Purpose of the Project

The **Indian Cinema Database Management System** is designed to provide a comprehensive platform for managing and analyzing data related to Indian cinema across multiple regional film industries. The system addresses the need for centralized data management of movies, producers, actors, crew members, box office collections, and performance analytics.

The primary purpose is to enable stakeholders such as film producers, distributors, analysts, and researchers to:
- Track and manage movie production data efficiently
- Analyze box office performance and profitability
- Make data-driven decisions based on historical trends and analytics
- Maintain audit trails for critical business operations
- Generate insights for revenue forecasting and market analysis

This system serves as a foundation for AI-driven predictive analytics, enabling advanced features like revenue forecasting, trend analysis, and recommendation systems for the Indian film industry.

---

## 2. Scope of the Project

The Indian Cinema DBMS encompasses the complete lifecycle of movie data management, from pre-production to post-release analytics. The system covers:

### **In Scope:**
- Management of 8 major Indian film languages (Hindi, Tamil, Telugu, Kannada, Malayalam, Marathi, Punjabi, English)
- Complete movie information including budget, ratings, certifications, and release dates
- Producer and production company management with regional segmentation
- Actor database with popularity scoring and filmography tracking
- Production crew management (directors, cinematographers, music directors, editors, etc.)
- Box office collection tracking (domestic, international, opening weekend)
- Genre classification and multi-genre movie support
- OTT rights valuation and tracking
- Automated audit logging for data integrity
- Complex analytical queries and reporting
- Web-based user interface for CRUD operations
- Stored procedures for business logic encapsulation
- Data validation through triggers
- Performance statistics and trending analysis

### **Out of Scope:**
- User authentication and role-based access control (designed but not enforced)
- Payment processing or financial transactions
- Ticket booking or distribution management
- Marketing campaign management
- Social media integration
- Real-time streaming or video hosting
- Mobile application development
- Multi-language UI support (interface is English-only)

---

## 3. Detailed Description

### **System Overview:**

The Indian Cinema DBMS is a relational database application built on MySQL with a FastAPI backend and modern web frontend. The system manages 15 database tables (10 core entities, 3 audit tables, 2 junction tables) with comprehensive relationships, constraints, and business logic enforcement.

### **Key Components:**

#### **3.1 Data Management Layer**
- **15 Database Tables:** Normalized schema following 3NF
- **14 Triggers:** For validation, audit logging, and business rule enforcement
- **10 Stored Procedures:** For complex operations and transaction management
- **10 User-Defined Functions:** For calculations and derived data
- **4 Database Views:** For reporting and complex queries

#### **3.2 Application Layer**
- **RESTful API:** Built with FastAPI framework
- **Connection Pooling:** Efficient database connection management
- **Data Validation:** Using Pydantic models
- **Error Handling:** Comprehensive exception management
- **Logging:** Activity and error logging

#### **3.3 Presentation Layer**
- **Single Page Application (SPA):** Modern web interface
- **Responsive Design:** Bootstrap-based UI
- **Data Visualization:** Chart.js integration for analytics
- **CRUD Interfaces:** User-friendly forms and tables
- **Real-time Feedback:** Toast notifications and loading states

### **Entities and Relationships:**

**Core Entities:**
1. **USERS:** System users with role-based access (admin, producer, analyst, viewer)
2. **PRODUCERS:** Film producers and production companies
3. **LANGUAGES:** Film industry languages
4. **GENRES:** Movie genre classifications
5. **MOVIES:** Central entity containing movie information
6. **BOX_OFFICE:** Box office collection data
7. **ACTORS:** Actor information with popularity metrics
8. **PRODUCTION_CREW:** Crew members (directors, cinematographers, etc.)
9. **MOVIE_STATISTICS:** Performance metrics and analytics
10. **MOVIE_GENRES:** Many-to-many relationship between movies and genres
11. **MOVIE_CAST:** Actor-movie relationships with role information
12. **MOVIE_CREW:** Crew-movie relationships

**Audit Entities:**
13. **MOVIE_AUDIT:** Tracks all movie modifications
14. **BOX_OFFICE_AUDIT:** Tracks box office updates
15. **ACTIVITY_LOG:** General system activity logging

### **Relationships:**
- Movies → Producer (Many-to-One)
- Movies → Language (Many-to-One)
- Movies → Genres (Many-to-Many via MOVIE_GENRES)
- Movies → Actors (Many-to-Many via MOVIE_CAST)
- Movies → Crew (Many-to-Many via MOVIE_CREW)
- Movies → Box Office (One-to-One)
- Movies → Statistics (One-to-One)

---

## 4. Functional Requirements

### **FR-1: User Management**
**Description:** System shall manage user accounts with role-based permissions
- Create, read, update, delete user accounts
- Assign roles: admin, producer, analyst, viewer
- Track user creation timestamps and active status
- Maintain user credentials with MD5 hashing

### **FR-2: Producer Management**
**Description:** System shall manage producer and production company information
- Add new producers with company details
- Update producer contact information (phone, email)
- Track production start date and experience
- Categorize producers by region
- View producer's filmography
- Calculate total movies produced per producer

### **FR-3: Movie Management**
**Description:** System shall comprehensively manage movie data
- Create new movie entries with complete metadata
- Associate movies with producers, languages, and genres
- Store plot summaries and poster URLs
- Track budget, OTT rights value, and certification
- Maintain IMDb ratings (0-10 scale)
- Calculate movie status (Not Scheduled, Upcoming, Released, etc.)
- Support multi-genre classification
- Enforce data validation (duration > 0, rating 0-10)

### **FR-4: Cast and Crew Management**
**Description:** System shall manage actor and crew member information
- Maintain actor profiles with demographics
- Track popularity scores (0-10 scale)
- Record date of birth and nationality
- Assign crew members to specific roles
- Track experience years for crew members
- Define role types for actors (Lead, Supporting, Cameo)
- Record screen time for cast members
- Prevent duplicate cast/crew assignments

### **FR-5: Box Office Tracking**
**Description:** System shall track and analyze box office collections
- Record domestic and international collections
- Track opening weekend performance
- Calculate total collections automatically
- Monitor profit margins
- Track release screen counts
- Maintain collection status (pending/updated)
- Generate profit analysis reports
- Compare budget vs. collection

### **FR-6: Genre Classification**
**Description:** System shall categorize movies by genres
- Maintain predefined genre list (Drama, Action, Comedy, etc.)
- Support multiple genres per movie
- Enable genre-based movie filtering
- Generate genre-wise statistics

### **FR-7: Language Support**
**Description:** System shall support multiple Indian film languages
- Maintain language master data
- Associate movies with primary language
- Generate language-wise box office summaries
- Track movie count per language

### **FR-8: Analytics and Reporting**
**Description:** System shall provide comprehensive analytics capabilities
- Generate top movies by collection
- Calculate profit percentages and margins
- Analyze language-wise performance
- Rank actors by popularity
- Track yearly movie trends
- Display visual charts and graphs
- Export analytics data

### **FR-9: Audit Trail**
**Description:** System shall maintain complete audit history
- Log all movie modifications (INSERT, UPDATE, DELETE)
- Track box office collection changes
- Record user activities
- Capture modification timestamps
- Store old and new values for comparisons
- Include modification reasons

### **FR-10: Data Validation and Integrity**
**Description:** System shall enforce data quality and consistency
- Validate all numeric constraints (ratings, budgets, scores)
- Prevent negative collections or budgets
- Enforce date validations
- Check email and phone formats
- Prevent duplicate entries
- Maintain referential integrity
- Auto-calculate derived fields

### **FR-11: Transaction Management**
**Description:** System shall ensure ACID properties
- Use transactions for multi-step operations
- Rollback on errors
- Ensure data consistency
- Handle concurrent operations
- Provide error messages

### **FR-12: Search and Filtering**
**Description:** System shall enable advanced search capabilities
- Search movies by title
- Filter by language, producer, genre
- Search actors and crew by name
- Filter by date ranges
- Support partial matching

### **FR-13: Stored Procedures**
**Description:** System shall encapsulate business logic in procedures
- sp_add_movie: Create movie with related records
- sp_update_box_office: Update collections with audit
- sp_get_movie_details: Retrieve complete movie info
- sp_get_profit_analysis: Calculate profitability
- sp_get_language_box_office_summary: Language-wise aggregation
- sp_get_top_actors: Rank actors by popularity
- sp_delete_movie: Safe deletion with cleanup

### **FR-14: User-Defined Functions**
**Description:** System shall provide reusable calculation functions
- fn_calculate_experience: Years calculation
- fn_get_movie_status: Status determination
- fn_calculate_profit_percentage: Profit calculation
- fn_get_actor_movie_count: Count actor's movies
- fn_get_producer_movie_count: Count producer's movies
- fn_is_profitable: Boolean profit check
- fn_get_actor_average_rating: Average rating calculation
- fn_get_producer_total_budget: Total budget calculation

### **FR-15: Database Views**
**Description:** System shall provide simplified query interfaces
- vw_movie_summary: Comprehensive movie overview
- vw_top_movies_by_collection: Top grossing movies
- vw_actor_filmography: Actor's movie history
- vw_production_crew_projects: Crew project history

### **FR-16: Web User Interface**
**Description:** System shall provide intuitive web interface
- Dashboard with statistics and charts
- CRUD forms for all entities
- Data tables with pagination
- Modal dialogs for details
- Responsive design for mobile/desktop
- Real-time notifications
- Loading indicators

### **FR-17: RESTful API**
**Description:** System shall expose RESTful endpoints
- GET /api/movies - List all movies
- POST /api/movies - Create movie
- PUT /api/movies/{id} - Update movie
- DELETE /api/movies/{id} - Delete movie
- Similar endpoints for all entities
- API documentation (Swagger/OpenAPI)
- JSON request/response format

### **FR-18: Error Handling**
**Description:** System shall gracefully handle errors
- Display user-friendly error messages
- Log detailed error information
- Prevent data corruption on errors
- Provide recovery suggestions
- Handle database connection failures

### **FR-19: Performance Optimization**
**Description:** System shall maintain acceptable performance
- Database indexing on frequent queries
- Connection pooling
- Efficient query execution
- Pagination for large datasets
- Caching strategies

### **FR-20: Data Export**
**Description:** System shall support data export
- Export analytics to CSV
- Generate printable reports
- Support data backup
- Enable data migration

---

## 5. Non-Functional Requirements

### **NFR-1: Performance**
- API response time < 2 seconds for standard queries
- Page load time < 3 seconds
- Support up to 100 concurrent users
- Database query execution < 1 second

### **NFR-2: Scalability**
- Database should handle 100,000+ movie records
- Support 1 million+ box office records
- Handle 10,000+ actor/crew profiles

### **NFR-3: Reliability**
- System uptime: 99% availability
- Automatic error recovery
- Data backup mechanisms
- Transaction rollback on failures

### **NFR-4: Usability**
- Intuitive UI requiring minimal training
- Responsive design for all screen sizes
- Clear error messages
- Consistent navigation

### **NFR-5: Maintainability**
- Modular code architecture
- Comprehensive code comments
- Separation of concerns
- Version control with Git

### **NFR-6: Security**
- SQL injection prevention (parameterized queries)
- Input validation and sanitization
- HTTPS support (production)
- Secure password storage (MD5 - to be upgraded)

### **NFR-7: Compatibility**
- Support major browsers (Chrome, Firefox, Edge, Safari)
- Python 3.10+ compatibility
- MySQL 8.0+ compatibility

---

## 6. System Constraints

1. **Database:** MySQL 8.0 or higher required
2. **Backend:** Python 3.10+, FastAPI framework
3. **Frontend:** HTML5, CSS3, JavaScript (ES6+)
4. **Browser:** Modern browsers with JavaScript enabled
5. **Network:** localhost or LAN deployment
6. **Storage:** Minimum 100MB database storage
7. **Memory:** Minimum 2GB RAM recommended

---

## 7. Assumptions and Dependencies

### **Assumptions:**
- MySQL server is properly configured and running
- Users have basic computer literacy
- Stable internet connection for CDN resources (Bootstrap, Chart.js)
- Data entry accuracy is user's responsibility
- System operates in single timezone

### **Dependencies:**
- Python packages: FastAPI, Uvicorn, MySQL Connector, Pydantic
- JavaScript libraries: Bootstrap 5.3, Chart.js 4.4, Bootstrap Icons
- MySQL database server
- Web browser with modern JavaScript support

---

## 8. Success Criteria

The project will be considered successful when:

1. ✅ All 15 database tables are created with proper constraints
2. ✅ All 14 triggers are functional and tested
3. ✅ All 10 stored procedures execute correctly
4. ✅ All 10 functions return expected results
5. ✅ All 4 views display correct data
6. ✅ CRUD operations work for all entities
7. ✅ Web interface is fully functional and responsive
8. ✅ API endpoints return correct responses
9. ✅ Data validation works as expected
10. ✅ Audit trails are properly maintained
11. ✅ Analytics and charts display correctly
12. ✅ System handles errors gracefully
13. ✅ Documentation is complete and accurate
14. ✅ Project can be demonstrated without errors

---

**Document Version:** 1.0
**Last Updated:** November 4, 2025
**Status:** Final

---

**Prepared by:**
Aaron Thomas Mathew & Aashlesh Lokesh
Database Management System Project Team
