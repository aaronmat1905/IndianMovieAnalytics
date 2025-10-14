from pydantic import BaseModel, Field, EmailStr
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
    plot_summary: Optional[str] = None
    imdb_rating: Optional[Decimal] = Field(None, ge=0, le=10)
    producer_id: Optional[int] = None
    genre_ids: Optional[List[int]] = []

class MovieResponse(BaseModel):
    movie_id: int
    title: str
    release_date: Optional[date]
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
    imdb_rating: Optional[Decimal] = None
    producer_id: Optional[int] = None

class SearchMoviesRequest(BaseModel):
    title: Optional[str] = None
    genre: Optional[str] = None
    min_rating: Optional[Decimal] = None
    max_budget: Optional[Decimal] = None