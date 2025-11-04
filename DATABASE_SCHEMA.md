# Indian Cinema Database Management System - Schema Documentation

## Database Overview

The Indian Cinema DBMS is a comprehensive database system designed to manage and analyze data related to the Indian film industry. The database consists of **15 tables** organized into core entities, junction tables, supporting tables, and audit tables.

---

## Entity Relationship Diagram

```
USERS ─┬─► PRODUCERS ──► MOVIES ──┬─► BOX_OFFICE
       │                          │
       └─► ACTIVITY_LOG            ├─► MOVIE_GENRES ──► GENRES
                                   │
                                   ├─► MOVIE_CAST ──► ACTORS
                                   │
                                   ├─► MOVIE_CREW ──► PRODUCTION_CREW
                                   │
                                   ├─► MOVIE_STATISTICS
                                   │
                                   └─► MOVIE_AUDIT

LANGUAGES ──► MOVIES
BOX_OFFICE ──► BOX_OFFICE_AUDIT
```

---

## Core Tables

### 1. USERS
**Purpose:** User management and role-based access control

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| user_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique user identifier |
| username | VARCHAR(50) | UNIQUE, NOT NULL | Unique username |
| password | VARCHAR(255) | NOT NULL | Hashed password (MD5) |
| email | VARCHAR(100) | UNIQUE, NOT NULL | User email address |
| role | VARCHAR(30) | NOT NULL, CHECK | User role (admin, producer, analyst, viewer) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation timestamp |
| is_active | BOOLEAN | DEFAULT TRUE | Account active status |

**Indexes:**
- `idx_user_role` on `role`

**Constraints:**
- Role must be one of: 'admin', 'producer', 'analyst', 'viewer'

---

### 2. PRODUCERS
**Purpose:** Store information about movie producers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| producer_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique producer identifier |
| name | VARCHAR(100) | NOT NULL | Producer name |
| company | VARCHAR(150) | | Production company name |
| phone | VARCHAR(15) | CHECK | Contact phone number |
| email | VARCHAR(100) | UNIQUE | Email address |
| start_date | DATE | NOT NULL | Career start date |
| region | VARCHAR(50) | | Operating region |
| created_by | INT | FK → USERS | User who created the record |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Indexes:**
- `idx_producer_name` on `name`
- `idx_company` on `company`

**Constraints:**
- Phone must match pattern: `^[0-9+\-\s()]*$`

---

### 3. LANGUAGES
**Purpose:** Film industry languages

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| language_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique language identifier |
| language_name | VARCHAR(50) | UNIQUE, NOT NULL | Language name |
| description | TEXT | | Language description |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Pre-populated Languages:**
- Hindi (Bollywood), Tamil (Kollywood), Telugu (Tollywood), Kannada, Malayalam, Marathi, Punjabi, English

---

### 4. GENRES
**Purpose:** Movie genre classification

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| genre_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique genre identifier |
| genre_name | VARCHAR(50) | UNIQUE, NOT NULL | Genre name |
| description | TEXT | | Genre description |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Pre-populated Genres:**
- Drama, Action, Comedy, Romance, Thriller, Family, Horror, Musical

---

### 5. MOVIES
**Purpose:** Core movie information

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| movie_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique movie identifier |
| title | VARCHAR(200) | NOT NULL | Movie title |
| release_date | DATE | | Release date |
| language_id | INT | NOT NULL, FK → LANGUAGES | Primary language |
| duration | INT | CHECK > 0 | Duration in minutes |
| certification | VARCHAR(10) | | Censor certification (U, UA, A, S) |
| budget | DECIMAL(15,2) | CHECK >= 0 | Production budget |
| ott_rights_value | DECIMAL(15,2) | CHECK >= 0 | OTT platform rights value |
| poster_url | VARCHAR(500) | | Movie poster URL |
| plot_summary | TEXT | | Plot summary |
| imdb_rating | DECIMAL(3,1) | CHECK 0-10 | IMDB rating |
| producer_id | INT | FK → PRODUCERS | Producer reference |
| created_by | INT | FK → USERS | User who created the record |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- `idx_title` on `title`
- `idx_release_date` on `release_date`
- `idx_language` on `language_id`
- `idx_producer` on `producer_id`

---

### 6. BOX_OFFICE
**Purpose:** Box office collection tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| box_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique box office record ID |
| movie_id | INT | UNIQUE, NOT NULL, FK → MOVIES | Movie reference |
| domestic_collection | DECIMAL(15,2) | CHECK >= 0 | Domestic box office collection |
| intl_collection | DECIMAL(15,2) | CHECK >= 0 | International collection |
| opening_weekend | DECIMAL(15,2) | CHECK >= 0 | Opening weekend collection |
| total_collection | DECIMAL(15,2) | GENERATED COLUMN | Domestic + International (auto-calculated) |
| profit_margin | DECIMAL(5,2) | CHECK >= 0 | Profit margin percentage |
| release_screens | INT | CHECK > 0 | Number of release screens |
| collection_status | VARCHAR(30) | DEFAULT 'pending' | Status (pending, updated, confirmed) |
| updated_by | INT | FK → USERS | User who last updated |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- `idx_box_office_movie` on `movie_id`

**Note:** `total_collection` is a STORED generated column automatically calculated.

---

### 7. ACTORS
**Purpose:** Actor information management

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| actor_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique actor identifier |
| name | VARCHAR(100) | NOT NULL | Actor name |
| gender | VARCHAR(20) | | Gender |
| date_of_birth | DATE | | Date of birth |
| nationality | VARCHAR(50) | | Nationality |
| popularity_score | DECIMAL(3,1) | CHECK 0-10 | Popularity score |
| email | VARCHAR(100) | UNIQUE | Email address |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- `idx_actor_name` on `name`

---

### 8. PRODUCTION_CREW
**Purpose:** Production crew members database

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| crew_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique crew member identifier |
| name | VARCHAR(100) | NOT NULL | Crew member name |
| role | VARCHAR(100) | NOT NULL, CHECK | Crew role |
| specialty | VARCHAR(150) | | Area of specialty |
| experience_years | INT | CHECK >= 0 | Years of experience |
| email | VARCHAR(100) | UNIQUE | Email address |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Indexes:**
- `idx_crew_name` on `name`
- `idx_crew_role` on `role`

**Constraints:**
- Role must be one of: 'Director', 'Cinematographer', 'Music Director', 'Editor', 'Producer', 'Writer', 'Choreographer', 'Other'

---

## Junction Tables (Many-to-Many Relationships)

### 9. MOVIE_GENRES
**Purpose:** Links movies to their genres (many-to-many)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| movie_id | INT | PRIMARY KEY (composite), FK → MOVIES | Movie reference |
| genre_id | INT | PRIMARY KEY (composite), FK → GENRES | Genre reference |

**Relationships:**
- One movie can have multiple genres
- One genre can be associated with multiple movies

---

### 10. MOVIE_CAST
**Purpose:** Links movies to actors with role details

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| cast_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique cast record ID |
| movie_id | INT | NOT NULL, FK → MOVIES | Movie reference |
| actor_id | INT | NOT NULL, FK → ACTORS | Actor reference |
| role_name | VARCHAR(100) | | Character name in movie |
| role_type | VARCHAR(20) | CHECK | Role type (Lead, Supporting, Cameo) |
| screen_time_minutes | INT | CHECK >= 0 | Screen time in minutes |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Indexes:**
- `idx_cast_movie` on `movie_id`
- `idx_cast_actor` on `actor_id`

**Constraints:**
- UNIQUE constraint on (movie_id, actor_id) - same actor can't be listed twice for one movie
- Role type must be: 'Lead', 'Supporting', or 'Cameo'

---

### 11. MOVIE_CREW
**Purpose:** Links movies to production crew members

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| movie_crew_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique movie crew record ID |
| movie_id | INT | NOT NULL, FK → MOVIES | Movie reference |
| crew_id | INT | NOT NULL, FK → PRODUCTION_CREW | Crew member reference |
| role_description | VARCHAR(150) | | Specific role description |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Indexes:**
- `idx_movie_crew_movie` on `movie_id`
- `idx_movie_crew_crew` on `crew_id`

**Constraints:**
- UNIQUE constraint on (movie_id, crew_id)

---

## Supporting Tables

### 12. MOVIE_STATISTICS
**Purpose:** Track movie performance statistics

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| stat_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique statistics record ID |
| movie_id | INT | UNIQUE, NOT NULL, FK → MOVIES | Movie reference |
| total_reviews | INT | DEFAULT 0 | Total number of reviews |
| average_rating | DECIMAL(3,1) | | Average user rating |
| viewer_count | INT | DEFAULT 0 | Total viewer count |
| weekly_collection | DECIMAL(15,2) | | Weekly box office collection |
| monthly_collection | DECIMAL(15,2) | | Monthly box office collection |
| last_updated | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- `idx_stat_movie` on `movie_id`

---

## Audit Tables

### 13. MOVIE_AUDIT
**Purpose:** Track all modifications to movie records

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| audit_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique audit record ID |
| movie_id | INT | NOT NULL, FK → MOVIES | Movie reference |
| old_title | VARCHAR(200) | | Previous title |
| new_title | VARCHAR(200) | | New title |
| old_budget | DECIMAL(15,2) | | Previous budget |
| new_budget | DECIMAL(15,2) | | New budget |
| old_release_date | DATE | | Previous release date |
| new_release_date | DATE | | New release date |
| modified_by | VARCHAR(100) | | User who made the modification |
| modification_reason | VARCHAR(255) | | Reason for modification |
| modified_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Modification timestamp |
| operation_type | VARCHAR(20) | CHECK | Operation type (INSERT, UPDATE, DELETE) |

**Indexes:**
- `idx_audit_movie` on `movie_id`
- `idx_audit_date` on `modified_at`

---

### 14. BOX_OFFICE_AUDIT
**Purpose:** Track all modifications to box office records

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| audit_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique audit record ID |
| box_id | INT | NOT NULL | Box office record reference |
| movie_id | INT | NOT NULL, FK → MOVIES | Movie reference |
| old_domestic | DECIMAL(15,2) | | Previous domestic collection |
| new_domestic | DECIMAL(15,2) | | New domestic collection |
| old_intl | DECIMAL(15,2) | | Previous international collection |
| new_intl | DECIMAL(15,2) | | New international collection |
| old_margin | DECIMAL(5,2) | | Previous profit margin |
| new_margin | DECIMAL(5,2) | | New profit margin |
| modified_by | VARCHAR(100) | | User who made the modification |
| modified_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Modification timestamp |
| operation_type | VARCHAR(20) | CHECK | Operation type (INSERT, UPDATE, DELETE) |

**Indexes:**
- `idx_box_audit_movie` on `movie_id`
- `idx_box_audit_date` on `modified_at`

---

### 15. ACTIVITY_LOG
**Purpose:** Track all user activities in the system

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| log_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique log record ID |
| user_id | INT | FK → USERS | User reference |
| action | VARCHAR(100) | NOT NULL | Action performed |
| table_name | VARCHAR(50) | | Table affected |
| record_id | INT | | Record affected |
| details | TEXT | | Additional details |
| action_timestamp | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Action timestamp |

**Indexes:**
- `idx_activity_user` on `user_id`
- `idx_activity_timestamp` on `action_timestamp`

---

## Key Relationships

### One-to-Many Relationships
1. **USERS → PRODUCERS** (one user can create many producers)
2. **USERS → MOVIES** (one user can create many movies)
3. **USERS → ACTIVITY_LOG** (one user can have many activity logs)
4. **PRODUCERS → MOVIES** (one producer can produce many movies)
5. **LANGUAGES → MOVIES** (one language can have many movies)
6. **MOVIES → BOX_OFFICE** (one movie has one box office record)
7. **MOVIES → MOVIE_STATISTICS** (one movie has one statistics record)
8. **MOVIES → MOVIE_AUDIT** (one movie can have many audit records)

### Many-to-Many Relationships
1. **MOVIES ↔ GENRES** (via MOVIE_GENRES)
2. **MOVIES ↔ ACTORS** (via MOVIE_CAST)
3. **MOVIES ↔ PRODUCTION_CREW** (via MOVIE_CREW)

---

## Database Features

### Automated Features
- **Auto-increment primary keys** on all tables
- **Timestamp tracking** (created_at, updated_at) on most tables
- **Generated columns** (total_collection in BOX_OFFICE)
- **Cascading deletes** to maintain referential integrity
- **SET NULL on delete** for non-critical foreign keys

### Data Integrity
- **CHECK constraints** on numerical ranges (ratings, budgets, etc.)
- **UNIQUE constraints** to prevent duplicates
- **Foreign key constraints** for referential integrity
- **ENUM-like constraints** using CHECK for categorical fields

### Performance Optimization
- **Strategic indexing** on frequently queried columns
- **Composite indexes** for junction tables
- **Timestamp indexes** for audit tables

---

## Validation Rules

### User Roles
- `admin`, `producer`, `analyst`, `viewer`

### Movie Certifications
- `U` (Universal), `UA` (Universal Adult), `A` (Adult), `S` (Special)

### Role Types (Actors)
- `Lead`, `Supporting`, `Cameo`

### Crew Roles
- `Director`, `Cinematographer`, `Music Director`, `Editor`, `Producer`, `Writer`, `Choreographer`, `Other`

### Collection Status
- `pending`, `updated`, `confirmed`

### Operation Types (Audit)
- `INSERT`, `UPDATE`, `DELETE`

---

## Database Statistics

- **Total Tables:** 15
- **Core Entity Tables:** 8
- **Junction Tables:** 3
- **Supporting Tables:** 1
- **Audit Tables:** 3
- **Total Indexes:** 25+
- **Foreign Key Relationships:** 18+

---

## Usage Guidelines

### For Developers
1. Always use transactions for multi-table operations
2. Respect foreign key constraints
3. Use prepared statements to prevent SQL injection
4. Check audit tables for data history
5. Monitor activity logs for security

### For Database Administrators
1. Regular backups of the entire database
2. Monitor index performance
3. Review audit tables regularly
4. Archive old activity logs periodically
5. Optimize queries based on usage patterns

---

*Last Updated: 2025-11-04*
