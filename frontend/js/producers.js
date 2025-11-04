// Producers Module

const Producers = {
    async init() {
        await this.render();
        await this.loadProducers();
    },

    async render() {
        const content = `
            <div class="fade-in">
                <div class="section-header d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="bi bi-briefcase"></i> Producers Management</h2>
                        <p class="text-muted">Manage producer records</p>
                    </div>
                    <button class="btn btn-primary" onclick="Producers.showCreateModal()">
                        <i class="bi bi-plus-circle"></i> Add New Producer
                    </button>
                </div>

                <!-- Search -->
                <div class="filter-section">
                    <div class="row">
                        <div class="col-md-6">
                            <input type="text" class="form-control" id="filter-producer-name"
                                   placeholder="Search by name or company..."
                                   onkeyup="Producers.applyFilters()">
                        </div>
                        <div class="col-md-4">
                            <input type="text" class="form-control" id="filter-region"
                                   placeholder="Filter by region..."
                                   onkeyup="Producers.applyFilters()">
                        </div>
                        <div class="col-md-2">
                            <button class="btn btn-secondary w-100" onclick="Producers.clearFilters()">
                                <i class="bi bi-x-circle"></i> Clear
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Producers Table -->
                <div class="table-container">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Company</th>
                                    <th>Contact</th>
                                    <th>Region</th>
                                    <th>Start Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="producers-tbody">
                                <tr><td colspan="7" class="text-center">
                                    <div class="spinner-border" role="status"></div>
                                    <p>Loading...</p>
                                </td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Producer Modal -->
            <div class="modal fade" id="producerModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="producerModalTitle">Add New Producer</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <form id="producerForm">
                                <input type="hidden" id="producer-id">
                                <div class="mb-3">
                                    <label for="producer-name" class="form-label">Name *</label>
                                    <input type="text" class="form-control" id="producer-name" required>
                                </div>
                                <div class="mb-3">
                                    <label for="producer-company" class="form-label">Company</label>
                                    <input type="text" class="form-control" id="producer-company">
                                </div>
                                <div class="mb-3">
                                    <label for="producer-phone" class="form-label">Phone</label>
                                    <input type="tel" class="form-control" id="producer-phone">
                                </div>
                                <div class="mb-3">
                                    <label for="producer-email" class="form-label">Email</label>
                                    <input type="email" class="form-control" id="producer-email">
                                </div>
                                <div class="mb-3">
                                    <label for="producer-start-date" class="form-label">Start Date</label>
                                    <input type="date" class="form-control" id="producer-start-date">
                                </div>
                                <div class="mb-3">
                                    <label for="producer-region" class="form-label">Region</label>
                                    <input type="text" class="form-control" id="producer-region">
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" class="btn btn-primary" onclick="Producers.saveProducer()">
                                <i class="bi bi-save"></i> Save
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
        document.getElementById('content-area').innerHTML = content;
    },

    async loadProducers() {
        showLoading();
        try {
            const producers = await api.getProducers(this.filters || {});
            this.renderTable(producers);
        } catch (error) {
            console.error('Error loading producers:', error);
            showToast('Failed to load producers', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    renderTable(producers) {
        const tbody = document.getElementById('producers-tbody');
        if (!producers || producers.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7"><div class="empty-state"><i class="bi bi-inbox"></i><h4>No producers found</h4></div></td></tr>';
            return;
        }

        tbody.innerHTML = producers.map(p => `
            <tr>
                <td>${p.producer_id}</td>
                <td><strong>${sanitizeHTML(p.name)}</strong></td>
                <td>${sanitizeHTML(p.company || '-')}</td>
                <td>${p.phone || '-'}<br><small class="text-muted">${p.email || ''}</small></td>
                <td>${p.region || '-'}</td>
                <td>${formatDate(p.start_date)}</td>
                <td class="action-buttons">
                    <button class="btn btn-sm btn-warning" onclick="Producers.showEditModal(${p.producer_id})">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="Producers.deleteProducer(${p.producer_id})">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    },

    showCreateModal() {
        document.getElementById('producerModalTitle').textContent = 'Add New Producer';
        document.getElementById('producerForm').reset();
        document.getElementById('producer-id').value = '';
        new bootstrap.Modal(document.getElementById('producerModal')).show();
    },

    async showEditModal(id) {
        try {
            showLoading();
            const producer = await api.getProducer(id);
            document.getElementById('producerModalTitle').textContent = 'Edit Producer';
            document.getElementById('producer-id').value = producer.producer_id;
            document.getElementById('producer-name').value = producer.name;
            document.getElementById('producer-company').value = producer.company || '';
            document.getElementById('producer-phone').value = producer.phone || '';
            document.getElementById('producer-email').value = producer.email || '';
            document.getElementById('producer-start-date').value = producer.start_date || '';
            document.getElementById('producer-region').value = producer.region || '';
            new bootstrap.Modal(document.getElementById('producerModal')).show();
        } catch (error) {
            console.error('Error:', error);
            showToast('Failed to load producer', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async saveProducer() {
        const form = document.getElementById('producerForm');
        if (!form.checkValidity()) {
            form.classList.add('was-validated');
            return;
        }

        const id = document.getElementById('producer-id').value;
        const data = {
            name: document.getElementById('producer-name').value,
            company: document.getElementById('producer-company').value || null,
            phone: document.getElementById('producer-phone').value || null,
            email: document.getElementById('producer-email').value || null,
            start_date: document.getElementById('producer-start-date').value || null,
            region: document.getElementById('producer-region').value || null,
            created_by: 1
        };

        try {
            showLoading();
            if (id) {
                await api.updateProducer(id, data);
                showToast('Producer updated successfully', 'Success', 'success');
            } else {
                await api.createProducer(data);
                showToast('Producer created successfully', 'Success', 'success');
            }
            bootstrap.Modal.getInstance(document.getElementById('producerModal')).hide();
            await this.loadProducers();
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message || 'Failed to save producer', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async deleteProducer(id) {
        if (!confirmAction('Are you sure you want to delete this producer?')) return;
        try {
            showLoading();
            await api.deleteProducer(id);
            showToast('Producer deleted successfully', 'Success', 'success');
            await this.loadProducers();
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message || 'Failed to delete producer', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    applyFilters: debounce(function() {
        this.filters = {};
        const name = document.getElementById('filter-producer-name').value;
        if (name) this.filters.name = name;
        const region = document.getElementById('filter-region').value;
        if (region) this.filters.region = region;
        this.loadProducers();
    }, APP_CONFIG.DEBOUNCE_DELAY),

    clearFilters() {
        document.getElementById('filter-producer-name').value = '';
        document.getElementById('filter-region').value = '';
        this.filters = {};
        this.loadProducers();
    }
};
