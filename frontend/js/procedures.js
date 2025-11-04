// Procedures & Functions Module

const Procedures = {
    async init() {
        this.render();
    },

    render() {
        const content = `
            <div class="fade-in">
                <div class="section-header">
                    <h2><i class="bi bi-gear"></i> Stored Procedures & Functions</h2>
                    <p class="text-muted">Execute database procedures and functions</p>
                </div>

                <div class="row">
                    <!-- Procedures -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-primary text-white">
                                <h5><i class="bi bi-code-square"></i> Stored Procedures</h5>
                            </div>
                            <div class="card-body">
                                <div class="list-group">
                                    <div class="list-group-item">
                                        <h6>sp_add_movie</h6>
                                        <p class="mb-2 text-muted">Create a new movie with statistics and box office record</p>
                                        <button class="btn btn-sm btn-primary" onclick="Procedures.showProcedureInfo('sp_add_movie')">
                                            View Details
                                        </button>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>sp_update_box_office</h6>
                                        <p class="mb-2 text-muted">Update box office collections with audit trail</p>
                                        <button class="btn btn-sm btn-primary" onclick="Procedures.showProcedureInfo('sp_update_box_office')">
                                            View Details
                                        </button>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>sp_get_movie_details</h6>
                                        <p class="mb-2 text-muted">Get complete movie information (nested query)</p>
                                        <button class="btn btn-sm btn-primary" onclick="Procedures.showProcedureInfo('sp_get_movie_details')">
                                            View Details
                                        </button>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>sp_get_profit_analysis</h6>
                                        <p class="mb-2 text-muted">Analyze movie profitability with calculations</p>
                                        <button class="btn btn-sm btn-primary" onclick="Procedures.showProcedureInfo('sp_get_profit_analysis')">
                                            View Details
                                        </button>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>sp_get_language_box_office_summary</h6>
                                        <p class="mb-2 text-muted">Aggregate box office data by language</p>
                                        <button class="btn btn-sm btn-primary" onclick="Procedures.showProcedureInfo('sp_get_language_box_office_summary')">
                                            View Details
                                        </button>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>sp_get_top_actors</h6>
                                        <p class="mb-2 text-muted">Get top actors by popularity score</p>
                                        <button class="btn btn-sm btn-primary" onclick="Procedures.showProcedureInfo('sp_get_top_actors')">
                                            View Details
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Functions -->
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-success text-white">
                                <h5><i class="bi bi-calculator"></i> User-Defined Functions</h5>
                            </div>
                            <div class="card-body">
                                <div class="list-group">
                                    <div class="list-group-item">
                                        <h6>fn_calculate_experience</h6>
                                        <p class="mb-2 text-muted">Calculate years of experience from start date</p>
                                        <span class="badge bg-success">Returns: INT</span>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>fn_get_movie_status</h6>
                                        <p class="mb-2 text-muted">Determine movie release status</p>
                                        <span class="badge bg-success">Returns: VARCHAR(50)</span>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>fn_calculate_profit_percentage</h6>
                                        <p class="mb-2 text-muted">Calculate profit percentage with safe division</p>
                                        <span class="badge bg-success">Returns: DECIMAL(5,2)</span>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>fn_get_actor_movie_count</h6>
                                        <p class="mb-2 text-muted">Count total movies for an actor</p>
                                        <span class="badge bg-success">Returns: INT</span>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>fn_get_producer_movie_count</h6>
                                        <p class="mb-2 text-muted">Count total movies for a producer</p>
                                        <span class="badge bg-success">Returns: INT</span>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>fn_is_profitable</h6>
                                        <p class="mb-2 text-muted">Check if movie is profitable (boolean)</p>
                                        <span class="badge bg-success">Returns: INT (0/1)</span>
                                    </div>
                                    <div class="list-group-item">
                                        <h6>fn_get_actor_average_rating</h6>
                                        <p class="mb-2 text-muted">Calculate average rating of actor's movies</p>
                                        <span class="badge bg-success">Returns: DECIMAL(3,1)</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Triggers Info -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header bg-warning">
                                <h5><i class="bi bi-lightning"></i> Active Triggers (14 Total)</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-4">
                                        <h6>Audit Logging (6)</h6>
                                        <ul class="small">
                                            <li>tr_movie_insert_audit</li>
                                            <li>tr_movie_update_audit</li>
                                            <li>tr_movie_delete_audit</li>
                                            <li>tr_box_office_insert_audit</li>
                                            <li>tr_log_activity_on_actor_insert</li>
                                            <li>tr_log_activity_on_crew_insert</li>
                                        </ul>
                                    </div>
                                    <div class="col-md-4">
                                        <h6>Data Validation (5)</h6>
                                        <ul class="small">
                                            <li>tr_box_office_validation</li>
                                            <li>tr_validate_actor_data</li>
                                            <li>tr_validate_crew_data</li>
                                            <li>tr_validate_movie_data</li>
                                            <li>tr_validate_movie_cast</li>
                                        </ul>
                                    </div>
                                    <div class="col-md-4">
                                        <h6>Business Rules (3)</h6>
                                        <ul class="small">
                                            <li>tr_prevent_duplicate_cast</li>
                                            <li>tr_prevent_duplicate_crew</li>
                                            <li>tr_update_movie_stats</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Views Info -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h5><i class="bi bi-eye"></i> Database Views (4 Total)</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="list-group">
                                            <div class="list-group-item">
                                                <h6>vw_movie_summary</h6>
                                                <p class="mb-0 text-muted small">Comprehensive movie overview with performance metrics</p>
                                            </div>
                                            <div class="list-group-item">
                                                <h6>vw_top_movies_by_collection</h6>
                                                <p class="mb-0 text-muted small">Top grossing movies with profit calculations</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="list-group">
                                            <div class="list-group-item">
                                                <h6>vw_actor_filmography</h6>
                                                <p class="mb-0 text-muted small">Actor's complete movie history and roles</p>
                                            </div>
                                            <div class="list-group-item">
                                                <h6>vw_production_crew_projects</h6>
                                                <p class="mb-0 text-muted small">Crew member project history and experience</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Procedure Details Modal -->
            <div class="modal fade" id="procedureModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title" id="procedureModalTitle">Procedure Details</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body" id="procedure-details">
                        </div>
                    </div>
                </div>
            </div>
        `;
        document.getElementById('content-area').innerHTML = content;
    },

    showProcedureInfo(procName) {
        const procedures = {
            'sp_add_movie': {
                name: 'sp_add_movie',
                description: 'Creates a new movie record with automatic statistics and box office initialization',
                parameters: [
                    'IN p_title VARCHAR(255)',
                    'IN p_release_date DATE',
                    'IN p_language_id INT',
                    'IN p_duration INT',
                    'IN p_certification VARCHAR(10)',
                    'IN p_budget DECIMAL(15,2)',
                    'IN p_ott_rights_value DECIMAL(15,2)',
                    'IN p_poster_url VARCHAR(500)',
                    'IN p_plot_summary TEXT',
                    'IN p_imdb_rating DECIMAL(3,1)',
                    'IN p_producer_id INT',
                    'IN p_created_by INT',
                    'OUT p_movie_id INT',
                    'OUT p_message VARCHAR(255)'
                ],
                features: ['Transaction management', 'Error handling', 'Auto-creates statistics record', 'Auto-creates box office record']
            },
            'sp_update_box_office': {
                name: 'sp_update_box_office',
                description: 'Updates box office collections with automatic audit trail',
                parameters: [
                    'IN p_movie_id INT',
                    'IN p_domestic_collection DECIMAL(15,2)',
                    'IN p_international_collection DECIMAL(15,2)',
                    'IN p_opening_weekend DECIMAL(15,2)',
                    'IN p_profit_margin DECIMAL(5,2)',
                    'IN p_release_screens INT',
                    'IN p_updated_by INT',
                    'OUT p_message VARCHAR(255)'
                ],
                features: ['Transaction management', 'Audit logging', 'Data validation', 'Status update']
            },
            'sp_get_movie_details': {
                name: 'sp_get_movie_details',
                description: 'Retrieves complete movie information including cast and crew (Nested Query)',
                parameters: ['IN p_movie_id INT'],
                features: ['Returns 3 result sets', 'Movie information', 'Cast details', 'Crew details', 'Uses JOINs and nested queries']
            },
            'sp_get_profit_analysis': {
                name: 'sp_get_profit_analysis',
                description: 'Analyzes movie profitability with detailed calculations',
                parameters: ['IN p_movie_id INT'],
                features: ['Profit calculations', 'Margin analysis', 'Uses fn_calculate_profit_percentage', 'JOIN queries']
            },
            'sp_get_language_box_office_summary': {
                name: 'sp_get_language_box_office_summary',
                description: 'Aggregate box office statistics grouped by language',
                parameters: ['None'],
                features: ['GROUP BY aggregation', 'SUM, AVG, MAX functions', 'Language-wise totals', 'Performance metrics']
            },
            'sp_get_top_actors': {
                name: 'sp_get_top_actors',
                description: 'Get top actors ranked by popularity score',
                parameters: ['IN p_limit INT (default 10)'],
                features: ['Ranking query', 'Popularity sorting', 'Movie count', 'Filmography aggregation']
            }
        };

        const proc = procedures[procName];
        if (!proc) return;

        const content = `
            <h4>${proc.name}</h4>
            <p class="text-muted">${proc.description}</p>

            <h6 class="mt-3">Parameters:</h6>
            <ul class="list-group mb-3">
                ${proc.parameters.map(p => `<li class="list-group-item"><code>${p}</code></li>`).join('')}
            </ul>

            <h6>Features:</h6>
            <ul>
                ${proc.features.map(f => `<li>${f}</li>`).join('')}
            </ul>

            <div class="alert alert-info mt-3">
                <strong>Usage in API:</strong> This procedure is called via the backend API endpoints.
                Check the Movies and Box Office modules to see it in action.
            </div>
        `;

        document.getElementById('procedure-details').innerHTML = content;
        document.getElementById('procedureModalTitle').textContent = proc.name;
        new bootstrap.Modal(document.getElementById('procedureModal')).show();
    }
};
