// Analytics Module

const Analytics = {
    charts: {},

    async init() {
        await this.render();
        await this.loadAnalytics();
    },

    async render() {
        const content = `
            <div class="fade-in">
                <div class="section-header">
                    <h2><i class="bi bi-graph-up"></i> Analytics & Insights</h2>
                    <p class="text-muted">Advanced analytics and data insights</p>
                </div>

                <!-- Top Movies by Collection -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="table-container">
                            <h5 class="mb-3"><i class="bi bi-trophy"></i> Top 10 Movies by Collection</h5>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Rank</th>
                                            <th>Title</th>
                                            <th>Language</th>
                                            <th>Total Collection</th>
                                            <th>Profit %</th>
                                            <th>Rating</th>
                                        </tr>
                                    </thead>
                                    <tbody id="top-movies-tbody">
                                        <tr><td colspan="6" class="text-center">
                                            <div class="spinner-border" role="status"></div>
                                        </td></tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Profit Analysis -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="table-container">
                            <h5 class="mb-3"><i class="bi bi-cash-stack"></i> Most Profitable Movies</h5>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Rank</th>
                                            <th>Title</th>
                                            <th>Budget</th>
                                            <th>Collection</th>
                                            <th>Profit</th>
                                            <th>Profit Margin</th>
                                        </tr>
                                    </thead>
                                    <tbody id="profit-analysis-tbody">
                                        <tr><td colspan="6" class="text-center">
                                            <div class="spinner-border" role="status"></div>
                                        </td></tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Charts -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="chart-container">
                            <h5 class="mb-3">Collection Trends</h5>
                            <canvas id="collectionTrendChart"></canvas>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="chart-container">
                            <h5 class="mb-3">Profit Margin Distribution</h5>
                            <canvas id="profitMarginChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        `;
        document.getElementById('content-area').innerHTML = content;
    },

    async loadAnalytics() {
        await Promise.all([
            this.loadTopMovies(),
            this.loadProfitAnalysis(),
            this.loadCharts()
        ]);
    },

    async loadTopMovies() {
        try {
            const data = await api.getTopMovies(10);
            const tbody = document.getElementById('top-movies-tbody');

            if (!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center">No data available</td></tr>';
                return;
            }

            tbody.innerHTML = data.map((movie, index) => `
                <tr>
                    <td><span class="badge ${index < 3 ? 'bg-warning' : 'bg-secondary'}">#${index + 1}</span></td>
                    <td><strong>${sanitizeHTML(movie.title)}</strong></td>
                    <td>${movie.language || '-'}</td>
                    <td>${formatCurrencyCrores(movie.total_collection)}</td>
                    <td>${getProfitBadge(movie.profit_percentage || 0)}</td>
                    <td>${getRatingStars(movie.imdb_rating)}</td>
                </tr>
            `).join('');
        } catch (error) {
            console.error('Error loading top movies:', error);
            document.getElementById('top-movies-tbody').innerHTML =
                '<tr><td colspan="6" class="text-center text-danger">Failed to load data</td></tr>';
        }
    },

    async loadProfitAnalysis() {
        try {
            const data = await api.getProfitAnalysis(10);
            const tbody = document.getElementById('profit-analysis-tbody');

            if (!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center">No data available</td></tr>';
                return;
            }

            tbody.innerHTML = data.map((movie, index) => {
                const profit = (movie.total_collection || 0) - (movie.budget || 0);
                return `
                    <tr>
                        <td><span class="badge bg-success">#${index + 1}</span></td>
                        <td><strong>${sanitizeHTML(movie.title)}</strong></td>
                        <td>${formatCurrencyCrores(movie.budget)}</td>
                        <td>${formatCurrencyCrores(movie.total_collection)}</td>
                        <td>${formatCurrencyCrores(profit)}</td>
                        <td><span class="badge bg-success">${movie.profit_margin}%</span></td>
                    </tr>
                `;
            }).join('');
        } catch (error) {
            console.error('Error loading profit analysis:', error);
            document.getElementById('profit-analysis-tbody').innerHTML =
                '<tr><td colspan="6" class="text-center text-danger">Failed to load data</td></tr>';
        }
    },

    async loadCharts() {
        try {
            const topMovies = await api.getTopMovies(10);
            const profitData = await api.getProfitAnalysis(10);

            // Collection Trend Chart
            const ctx1 = document.getElementById('collectionTrendChart');
            if (ctx1 && topMovies) {
                if (this.charts.trend) this.charts.trend.destroy();
                this.charts.trend = new Chart(ctx1, {
                    type: 'line',
                    data: {
                        labels: topMovies.map(m => m.title),
                        datasets: [{
                            label: 'Total Collection (Crores)',
                            data: topMovies.map(m => (m.total_collection || 0) / 10000000),
                            borderColor: 'rgba(75, 192, 192, 1)',
                            backgroundColor: 'rgba(75, 192, 192, 0.2)',
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: { display: true, text: 'Collection (₹ Crores)' }
                            }
                        }
                    }
                });
            }

            // Profit Margin Chart
            const ctx2 = document.getElementById('profitMarginChart');
            if (ctx2 && profitData) {
                if (this.charts.margin) this.charts.margin.destroy();
                this.charts.margin = new Chart(ctx2, {
                    type: 'bar',
                    data: {
                        labels: profitData.map(m => m.title),
                        datasets: [{
                            label: 'Profit Margin (%)',
                            data: profitData.map(m => parseFloat(m.profit_margin) || 0),
                            backgroundColor: profitData.map(m => {
                                const margin = parseFloat(m.profit_margin) || 0;
                                if (margin > 100) return 'rgba(40, 167, 69, 0.7)';
                                if (margin > 50) return 'rgba(23, 162, 184, 0.7)';
                                if (margin > 0) return 'rgba(255, 193, 7, 0.7)';
                                return 'rgba(220, 53, 69, 0.7)';
                            })
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } },
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: { display: true, text: 'Profit Margin (%)' }
                            }
                        }
                    }
                });
            }
        } catch (error) {
            console.error('Error loading charts:', error);
        }
    },

    destroy() {
        Object.values(this.charts).forEach(chart => {
            if (chart) chart.destroy();
        });
        this.charts = {};
    }
};
