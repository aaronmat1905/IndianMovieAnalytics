from pydantic import BaseModel, Field, condecimal
from typing import Optional, List
from datetime import date, datetime
from enum import Enum

# Enums for validation
class UserRole(str, Enum):
    ADMIN = "admin"
    PRODUCER = "producer"
    ANALYST = "analyst"
    VIEWER = "viewer"

class MovieStatus(str, Enum):
    PENDING = "pending"
    UPDATED = "updated"
    CONFIRMED = "confirmed"

class GenreType(str, Enum):
    DRAMA = "Drama"
    ACTION = "Action"
    COMEDY = "Comedy"
    ROMANCE = "Romance"
    THRILLER = "Thriller"
    FAMILY = "Family"
    HORROR = "Horror"
    MUSICAL = "Musical"

class RoleType(str, Enum):
    LEAD = "Lead"
    SUPPORTING = "Supporting"
    CAMEO = "Cameo"

class CrewRole(str, Enum):
    DIRECTOR = "Director"
    CINEMATOGRAPHER = "Cinematographer"
    MUSIC_DIRECTOR = "Music Director"
    EDITOR = "Editor"
    PRODUCER = "Producer"
    WRITER = "Writer"
    CHOREOGRAPHER = "Choreographer"
    OTHER = "Other"

# User models
class UserBase(BaseModel):
    username: str = Field(..., min_length=1, max_length=50)
    email: str = Field(..., pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    role: UserRole

class UserCreate(UserBase):
    password: str = Field(..., min_length=6)

class User(UserBase):
    user_id: int
    created_at: datetime
    is_active: bool = True

    class Config:
        from_attributes = True

# Producer models
class ProducerBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    company: Optional[str] = Field(None, max_length=150)
    phone: Optional[str] = Field(None, pattern=r"^[0-9+\-\s()]*$")
    email: Optional[str] = Field(None, pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    start_date: date
    region: Optional[str] = Field(None, max_length=50)

class ProducerCreate(ProducerBase):
    created_by: Optional[int] = None

class Producer(ProducerBase):
    producer_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Language models
class LanguageBase(BaseModel):
    language_name: str = Field(..., min_length=1, max_length=50)
    description: Optional[str] = None

class LanguageCreate(LanguageBase):
    pass

class Language(LanguageBase):
    language_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Genre models
class GenreBase(BaseModel):
    genre_name: str = Field(..., min_length=1, max_length=50)
    description: Optional[str] = None

class GenreCreate(GenreBase):
    pass

class Genre(GenreBase):
    genre_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Movie models
class MovieBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    release_date: Optional[date] = None
    language_id: int
    duration: Optional[int] = Field(None, gt=0)
    certification: Optional[str] = Field(None, max_length=10)
    budget: Optional[float] = Field(None, ge=0)
    ott_rights_value: Optional[float] = Field(None, ge=0)
    poster_url: Optional[str] = Field(None, max_length=500)
    plot_summary: Optional[str] = None
    imdb_rating: Optional[float] = Field(None, ge=0, le=10)
    producer_id: Optional[int] = None

class MovieCreate(MovieBase):
    created_by: Optional[int] = None

class Movie(MovieBase):
    movie_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Movie-Genre models
class MovieGenreBase(BaseModel):
    movie_id: int
    genre_id: int

class MovieGenre(MovieGenreBase):
    class Config:
        from_attributes = True

# Box Office models
class BoxOfficeBase(BaseModel):
    movie_id: int
    domestic_collection: Optional[float] = Field(None, ge=0)
    intl_collection: Optional[float] = Field(None, ge=0)
    opening_weekend: Optional[float] = Field(None, ge=0)
    profit_margin: Optional[float] = Field(None, ge=0)
    release_screens: Optional[int] = Field(None, gt=0)
    collection_status: MovieStatus = MovieStatus.PENDING

class BoxOfficeCreate(BoxOfficeBase):
    updated_by: Optional[int] = None

class BoxOffice(BoxOfficeBase):
    box_id: int
    total_collection: Optional[float] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Actor models
class ActorBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    gender: Optional[str] = Field(None, max_length=20)
    date_of_birth: Optional[date] = None
    nationality: Optional[str] = Field(None, max_length=50)
    popularity_score: Optional[float] = Field(None, ge=0, le=10)
    email: Optional[str] = Field(None, pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")

class ActorCreate(ActorBase):
    pass

class Actor(ActorBase):
    actor_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Movie Cast models
class MovieCastBase(BaseModel):
    movie_id: int
    actor_id: int
    role_name: Optional[str] = Field(None, max_length=100)
    role_type: RoleType
    screen_time_minutes: Optional[int] = Field(None, ge=0)

class MovieCast(MovieCastBase):
    cast_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Production Crew models
class ProductionCrewBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    role: CrewRole
    specialty: Optional[str] = Field(None, max_length=150)
    experience_years: Optional[int] = Field(None, ge=0)
    email: Optional[str] = Field(None, pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")

class ProductionCrewCreate(ProductionCrewBase):
    pass

class ProductionCrew(ProductionCrewBase):
    crew_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Movie Crew models
class MovieCrewBase(BaseModel):
    movie_id: int
    crew_id: int
    role_description: Optional[str] = Field(None, max_length=150)

class MovieCrew(MovieCrewBase):
    movie_crew_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Movie Statistics models
class MovieStatisticsBase(BaseModel):
    movie_id: int
    total_reviews: int = 0
    average_rating: Optional[float] = Field(None, ge=0, le=10)
    viewer_count: int = 0
    weekly_collection: Optional[float] = None
    monthly_collection: Optional[float] = None

class MovieStatistics(MovieStatisticsBase):
    stat_id: int
    last_updated: datetime

    class Config:
        from_attributes = True

# Audit models
class MovieAuditBase(BaseModel):
    movie_id: int
    operation_type: str
    modification_reason: Optional[str] = Field(None, max_length=255)

class MovieAudit(MovieAuditBase):
    audit_id: int
    old_title: Optional[str] = None
    new_title: Optional[str] = None
    old_budget: Optional[float] = None
    new_budget: Optional[float] = None
    old_release_date: Optional[date] = None
    new_release_date: Optional[date] = None
    modified_by: Optional[str] = None
    modified_at: datetime

    class Config:
        from_attributes = True

class BoxOfficeAuditBase(BaseModel):
    box_id: int
    movie_id: int
    operation_type: str

class BoxOfficeAudit(BoxOfficeAuditBase):
    audit_id: int
    old_domestic: Optional[float] = None
    new_domestic: Optional[float] = None
    old_intl: Optional[float] = None
    new_intl: Optional[float] = None
    old_margin: Optional[float] = None
    new_margin: Optional[float] = None
    modified_by: Optional[str] = None
    modified_at: datetime

    class Config:
        from_attributes = True

class ActivityLogBase(BaseModel):
    user_id: Optional[int] = None
    action: str = Field(..., min_length=1, max_length=100)
    table_name: Optional[str] = Field(None, max_length=50)
    record_id: Optional[int] = None
    details: Optional[str] = None

class ActivityLog(ActivityLogBase):
    log_id: int
    action_timestamp: datetime

    class Config:
        from_attributes = True
