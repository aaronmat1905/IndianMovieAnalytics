// Actors Module

const Actors = {
    currentActors: [],

    async init() {
        await this.render();
        await this.loadActors();
    },

    async render() {
        const content = `
            <div class="fade-in">
                <div class="section-header d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="bi bi-person-circle"></i> Actors Management</h2>
                        <p class="text-muted">Manage actor records and profiles</p>
                    </div>
                    <button class="btn btn-primary" onclick="Actors.showCreateModal()">
                        <i class="bi bi-plus-circle"></i> Add New Actor
                    </button>
                </div>

                <!-- Search and Filter -->
                <div class="filter-section">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-search"></i></span>
                                <input type="text" class="form-control" id="actor-search" placeholder="Search by name...">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" id="actor-gender-filter">
                                <option value="">All Genders</option>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button class="btn btn-secondary w-100" onclick="Actors.resetFilters()">
                                <i class="bi bi-arrow-clockwise"></i> Reset Filters
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Actors Table -->
                <div class="table-container">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Gender</th>
                                    <th>Date of Birth</th>
                                    <th>Nationality</th>
                                    <th>Popularity Score</th>
                                    <th>Email</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="actors-tbody">
                                <tr><td colspan="8" class="text-center">
                                    <div class="spinner-border" role="status"></div>
                                    <p>Loading actors...</p>
                                </td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Actor Modal -->
            <div class="modal fade" id="actorModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="actorModalTitle">Add New Actor</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <form id="actorForm">
                                <input type="hidden" id="actor-id">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="actor-name" class="form-label">Name *</label>
                                        <input type="text" class="form-control" id="actor-name" required maxlength="100">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="actor-gender" class="form-label">Gender</label>
                                        <select class="form-select" id="actor-gender">
                                            <option value="">Select Gender</option>
                                            <option value="Male">Male</option>
                                            <option value="Female">Female</option>
                                            <option value="Other">Other</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="actor-dob" class="form-label">Date of Birth</label>
                                        <input type="date" class="form-control" id="actor-dob">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="actor-nationality" class="form-label">Nationality</label>
                                        <input type="text" class="form-control" id="actor-nationality" maxlength="50">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="actor-popularity" class="form-label">Popularity Score (0-10)</label>
                                        <input type="number" class="form-control" id="actor-popularity" min="0" max="10" step="0.1">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="actor-email" class="form-label">Email</label>
                                        <input type="email" class="form-control" id="actor-email">
                                    </div>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" class="btn btn-primary" onclick="Actors.saveActor()">
                                <i class="bi bi-save"></i> Save
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
        document.getElementById('content-area').innerHTML = content;

        // Add event listeners for search and filter
        document.getElementById('actor-search').addEventListener('input', () => this.filterActors());
        document.getElementById('actor-gender-filter').addEventListener('change', () => this.filterActors());
    },

    async loadActors() {
        showLoading();
        try {
            const actors = await api.getActors();
            this.currentActors = actors;
            this.renderTable(actors);
        } catch (error) {
            console.error('Error loading actors:', error);
            showToast('Failed to load actors', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    renderTable(actors) {
        const tbody = document.getElementById('actors-tbody');
        if (!actors || actors.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state"><i class="bi bi-person-x"></i><h4>No actors found</h4><p>Add some actors to get started</p></div></td></tr>';
            return;
        }

        tbody.innerHTML = actors.map(actor => `
            <tr>
                <td><strong>${actor.actor_id}</strong></td>
                <td><i class="bi bi-person-fill"></i> ${actor.name}</td>
                <td>${actor.gender || '-'}</td>
                <td>${actor.date_of_birth ? formatDate(actor.date_of_birth) : '-'}</td>
                <td>${actor.nationality || '-'}</td>
                <td>${actor.popularity_score ? `<span class="badge bg-info">${actor.popularity_score}/10</span>` : '-'}</td>
                <td>${actor.email ? `<a href="mailto:${actor.email}">${actor.email}</a>` : '-'}</td>
                <td class="action-buttons">
                    <button class="btn btn-sm btn-warning" onclick="Actors.showEditModal(${actor.actor_id})" title="Edit">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="Actors.deleteActor(${actor.actor_id})" title="Delete">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    },

    filterActors() {
        const searchTerm = document.getElementById('actor-search').value.toLowerCase();
        const genderFilter = document.getElementById('actor-gender-filter').value;

        const filtered = this.currentActors.filter(actor => {
            const matchesSearch = actor.name.toLowerCase().includes(searchTerm);
            const matchesGender = !genderFilter || actor.gender === genderFilter;
            return matchesSearch && matchesGender;
        });

        this.renderTable(filtered);
    },

    resetFilters() {
        document.getElementById('actor-search').value = '';
        document.getElementById('actor-gender-filter').value = '';
        this.renderTable(this.currentActors);
    },

    showCreateModal() {
        document.getElementById('actorModalTitle').textContent = 'Add New Actor';
        document.getElementById('actorForm').reset();
        document.getElementById('actor-id').value = '';
        new bootstrap.Modal(document.getElementById('actorModal')).show();
    },

    async showEditModal(id) {
        try {
            showLoading();
            const actor = await api.getActor(id);
            document.getElementById('actorModalTitle').textContent = 'Edit Actor';
            document.getElementById('actor-id').value = actor.actor_id;
            document.getElementById('actor-name').value = actor.name;
            document.getElementById('actor-gender').value = actor.gender || '';
            document.getElementById('actor-dob').value = actor.date_of_birth || '';
            document.getElementById('actor-nationality').value = actor.nationality || '';
            document.getElementById('actor-popularity').value = actor.popularity_score || '';
            document.getElementById('actor-email').value = actor.email || '';
            new bootstrap.Modal(document.getElementById('actorModal')).show();
        } catch (error) {
            console.error('Error loading actor:', error);
            showToast('Failed to load actor details', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async saveActor() {
        const form = document.getElementById('actorForm');
        if (!form.checkValidity()) {
            form.classList.add('was-validated');
            return;
        }

        const id = document.getElementById('actor-id').value;
        const data = {
            name: document.getElementById('actor-name').value,
            gender: document.getElementById('actor-gender').value || null,
            date_of_birth: document.getElementById('actor-dob').value || null,
            nationality: document.getElementById('actor-nationality').value || null,
            popularity_score: parseFloat(document.getElementById('actor-popularity').value) || null,
            email: document.getElementById('actor-email').value || null
        };

        try {
            showLoading();
            if (id) {
                await api.updateActor(id, data);
                showToast('Actor updated successfully', 'Success', 'success');
            } else {
                await api.createActor(data);
                showToast('Actor created successfully', 'Success', 'success');
            }
            bootstrap.Modal.getInstance(document.getElementById('actorModal')).hide();
            await this.loadActors();
        } catch (error) {
            console.error('Error saving actor:', error);
            showToast(error.message || 'Failed to save actor', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async deleteActor(id) {
        if (!confirmAction('Are you sure you want to delete this actor?')) return;
        try {
            showLoading();
            await api.deleteActor(id);
            showToast('Actor deleted successfully', 'Success', 'success');
            await this.loadActors();
        } catch (error) {
            console.error('Error deleting actor:', error);
            showToast(error.message || 'Failed to delete actor', 'Error', 'error');
        } finally {
            hideLoading();
        }
    }
};
