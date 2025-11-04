// Production Crew Module

const Crew = {
    currentCrew: [],

    async init() {
        await this.render();
        await this.loadCrew();
    },

    async render() {
        const content = `
            <div class="fade-in">
                <div class="section-header d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="bi bi-people"></i> Production Crew Management</h2>
                        <p class="text-muted">Manage production crew members and technical staff</p>
                    </div>
                    <button class="btn btn-primary" onclick="Crew.showCreateModal()">
                        <i class="bi bi-plus-circle"></i> Add Crew Member
                    </button>
                </div>

                <!-- Search and Filter -->
                <div class="filter-section">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-search"></i></span>
                                <input type="text" class="form-control" id="crew-search" placeholder="Search by name or specialty...">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <select class="form-select" id="crew-role-filter">
                                <option value="">All Roles</option>
                                <option value="Director">Director</option>
                                <option value="Cinematographer">Cinematographer</option>
                                <option value="Music Director">Music Director</option>
                                <option value="Editor">Editor</option>
                                <option value="Producer">Producer</option>
                                <option value="Writer">Writer</option>
                                <option value="Choreographer">Choreographer</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button class="btn btn-secondary w-100" onclick="Crew.resetFilters()">
                                <i class="bi bi-arrow-clockwise"></i> Reset Filters
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Crew Table -->
                <div class="table-container">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Role</th>
                                    <th>Specialty</th>
                                    <th>Experience</th>
                                    <th>Email</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="crew-tbody">
                                <tr><td colspan="7" class="text-center">
                                    <div class="spinner-border" role="status"></div>
                                    <p>Loading crew members...</p>
                                </td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Crew Modal -->
            <div class="modal fade" id="crewModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="crewModalTitle">Add Crew Member</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <form id="crewForm">
                                <input type="hidden" id="crew-id">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="crew-name" class="form-label">Name *</label>
                                        <input type="text" class="form-control" id="crew-name" required maxlength="100">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="crew-role" class="form-label">Role *</label>
                                        <select class="form-select" id="crew-role" required>
                                            <option value="">Select Role</option>
                                            <option value="Director">Director</option>
                                            <option value="Cinematographer">Cinematographer</option>
                                            <option value="Music Director">Music Director</option>
                                            <option value="Editor">Editor</option>
                                            <option value="Producer">Producer</option>
                                            <option value="Writer">Writer</option>
                                            <option value="Choreographer">Choreographer</option>
                                            <option value="Other">Other</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="crew-specialty" class="form-label">Specialty</label>
                                        <input type="text" class="form-control" id="crew-specialty" maxlength="150" placeholder="e.g., Action Films, Background Score">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="crew-experience" class="form-label">Experience (Years)</label>
                                        <input type="number" class="form-control" id="crew-experience" min="0" max="70">
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label for="crew-email" class="form-label">Email</label>
                                    <input type="email" class="form-control" id="crew-email">
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" class="btn btn-primary" onclick="Crew.saveCrew()">
                                <i class="bi bi-save"></i> Save
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
        document.getElementById('content-area').innerHTML = content;

        // Add event listeners for search and filter
        document.getElementById('crew-search').addEventListener('input', () => this.filterCrew());
        document.getElementById('crew-role-filter').addEventListener('change', () => this.filterCrew());
    },

    async loadCrew() {
        showLoading();
        try {
            const crew = await api.getCrew();
            this.currentCrew = crew;
            this.renderTable(crew);
        } catch (error) {
            console.error('Error loading crew:', error);
            showToast('Failed to load crew members', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    renderTable(crew) {
        const tbody = document.getElementById('crew-tbody');
        if (!crew || crew.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7"><div class="empty-state"><i class="bi bi-people"></i><h4>No crew members found</h4><p>Add crew members to get started</p></div></td></tr>';
            return;
        }

        tbody.innerHTML = crew.map(member => `
            <tr>
                <td><strong>${member.crew_id}</strong></td>
                <td><i class="bi bi-person-badge"></i> ${member.name}</td>
                <td>${this.getRoleBadge(member.role)}</td>
                <td>${member.specialty || '-'}</td>
                <td>${member.experience_years ? `<span class="badge bg-secondary">${member.experience_years} years</span>` : '-'}</td>
                <td>${member.email ? `<a href="mailto:${member.email}">${member.email}</a>` : '-'}</td>
                <td class="action-buttons">
                    <button class="btn btn-sm btn-warning" onclick="Crew.showEditModal(${member.crew_id})" title="Edit">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="Crew.deleteCrew(${member.crew_id})" title="Delete">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    },

    getRoleBadge(role) {
        const colorMap = {
            'Director': 'bg-primary',
            'Cinematographer': 'bg-info',
            'Music Director': 'bg-success',
            'Editor': 'bg-warning',
            'Producer': 'bg-danger',
            'Writer': 'bg-secondary',
            'Choreographer': 'bg-dark',
            'Other': 'bg-light text-dark'
        };
        return `<span class="badge ${colorMap[role] || 'bg-secondary'}">${role}</span>`;
    },

    filterCrew() {
        const searchTerm = document.getElementById('crew-search').value.toLowerCase();
        const roleFilter = document.getElementById('crew-role-filter').value;

        const filtered = this.currentCrew.filter(member => {
            const matchesSearch = member.name.toLowerCase().includes(searchTerm) ||
                                (member.specialty && member.specialty.toLowerCase().includes(searchTerm));
            const matchesRole = !roleFilter || member.role === roleFilter;
            return matchesSearch && matchesRole;
        });

        this.renderTable(filtered);
    },

    resetFilters() {
        document.getElementById('crew-search').value = '';
        document.getElementById('crew-role-filter').value = '';
        this.renderTable(this.currentCrew);
    },

    showCreateModal() {
        document.getElementById('crewModalTitle').textContent = 'Add Crew Member';
        document.getElementById('crewForm').reset();
        document.getElementById('crew-id').value = '';
        new bootstrap.Modal(document.getElementById('crewModal')).show();
    },

    async showEditModal(id) {
        try {
            showLoading();
            const member = await api.getCrewMember(id);
            document.getElementById('crewModalTitle').textContent = 'Edit Crew Member';
            document.getElementById('crew-id').value = member.crew_id;
            document.getElementById('crew-name').value = member.name;
            document.getElementById('crew-role').value = member.role;
            document.getElementById('crew-specialty').value = member.specialty || '';
            document.getElementById('crew-experience').value = member.experience_years || '';
            document.getElementById('crew-email').value = member.email || '';
            new bootstrap.Modal(document.getElementById('crewModal')).show();
        } catch (error) {
            console.error('Error loading crew member:', error);
            showToast('Failed to load crew member details', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async saveCrew() {
        const form = document.getElementById('crewForm');
        if (!form.checkValidity()) {
            form.classList.add('was-validated');
            return;
        }

        const id = document.getElementById('crew-id').value;
        const data = {
            name: document.getElementById('crew-name').value,
            role: document.getElementById('crew-role').value,
            specialty: document.getElementById('crew-specialty').value || null,
            experience_years: parseInt(document.getElementById('crew-experience').value) || null,
            email: document.getElementById('crew-email').value || null
        };

        try {
            showLoading();
            if (id) {
                await api.updateCrewMember(id, data);
                showToast('Crew member updated successfully', 'Success', 'success');
            } else {
                await api.createCrewMember(data);
                showToast('Crew member created successfully', 'Success', 'success');
            }
            bootstrap.Modal.getInstance(document.getElementById('crewModal')).hide();
            await this.loadCrew();
        } catch (error) {
            console.error('Error saving crew member:', error);
            showToast(error.message || 'Failed to save crew member', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async deleteCrew(id) {
        if (!confirmAction('Are you sure you want to delete this crew member?')) return;
        try {
            showLoading();
            await api.deleteCrewMember(id);
            showToast('Crew member deleted successfully', 'Success', 'success');
            await this.loadCrew();
        } catch (error) {
            console.error('Error deleting crew member:', error);
            showToast(error.message || 'Failed to delete crew member', 'Error', 'error');
        } finally {
            hideLoading();
        }
    }
};
