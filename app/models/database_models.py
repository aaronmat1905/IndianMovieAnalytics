from pydantic import BaseModel, Field, EmailStr, validator

from typing import Optional, List
from datetime import date
from decimal import Decimal

class ProducerCreate(BaseModel):
    name: str = Field(..., max_length=100)
    company: Optional[str] = Field(None, max_length=150)
    phone: Optional[str] = Field(None, max_length=15)
    email: Optional[EmailStr] = None
    start_date: Optional[date] = None

class ProducerResponse(BaseModel):
    producer_id: int
    name: str
    company: Optional[str]
    phone: Optional[str]
    email: Optional[str]
    start_date: Optional[date]
    experience_years: Optional[int]

class MovieCreate(BaseModel):
    title: str = Field(..., max_length=200)
    release_date: Optional[date] = None
    language: Optional[str] = Field(None, max_length=50)
    duration: Optional[int] = Field(None, gt=0)
    certification: Optional[str] = Field(None, max_length=10)
    budget: Optional[Decimal] = Field(None, ge=0)
    ott_rights_value: Optional[Decimal] = None
    poster_url: Optional[str] = Field(None, max_length=500)
    plot_summary: Optional[str] = None
    imdb_rating: Optional[Decimal] = Field(None, ge=0, le=10)
    producer_id: Optional[int] = None
    language_id: int
    genre_ids: Optional[List[int]] = []

class MovieResponse(BaseModel):
    movie_id: int
    title: str
    language: Optional[str]
    duration: Optional[int]
    certification: Optional[str]
    budget: Optional[Decimal]
    imdb_rating: Optional[Decimal]
    producer_id: Optional[int]

class MovieUpdate(BaseModel):
    title: Optional[str] = None
    release_date: Optional[date] = None
    language: Optional[str] = None
    duration: Optional[int] = None
    certification: Optional[str] = None
    budget: Optional[Decimal] = None
    ott_rights_value: Optional[Decimal] = None
    plot_summary: Optional[str] = None
    language_id: Optional[int] = None
    poster_url: Optional[str] = None

class SearchMoviesRequest(BaseModel):
    title: Optional[str] = None
    genre: Optional[str] = None
    min_rating: Optional[Decimal] = None
    max_budget: Optional[Decimal] = None
    language: Optional[str] = None
    min_duration: Optional[int] = None
    max_duration: Optional[int] = None
    producer: Optional[str] = None

# User Management Models
class UserCreate(BaseModel):
    username: str = Field(..., max_length=50)
    password: str = Field(..., min_length=6)
    email: EmailStr
    role: str = Field(..., regex='^(admin|producer|analyst|viewer)$')

class UserResponse(BaseModel):
    user_id: int
    username: str
    email: str
    role: str
    created_at: Optional[date]
    is_active: bool = True

class UserLogin(BaseModel):
    username: str
    password: str

# Language Models
class LanguageCreate(BaseModel):
    language_name: str = Field(..., max_length=50)
    description: Optional[str] = None

class LanguageResponse(BaseModel):
    language_id: int
    language_name: str
    description: Optional[str]
    created_at: Optional[date]

# Genre Models
class GenreCreate(BaseModel):
    genre_name: str = Field(..., max_length=50)
    description: Optional[str] = None

class GenreResponse(BaseModel):
    genre_id: int
    genre_name: str
    description: Optional[str]
    created_at: Optional[date]

# Actor Models
class ActorCreate(BaseModel):
    name: str = Field(..., max_length=100)
    gender: Optional[str] = Field(None, max_length=20)
    date_of_birth: Optional[date] = None
    nationality: Optional[str] = Field(None, max_length=50)
    popularity_score: Optional[Decimal] = Field(None, ge=0, le=10)
    email: Optional[EmailStr] = None

class ActorResponse(BaseModel):
    actor_id: int
    name: str
    gender: Optional[str]
    date_of_birth: Optional[date]
    nationality: Optional[str]
    popularity_score: Optional[Decimal]
    email: Optional[str]
    created_at: Optional[date]
    updated_at: Optional[date]

class ActorUpdate(BaseModel):
    name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[date] = None
    nationality: Optional[str] = None
    popularity_score: Optional[Decimal] = None
    email: Optional[str] = None

# Production Crew Models
class ProductionCrewCreate(BaseModel):
    name: str = Field(..., max_length=100)
    role: str = Field(..., regex='^(Director|Cinematographer|Music Director|Editor|Producer|Writer|Choreographer|Other)$')
    specialty: Optional[str] = Field(None, max_length=150)
    experience_years: Optional[int] = Field(None, ge=0)
    email: Optional[EmailStr] = None

class ProductionCrewResponse(BaseModel):
    crew_id: int
    name: str
    role: str
    specialty: Optional[str]
    experience_years: Optional[int]
    email: Optional[str]
    created_at: Optional[date]

# Box Office Models
class BoxOfficeCreate(BaseModel):
    movie_id: int
    domestic_collection: Optional[Decimal] = Field(None, ge=0)
    intl_collection: Optional[Decimal] = Field(None, ge=0)
    opening_weekend: Optional[Decimal] = Field(None, ge=0)
    profit_margin: Optional[Decimal] = Field(None, ge=0, le=100)
    release_screens: Optional[int] = Field(None, gt=0)
    collection_status: Optional[str] = Field('pending', max_length=30)

class BoxOfficeResponse(BaseModel):
    box_id: int
    movie_id: int
    domestic_collection: Optional[Decimal]
    intl_collection: Optional[Decimal]
    opening_weekend: Optional[Decimal]
    total_collection: Optional[Decimal]
    profit_margin: Optional[Decimal]
    release_screens: Optional[int]
    collection_status: str
    updated_by: Optional[int]
    created_at: Optional[date]
    updated_at: Optional[date]

class BoxOfficeUpdate(BaseModel):
    domestic_collection: Optional[Decimal] = None
    intl_collection: Optional[Decimal] = None
    opening_weekend: Optional[Decimal] = None
    profit_margin: Optional[Decimal] = None
    release_screens: Optional[int] = None
    collection_status: Optional[str] = None

# Movie Statistics Models
class MovieStatisticsResponse(BaseModel):
    stat_id: int
    movie_id: int
    total_reviews: int = 0
    average_rating: Optional[Decimal]
    viewer_count: int = 0
    weekly_collection: Optional[Decimal]
    monthly_collection: Optional[Decimal]
    last_updated: Optional[date]

# Cast and Crew Association Models
class MovieCastCreate(BaseModel):
    movie_id: int
    actor_id: int
    role_name: Optional[str] = Field(None, max_length=100)
    role_type: str = Field(..., regex='^(Lead|Supporting|Cameo)$')
    screen_time_minutes: Optional[int] = Field(None, ge=0)

class MovieCastResponse(BaseModel):
    cast_id: int
    movie_id: int
    actor_id: int
    role_name: Optional[str]
    role_type: str
    screen_time_minutes: Optional[int]
    created_at: Optional[date]

class MovieCrewCreate(BaseModel):
    movie_id: int
    crew_id: int
    role_description: Optional[str] = Field(None, max_length=150)

class MovieCrewResponse(BaseModel):
    movie_crew_id: int
    movie_id: int
    crew_id: int
    role_description: Optional[str]
    created_at: Optional[date]

# Movie Genres Association Models
class MovieGenresCreate(BaseModel):
    movie_id: int
    genre_id: int

class MovieGenresResponse(BaseModel):
    movie_id: int
    genre_id: int

# Audit Models
class MovieAuditResponse(BaseModel):
    audit_id: int
    movie_id: int
    old_title: Optional[str]
    new_title: Optional[str]
    old_budget: Optional[Decimal]
    new_budget: Optional[Decimal]
    old_release_date: Optional[date]
    new_release_date: Optional[date]
    modified_by: Optional[str]
    modification_reason: Optional[str]
    modified_at: Optional[date]
    operation_type: str

class BoxOfficeAuditResponse(BaseModel):
    audit_id: int
    box_id: int
    movie_id: int
    old_domestic: Optional[Decimal]
    new_domestic: Optional[Decimal]
    old_intl: Optional[Decimal]
    new_intl: Optional[Decimal]
    old_margin: Optional[Decimal]
    new_margin: Optional[Decimal]
    modified_by: Optional[str]
    modified_at: Optional[date]
    operation_type: str

class ActivityLogResponse(BaseModel):
    log_id: int
    user_id: Optional[int]
    action: str
    table_name: Optional[str]
    record_id: Optional[int]
    details: Optional[str]
    action_timestamp: Optional[date]</parameter,