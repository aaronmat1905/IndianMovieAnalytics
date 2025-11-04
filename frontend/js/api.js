// API Service Layer

class APIService {
    constructor(baseURL) {
        this.baseURL = baseURL;
    }

    // Generic request method
    async request(endpoint, method = 'GET', data = null, params = null) {
        try {
            const url = new URL(this.baseURL + endpoint);

            // Add query parameters
            if (params) {
                Object.keys(params).forEach(key => {
                    if (params[key] !== null && params[key] !== undefined && params[key] !== '') {
                        url.searchParams.append(key, params[key]);
                    }
                });
            }

            const options = {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                },
            };

            // Add body for POST, PUT, PATCH
            if (data && ['POST', 'PUT', 'PATCH'].includes(method)) {
                options.body = JSON.stringify(data);
            }

            const response = await fetch(url, options);

            // Handle non-JSON responses
            const contentType = response.headers.get('content-type');
            if (!contentType || !contentType.includes('application/json')) {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return { success: true };
            }

            const responseData = await response.json();

            if (!response.ok) {
                throw new Error(responseData.detail || `HTTP error! status: ${response.status}`);
            }

            return responseData;
        } catch (error) {
            console.error('API Request Error:', error);
            throw error;
        }
    }

    // GET request
    async get(endpoint, params = null) {
        return this.request(endpoint, 'GET', null, params);
    }

    // POST request
    async post(endpoint, data) {
        return this.request(endpoint, 'POST', data);
    }

    // PUT request
    async put(endpoint, data) {
        return this.request(endpoint, 'PUT', data);
    }

    // DELETE request
    async delete(endpoint) {
        return this.request(endpoint, 'DELETE');
    }

    // MOVIES
    async getMovies(params = {}) {
        return this.get(API_CONFIG.ENDPOINTS.MOVIES, params);
    }

    async getMovie(id) {
        return this.get(`${API_CONFIG.ENDPOINTS.MOVIES}/${id}`);
    }

    async createMovie(data) {
        return this.post(API_CONFIG.ENDPOINTS.MOVIES, data);
    }

    async updateMovie(id, data) {
        return this.put(`${API_CONFIG.ENDPOINTS.MOVIES}/${id}`, data);
    }

    async deleteMovie(id) {
        return this.delete(`${API_CONFIG.ENDPOINTS.MOVIES}/${id}`);
    }

    async getMovieDetails(id) {
        return this.get(API_CONFIG.ENDPOINTS.MOVIE_DETAILS.replace('{id}', id));
    }

    async getMovieProfitAnalysis(id) {
        return this.get(API_CONFIG.ENDPOINTS.MOVIE_PROFIT.replace('{id}', id));
    }

    // PRODUCERS
    async getProducers(params = {}) {
        return this.get(API_CONFIG.ENDPOINTS.PRODUCERS, params);
    }

    async getProducer(id) {
        return this.get(`${API_CONFIG.ENDPOINTS.PRODUCERS}/${id}`);
    }

    async createProducer(data) {
        return this.post(API_CONFIG.ENDPOINTS.PRODUCERS, data);
    }

    async updateProducer(id, data) {
        return this.put(`${API_CONFIG.ENDPOINTS.PRODUCERS}/${id}`, data);
    }

    async deleteProducer(id) {
        return this.delete(`${API_CONFIG.ENDPOINTS.PRODUCERS}/${id}`);
    }

    // GENRES
    async getGenres(params = {}) {
        return this.get(API_CONFIG.ENDPOINTS.GENRES, params);
    }

    async getGenre(id) {
        return this.get(`${API_CONFIG.ENDPOINTS.GENRES}/${id}`);
    }

    async createGenre(data) {
        return this.post(API_CONFIG.ENDPOINTS.GENRES, data);
    }

    async updateGenre(id, data) {
        return this.put(`${API_CONFIG.ENDPOINTS.GENRES}/${id}`, data);
    }

    async deleteGenre(id) {
        return this.delete(`${API_CONFIG.ENDPOINTS.GENRES}/${id}`);
    }

    // BOX OFFICE
    async getBoxOfficeRecords(params = {}) {
        return this.get(API_CONFIG.ENDPOINTS.BOX_OFFICE, params);
    }

    async getBoxOfficeRecord(id) {
        return this.get(`${API_CONFIG.ENDPOINTS.BOX_OFFICE}/${id}`);
    }

    async createBoxOfficeRecord(data) {
        return this.post(API_CONFIG.ENDPOINTS.BOX_OFFICE, data);
    }

    async updateBoxOfficeRecord(id, data) {
        return this.put(`${API_CONFIG.ENDPOINTS.BOX_OFFICE}/${id}`, data);
    }

    async deleteBoxOfficeRecord(id) {
        return this.delete(`${API_CONFIG.ENDPOINTS.BOX_OFFICE}/${id}`);
    }

    async getMovieBoxOffice(movieId) {
        return this.get(API_CONFIG.ENDPOINTS.MOVIE_BOX_OFFICE.replace('{id}', movieId));
    }

    // ANALYTICS
    async getTopMovies(limit = 10) {
        return this.get(API_CONFIG.ENDPOINTS.TOP_MOVIES, { limit });
    }

    async getProfitAnalysis(limit = 10) {
        return this.get(API_CONFIG.ENDPOINTS.PROFIT_ANALYSIS, { limit });
    }

    // ACTORS (to be implemented in backend)
    async getActors(params = {}) {
        return this.get(API_CONFIG.ENDPOINTS.ACTORS, params);
    }

    async getActor(id) {
        return this.get(`${API_CONFIG.ENDPOINTS.ACTORS}/${id}`);
    }

    async createActor(data) {
        return this.post(API_CONFIG.ENDPOINTS.ACTORS, data);
    }

    async updateActor(id, data) {
        return this.put(`${API_CONFIG.ENDPOINTS.ACTORS}/${id}`, data);
    }

    async deleteActor(id) {
        return this.delete(`${API_CONFIG.ENDPOINTS.ACTORS}/${id}`);
    }

    // CREW (to be implemented in backend)
    async getCrew(params = {}) {
        return this.get(API_CONFIG.ENDPOINTS.CREW, params);
    }

    async getCrewMember(id) {
        return this.get(`${API_CONFIG.ENDPOINTS.CREW}/${id}`);
    }

    async createCrewMember(data) {
        return this.post(API_CONFIG.ENDPOINTS.CREW, data);
    }

    async updateCrewMember(id, data) {
        return this.put(`${API_CONFIG.ENDPOINTS.CREW}/${id}`, data);
    }

    async deleteCrewMember(id) {
        return this.delete(`${API_CONFIG.ENDPOINTS.CREW}/${id}`);
    }

    // LANGUAGES
    async getLanguages(params = {}) {
        return this.get(API_CONFIG.ENDPOINTS.LANGUAGES, params);
    }
}

// Create global API instance
const api = new APIService(API_CONFIG.BASE_URL);
