from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

# Import routers
from .routes import movies, producers, genres, box_office, actors, crew, languages

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Indian Cinema DBMS Backend",
    description="A backend system for managing Indian cinema data with AI-driven analytics",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(movies.router, prefix="/api", tags=["movies"])
app.include_router(producers.router, prefix="/api", tags=["producers"])
app.include_router(genres.router, prefix="/api", tags=["genres"])
app.include_router(box_office.router, prefix="/api", tags=["box-office"])
app.include_router(actors.router)
app.include_router(crew.router)
app.include_router(languages.router)

@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Welcome to Indian Cinema DBMS Backend"}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "Indian Cinema DBMS Backend"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)