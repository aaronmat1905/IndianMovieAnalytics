// API Configuration
const API_CONFIG = {
    BASE_URL: 'http://localhost:8001',
    ENDPOINTS: {
        // Movies
        MOVIES: '/api/movies',
        MOVIE_DETAILS: '/api/movies/{id}/details',
        MOVIE_PROFIT: '/api/movies/{id}/profit-analysis',

        // Producers
        PRODUCERS: '/api/producers',

        // Genres
        GENRES: '/api/genres',

        // Box Office
        BOX_OFFICE: '/api/box-office',
        MOVIE_BOX_OFFICE: '/api/movies/{id}/box-office',

        // Analytics
        TOP_MOVIES: '/api/analytics/top-movies',
        PROFIT_ANALYSIS: '/api/analytics/profit-analysis',

        // Actors (to be implemented)
        ACTORS: '/api/actors',

        // Crew (to be implemented)
        CREW: '/api/crew',

        // Languages
        LANGUAGES: '/api/languages',
    }
};

// Application Configuration
const APP_CONFIG = {
    ITEMS_PER_PAGE: 10,
    DEBOUNCE_DELAY: 300,
    TOAST_DURATION: 3000,
};

// Enums
const ENUMS = {
    USER_ROLES: ['admin', 'producer', 'analyst', 'viewer'],
    ROLE_TYPES: ['Lead', 'Supporting', 'Cameo'],
    CREW_ROLES: ['Director', 'Cinematographer', 'Music Director', 'Editor', 'Producer', 'Writer', 'Choreographer', 'Other'],
    COLLECTION_STATUS: ['pending', 'updated', 'confirmed'],
    CERTIFICATIONS: ['U', 'UA', 'A', 'S'],
    GENDERS: ['Male', 'Female', 'Other'],
};
