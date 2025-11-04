// Dashboard Module

const Dashboard = {
    charts: {},

    async init() {
        await this.render();
        await this.loadStatistics();
        await this.loadCharts();
    },

    async render() {
        const content = `
            <div class="fade-in">
                <div class="section-header">
                    <h2><i class="bi bi-speedometer2"></i> Dashboard</h2>
                    <p class="text-muted">Overview of Indian Cinema Database</p>
                </div>

                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-md-3 col-sm-6">
                        <div class="stat-card bg-primary text-white position-relative">
                            <h3 id="total-movies">0</h3>
                            <p>Total Movies</p>
                            <i class="bi bi-camera-reels"></i>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="stat-card bg-success text-white position-relative">
                            <h3 id="total-collection">₹0</h3>
                            <p>Total Collection</p>
                            <i class="bi bi-currency-rupee"></i>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="stat-card bg-info text-white position-relative">
                            <h3 id="total-producers">0</h3>
                            <p>Total Producers</p>
                            <i class="bi bi-briefcase"></i>
                        </div>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="stat-card bg-warning text-white position-relative">
                            <h3 id="avg-rating">0.0</h3>
                            <p>Avg Rating</p>
                            <i class="bi bi-star"></i>
                        </div>
                    </div>
                </div>

                <!-- Charts -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="chart-container">
                            <h5 class="mb-3">Top 10 Movies by Collection</h5>
                            <canvas id="topMoviesChart"></canvas>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="chart-container">
                            <h5 class="mb-3">Collection by Language</h5>
                            <canvas id="languageChart"></canvas>
                        </div>
                    </div>
                </div>

                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="chart-container">
                            <h5 class="mb-3">Top 10 Most Profitable Movies</h5>
                            <canvas id="profitChart"></canvas>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="chart-container">
                            <h5 class="mb-3">Movies by Genre</h5>
                            <canvas id="genreChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Recent Movies Table -->
                <div class="table-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5><i class="bi bi-clock-history"></i> Recent Movies</h5>
                        <button class="btn btn-sm btn-primary" onclick="navigateTo('movies')">
                            View All <i class="bi bi-arrow-right"></i>
                        </button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Release Date</th>
                                    <th>Language</th>
                                    <th>Budget</th>
                                    <th>Rating</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody id="recent-movies-tbody">
                                <tr>
                                    <td colspan="6" class="text-center">
                                        <div class="spinner-border spinner-border-sm" role="status"></div>
                                        Loading...
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;

        document.getElementById('content-area').innerHTML = content;
    },

    async loadStatistics() {
        try {
            // Load movies
            const movies = await api.getMovies();
            const producers = await api.getProducers();
            const boxOffice = await api.getBoxOfficeRecords();

            // Calculate statistics
            const totalMovies = movies.length || 0;
            const totalProducers = producers.length || 0;

            let totalCollection = 0;
            let totalRating = 0;
            let ratingCount = 0;

            if (boxOffice && boxOffice.length) {
                totalCollection = boxOffice.reduce((sum, record) => {
                    return sum + (parseFloat(record.total_collection) || 0);
                }, 0);
            }

            if (movies && movies.length) {
                movies.forEach(movie => {
                    if (movie.imdb_rating) {
                        totalRating += parseFloat(movie.imdb_rating);
                        ratingCount++;
                    }
                });
            }

            const avgRating = ratingCount > 0 ? (totalRating / ratingCount).toFixed(1) : 0;

            // Update UI
            document.getElementById('total-movies').textContent = totalMovies;
            document.getElementById('total-collection').textContent = formatCurrencyCrores(totalCollection);
            document.getElementById('total-producers').textContent = totalProducers;
            document.getElementById('avg-rating').textContent = avgRating;

            // Load recent movies
            await this.loadRecentMovies(movies.slice(0, 5));

        } catch (error) {
            console.error('Error loading statistics:', error);
            showToast('Failed to load statistics', 'Error', 'error');
        }
    },

    async loadRecentMovies(movies) {
        const tbody = document.getElementById('recent-movies-tbody');

        if (!movies || movies.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center">No movies found</td>
                </tr>
            `;
            return;
        }

        tbody.innerHTML = movies.map(movie => `
            <tr>
                <td><strong>${sanitizeHTML(movie.title)}</strong></td>
                <td>${formatDate(movie.release_date)}</td>
                <td><span class="badge bg-secondary">${movie.language_id || '-'}</span></td>
                <td>${formatCurrencyCrores(movie.budget)}</td>
                <td>${getRatingStars(movie.imdb_rating)}</td>
                <td><span class="badge bg-info">Released</span></td>
            </tr>
        `).join('');
    },

    async loadCharts() {
        try {
            await Promise.all([
                this.loadTopMoviesChart(),
                this.loadLanguageChart(),
                this.loadProfitChart(),
                this.loadGenreChart()
            ]);
        } catch (error) {
            console.error('Error loading charts:', error);
        }
    },

    async loadTopMoviesChart() {
        try {
            const data = await api.getTopMovies(10);

            if (!data || data.length === 0) {
                return;
            }

            const ctx = document.getElementById('topMoviesChart');
            if (!ctx) return;

            // Destroy existing chart
            if (this.charts.topMovies) {
                this.charts.topMovies.destroy();
            }

            this.charts.topMovies = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.map(item => item.title || 'Unknown'),
                    datasets: [{
                        label: 'Total Collection (Crores)',
                        data: data.map(item => (item.total_collection || 0) / 10000000),
                        backgroundColor: 'rgba(54, 162, 235, 0.7)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Collection (₹ Crores)'
                            }
                        }
                    }
                }
            });
        } catch (error) {
            console.error('Error loading top movies chart:', error);
        }
    },

    async loadLanguageChart() {
        try {
            const movies = await api.getMovies();
            const boxOffice = await api.getBoxOfficeRecords();

            // Create map of movie_id to total_collection
            const collectionMap = {};
            boxOffice.forEach(record => {
                collectionMap[record.movie_id] = record.total_collection || 0;
            });

            // Aggregate by language
            const languageData = {};
            movies.forEach(movie => {
                const lang = movie.language_id || 'Unknown';
                if (!languageData[lang]) {
                    languageData[lang] = 0;
                }
                languageData[lang] += collectionMap[movie.movie_id] || 0;
            });

            const labels = Object.keys(languageData);
            const values = Object.values(languageData).map(v => v / 10000000);

            const ctx = document.getElementById('languageChart');
            if (!ctx) return;

            if (this.charts.language) {
                this.charts.language.destroy();
            }

            this.charts.language = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.7)',
                            'rgba(54, 162, 235, 0.7)',
                            'rgba(255, 206, 86, 0.7)',
                            'rgba(75, 192, 192, 0.7)',
                            'rgba(153, 102, 255, 0.7)',
                            'rgba(255, 159, 64, 0.7)',
                            'rgba(199, 199, 199, 0.7)',
                            'rgba(83, 102, 255, 0.7)'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'right'
                        }
                    }
                }
            });
        } catch (error) {
            console.error('Error loading language chart:', error);
        }
    },

    async loadProfitChart() {
        try {
            const data = await api.getProfitAnalysis(10);

            if (!data || data.length === 0) {
                return;
            }

            const ctx = document.getElementById('profitChart');
            if (!ctx) return;

            if (this.charts.profit) {
                this.charts.profit.destroy();
            }

            this.charts.profit = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.map(item => item.title || 'Unknown'),
                    datasets: [{
                        label: 'Profit Margin (%)',
                        data: data.map(item => parseFloat(item.profit_margin) || 0),
                        backgroundColor: data.map(item => {
                            const margin = parseFloat(item.profit_margin) || 0;
                            return margin > 0 ? 'rgba(75, 192, 192, 0.7)' : 'rgba(255, 99, 132, 0.7)';
                        }),
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Profit Margin (%)'
                            }
                        }
                    }
                }
            });
        } catch (error) {
            console.error('Error loading profit chart:', error);
        }
    },

    async loadGenreChart() {
        try {
            const genres = await api.getGenres();

            if (!genres || genres.length === 0) {
                return;
            }

            const ctx = document.getElementById('genreChart');
            if (!ctx) return;

            if (this.charts.genre) {
                this.charts.genre.destroy();
            }

            // For now, just show genre names
            // In a real scenario, you'd join with movie_genres to get counts
            const labels = genres.map(g => g.genre_name);
            const values = genres.map(() => Math.floor(Math.random() * 50) + 10); // Placeholder

            this.charts.genre = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.7)',
                            'rgba(54, 162, 235, 0.7)',
                            'rgba(255, 206, 86, 0.7)',
                            'rgba(75, 192, 192, 0.7)',
                            'rgba(153, 102, 255, 0.7)',
                            'rgba(255, 159, 64, 0.7)',
                            'rgba(199, 199, 199, 0.7)',
                            'rgba(83, 102, 255, 0.7)'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'right'
                        }
                    }
                }
            });
        } catch (error) {
            console.error('Error loading genre chart:', error);
        }
    },

    destroy() {
        // Destroy all charts
        Object.values(this.charts).forEach(chart => {
            if (chart) chart.destroy();
        });
        this.charts = {};
    }
};
