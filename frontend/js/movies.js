// Movies Module

const Movies = {
    currentPage: 1,
    totalPages: 1,
    filters: {},

    async init() {
        await this.render();
        await this.loadMovies();
    },

    async render() {
        const content = `
            <div class="fade-in">
                <div class="section-header d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="bi bi-camera-reels"></i> Movies Management</h2>
                        <p class="text-muted">Manage movie records with CRUD operations</p>
                    </div>
                    <button class="btn btn-primary" onclick="Movies.showCreateModal()">
                        <i class="bi bi-plus-circle"></i> Add New Movie
                    </button>
                </div>

                <!-- Filters -->
                <div class="filter-section">
                    <div class="row">
                        <div class="col-md-4">
                            <input type="text" class="form-control" id="filter-title"
                                   placeholder="Search by title..."
                                   onkeyup="Movies.applyFilters()">
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" id="filter-language" onchange="Movies.applyFilters()">
                                <option value="">All Languages</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" id="filter-producer" onchange="Movies.applyFilters()">
                                <option value="">All Producers</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button class="btn btn-secondary w-100" onclick="Movies.clearFilters()">
                                <i class="bi bi-x-circle"></i> Clear
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Movies Table -->
                <div class="table-container">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Title</th>
                                    <th>Release Date</th>
                                    <th>Language</th>
                                    <th>Duration</th>
                                    <th>Budget</th>
                                    <th>Rating</th>
                                    <th>Producer</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="movies-tbody">
                                <tr>
                                    <td colspan="9" class="text-center">
                                        <div class="spinner-border" role="status"></div>
                                        <p>Loading movies...</p>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div id="pagination-container"></div>
                </div>
            </div>

            <!-- Create/Edit Movie Modal -->
            <div class="modal fade" id="movieModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="movieModalTitle">Add New Movie</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <form id="movieForm">
                                <input type="hidden" id="movie-id">

                                <div class="row">
                                    <div class="col-md-8 mb-3">
                                        <label for="movie-title" class="form-label">Title *</label>
                                        <input type="text" class="form-control" id="movie-title" required>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label for="movie-release-date" class="form-label">Release Date *</label>
                                        <input type="date" class="form-control" id="movie-release-date" required>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <label for="movie-language" class="form-label">Language *</label>
                                        <select class="form-select" id="movie-language" required>
                                            <option value="">-- Select --</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label for="movie-duration" class="form-label">Duration (mins) *</label>
                                        <input type="number" class="form-control" id="movie-duration" min="1" required>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label for="movie-certification" class="form-label">Certification</label>
                                        <select class="form-select" id="movie-certification">
                                            <option value="">-- Select --</option>
                                            <option value="U">U</option>
                                            <option value="UA">UA</option>
                                            <option value="A">A</option>
                                            <option value="S">S</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="movie-budget" class="form-label">Budget (₹)</label>
                                        <input type="number" class="form-control" id="movie-budget" min="0" step="0.01">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="movie-ott-rights" class="form-label">OTT Rights Value (₹)</label>
                                        <input type="number" class="form-control" id="movie-ott-rights" min="0" step="0.01">
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="movie-rating" class="form-label">IMDb Rating (0-10)</label>
                                        <input type="number" class="form-control" id="movie-rating" min="0" max="10" step="0.1">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="movie-producer" class="form-label">Producer *</label>
                                        <select class="form-select" id="movie-producer" required>
                                            <option value="">-- Select --</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="movie-poster-url" class="form-label">Poster URL</label>
                                    <input type="url" class="form-control" id="movie-poster-url">
                                </div>

                                <div class="mb-3">
                                    <label for="movie-plot" class="form-label">Plot Summary</label>
                                    <textarea class="form-control" id="movie-plot" rows="3"></textarea>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" class="btn btn-primary" onclick="Movies.saveMovie()">
                                <i class="bi bi-save"></i> Save Movie
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- View Details Modal -->
            <div class="modal fade" id="movieDetailsModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Movie Details</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body" id="movie-details-content">
                            <div class="text-center">
                                <div class="spinner-border" role="status"></div>
                                <p>Loading details...</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        document.getElementById('content-area').innerHTML = content;

        // Load dropdown data
        await this.loadDropdowns();
    },

    async loadDropdowns() {
        try {
            // Load languages
            const languages = await api.getLanguages();
            const languageSelects = document.querySelectorAll('#movie-language, #filter-language');
            languageSelects.forEach(select => {
                const isFilter = select.id === 'filter-language';
                select.innerHTML = isFilter ? '<option value="">All Languages</option>' : '<option value="">-- Select --</option>';
                languages.forEach(lang => {
                    select.innerHTML += `<option value="${lang.language_id}">${lang.language_name}</option>`;
                });
            });

            // Load producers
            const producers = await api.getProducers();
            const producerSelects = document.querySelectorAll('#movie-producer, #filter-producer');
            producerSelects.forEach(select => {
                const isFilter = select.id === 'filter-producer';
                select.innerHTML = isFilter ? '<option value="">All Producers</option>' : '<option value="">-- Select --</option>';
                producers.forEach(prod => {
                    select.innerHTML += `<option value="${prod.producer_id}">${prod.name}</option>`;
                });
            });
        } catch (error) {
            console.error('Error loading dropdowns:', error);
        }
    },

    async loadMovies() {
        showLoading();
        try {
            const movies = await api.getMovies(this.filters);
            this.renderMoviesTable(movies);
        } catch (error) {
            console.error('Error loading movies:', error);
            showToast('Failed to load movies', 'Error', 'error');
            document.getElementById('movies-tbody').innerHTML = `
                <tr>
                    <td colspan="9" class="text-center text-danger">
                        <i class="bi bi-exclamation-triangle"></i> Failed to load movies
                    </td>
                </tr>
            `;
        } finally {
            hideLoading();
        }
    },

    renderMoviesTable(movies) {
        const tbody = document.getElementById('movies-tbody');

        if (!movies || movies.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="9">
                        <div class="empty-state">
                            <i class="bi bi-inbox"></i>
                            <h4>No movies found</h4>
                            <p>Try adjusting your filters or add a new movie</p>
                        </div>
                    </td>
                </tr>
            `;
            return;
        }

        tbody.innerHTML = movies.map(movie => `
            <tr>
                <td>${movie.movie_id}</td>
                <td><strong>${sanitizeHTML(movie.title)}</strong></td>
                <td>${formatDate(movie.release_date)}</td>
                <td><span class="badge bg-secondary">${movie.language_id || '-'}</span></td>
                <td>${formatDuration(movie.duration)}</td>
                <td>${formatCurrencyCrores(movie.budget)}</td>
                <td>${getRatingStars(movie.imdb_rating)}</td>
                <td>${movie.producer_id || '-'}</td>
                <td class="action-buttons">
                    <button class="btn btn-sm btn-info" onclick="Movies.viewDetails(${movie.movie_id})"
                            title="View Details">
                        <i class="bi bi-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-warning" onclick="Movies.showEditModal(${movie.movie_id})"
                            title="Edit">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="Movies.deleteMovie(${movie.movie_id})"
                            title="Delete">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    },

    showCreateModal() {
        document.getElementById('movieModalTitle').textContent = 'Add New Movie';
        document.getElementById('movieForm').reset();
        document.getElementById('movie-id').value = '';
        const modal = new bootstrap.Modal(document.getElementById('movieModal'));
        modal.show();
    },

    async showEditModal(id) {
        try {
            showLoading();
            const movie = await api.getMovie(id);

            document.getElementById('movieModalTitle').textContent = 'Edit Movie';
            document.getElementById('movie-id').value = movie.movie_id;
            document.getElementById('movie-title').value = movie.title;
            document.getElementById('movie-release-date').value = movie.release_date;
            document.getElementById('movie-language').value = movie.language_id;
            document.getElementById('movie-duration').value = movie.duration;
            document.getElementById('movie-certification').value = movie.certification || '';
            document.getElementById('movie-budget').value = movie.budget || '';
            document.getElementById('movie-ott-rights').value = movie.ott_rights_value || '';
            document.getElementById('movie-rating').value = movie.imdb_rating || '';
            document.getElementById('movie-producer').value = movie.producer_id;
            document.getElementById('movie-poster-url').value = movie.poster_url || '';
            document.getElementById('movie-plot').value = movie.plot_summary || '';

            const modal = new bootstrap.Modal(document.getElementById('movieModal'));
            modal.show();
        } catch (error) {
            console.error('Error loading movie:', error);
            showToast('Failed to load movie details', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async saveMovie() {
        const form = document.getElementById('movieForm');
        if (!form.checkValidity()) {
            form.classList.add('was-validated');
            return;
        }

        const movieId = document.getElementById('movie-id').value;
        const data = {
            title: document.getElementById('movie-title').value,
            release_date: document.getElementById('movie-release-date').value,
            language_id: parseInt(document.getElementById('movie-language').value),
            duration: parseInt(document.getElementById('movie-duration').value),
            certification: document.getElementById('movie-certification').value || null,
            budget: parseFloat(document.getElementById('movie-budget').value) || null,
            ott_rights_value: parseFloat(document.getElementById('movie-ott-rights').value) || null,
            imdb_rating: parseFloat(document.getElementById('movie-rating').value) || null,
            producer_id: parseInt(document.getElementById('movie-producer').value),
            poster_url: document.getElementById('movie-poster-url').value || null,
            plot_summary: document.getElementById('movie-plot').value || null,
            created_by: 1 // Default user
        };

        try {
            showLoading();
            if (movieId) {
                await api.updateMovie(movieId, data);
                showToast('Movie updated successfully', 'Success', 'success');
            } else {
                await api.createMovie(data);
                showToast('Movie created successfully', 'Success', 'success');
            }

            bootstrap.Modal.getInstance(document.getElementById('movieModal')).hide();
            await this.loadMovies();
        } catch (error) {
            console.error('Error saving movie:', error);
            showToast(error.message || 'Failed to save movie', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async deleteMovie(id) {
        if (!confirmAction('Are you sure you want to delete this movie? This action cannot be undone.')) {
            return;
        }

        try {
            showLoading();
            await api.deleteMovie(id);
            showToast('Movie deleted successfully', 'Success', 'success');
            await this.loadMovies();
        } catch (error) {
            console.error('Error deleting movie:', error);
            showToast(error.message || 'Failed to delete movie', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async viewDetails(id) {
        const modal = new bootstrap.Modal(document.getElementById('movieDetailsModal'));
        modal.show();

        try {
            const details = await api.getMovieDetails(id);
            const profit = await api.getMovieProfitAnalysis(id);

            const content = `
                <div class="row">
                    <div class="col-md-8">
                        <h3>${sanitizeHTML(details.movie.title)}</h3>
                        <p class="text-muted">${sanitizeHTML(details.movie.plot_summary || 'No plot summary available')}</p>

                        <div class="row mt-4">
                            <div class="col-md-6">
                                <p><strong>Release Date:</strong> ${formatDate(details.movie.release_date)}</p>
                                <p><strong>Language:</strong> ${details.movie.language_id}</p>
                                <p><strong>Duration:</strong> ${formatDuration(details.movie.duration)}</p>
                                <p><strong>Certification:</strong> ${details.movie.certification || '-'}</p>
                            </div>
                            <div class="col-md-6">
                                <p><strong>Budget:</strong> ${formatCurrencyCrores(details.movie.budget)}</p>
                                <p><strong>OTT Rights:</strong> ${formatCurrencyCrores(details.movie.ott_rights_value)}</p>
                                <p><strong>Rating:</strong> ${getRatingStars(details.movie.imdb_rating)}</p>
                                <p><strong>Producer:</strong> ${details.movie.producer_id}</p>
                            </div>
                        </div>

                        ${profit ? `
                        <div class="card mt-3">
                            <div class="card-body">
                                <h5>Box Office Performance</h5>
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong>Domestic:</strong> ${formatCurrencyCrores(profit.domestic_collection)}</p>
                                        <p><strong>International:</strong> ${formatCurrencyCrores(profit.international_collection)}</p>
                                    </div>
                                    <div class="col-md-6">
                                        <p><strong>Total Collection:</strong> ${formatCurrencyCrores(profit.total_collection)}</p>
                                        <p><strong>Profit Margin:</strong> ${profit.profit_margin}%</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        ` : ''}
                    </div>
                    <div class="col-md-4">
                        ${details.movie.poster_url ?
                            `<img src="${details.movie.poster_url}" class="img-fluid rounded" alt="Poster">` :
                            '<div class="bg-secondary text-white p-5 text-center rounded">No Poster</div>'
                        }
                    </div>
                </div>

                ${details.cast && details.cast.length > 0 ? `
                <div class="mt-4">
                    <h5>Cast</h5>
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Actor</th>
                                    <th>Role</th>
                                    <th>Type</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${details.cast.map(c => `
                                    <tr>
                                        <td>${c.actor_name || '-'}</td>
                                        <td>${c.role_name || '-'}</td>
                                        <td><span class="badge bg-info">${c.role_type || '-'}</span></td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
                ` : ''}

                ${details.crew && details.crew.length > 0 ? `
                <div class="mt-4">
                    <h5>Crew</h5>
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Role</th>
                                    <th>Description</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${details.crew.map(c => `
                                    <tr>
                                        <td>${c.crew_name || '-'}</td>
                                        <td><span class="badge bg-secondary">${c.crew_role || '-'}</span></td>
                                        <td>${c.role_description || '-'}</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
                ` : ''}
            `;

            document.getElementById('movie-details-content').innerHTML = content;
        } catch (error) {
            console.error('Error loading movie details:', error);
            document.getElementById('movie-details-content').innerHTML = `
                <div class="alert alert-danger">
                    <i class="bi bi-exclamation-triangle"></i> Failed to load movie details
                </div>
            `;
        }
    },

    applyFilters: debounce(function() {
        this.filters = {};

        const title = document.getElementById('filter-title').value;
        if (title) this.filters.title = title;

        const language = document.getElementById('filter-language').value;
        if (language) this.filters.language_id = language;

        const producer = document.getElementById('filter-producer').value;
        if (producer) this.filters.producer_id = producer;

        this.loadMovies();
    }, APP_CONFIG.DEBOUNCE_DELAY),

    clearFilters() {
        document.getElementById('filter-title').value = '';
        document.getElementById('filter-language').value = '';
        document.getElementById('filter-producer').value = '';
        this.filters = {};
        this.loadMovies();
    }
};
