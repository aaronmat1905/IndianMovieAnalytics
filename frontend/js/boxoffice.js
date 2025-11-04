// Box Office Module

const BoxOffice = {
    async init() {
        await this.render();
        await this.loadBoxOffice();
    },

    async render() {
        const content = `
            <div class="fade-in">
                <div class="section-header d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="bi bi-currency-dollar"></i> Box Office Management</h2>
                        <p class="text-muted">Track box office collections</p>
                    </div>
                    <button class="btn btn-primary" onclick="BoxOffice.showCreateModal()">
                        <i class="bi bi-plus-circle"></i> Add Box Office Record
                    </button>
                </div>

                <!-- Box Office Table -->
                <div class="table-container">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Movie ID</th>
                                    <th>Domestic Collection</th>
                                    <th>International Collection</th>
                                    <th>Total Collection</th>
                                    <th>Opening Weekend</th>
                                    <th>Profit Margin</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="boxoffice-tbody">
                                <tr><td colspan="8" class="text-center">
                                    <div class="spinner-border" role="status"></div>
                                    <p>Loading...</p>
                                </td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Box Office Modal -->
            <div class="modal fade" id="boxOfficeModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="boxOfficeModalTitle">Add Box Office Record</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <form id="boxOfficeForm">
                                <input type="hidden" id="box-id">
                                <div class="mb-3">
                                    <label for="box-movie-id" class="form-label">Movie ID *</label>
                                    <input type="number" class="form-control" id="box-movie-id" required>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="box-domestic" class="form-label">Domestic Collection (₹)</label>
                                        <input type="number" class="form-control" id="box-domestic" min="0" step="0.01">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="box-international" class="form-label">International Collection (₹)</label>
                                        <input type="number" class="form-control" id="box-international" min="0" step="0.01">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="box-opening-weekend" class="form-label">Opening Weekend (₹)</label>
                                        <input type="number" class="form-control" id="box-opening-weekend" min="0" step="0.01">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="box-profit-margin" class="form-label">Profit Margin (%)</label>
                                        <input type="number" class="form-control" id="box-profit-margin" min="0" max="100" step="0.01">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="box-screens" class="form-label">Release Screens</label>
                                        <input type="number" class="form-control" id="box-screens" min="1">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="box-status" class="form-label">Collection Status</label>
                                        <select class="form-select" id="box-status">
                                            <option value="pending">Pending</option>
                                            <option value="updated">Updated</option>
                                        </select>
                                    </div>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" class="btn btn-primary" onclick="BoxOffice.saveRecord()">
                                <i class="bi bi-save"></i> Save
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
        document.getElementById('content-area').innerHTML = content;
    },

    async loadBoxOffice() {
        showLoading();
        try {
            const records = await api.getBoxOfficeRecords();
            this.renderTable(records);
        } catch (error) {
            console.error('Error:', error);
            showToast('Failed to load box office records', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    renderTable(records) {
        const tbody = document.getElementById('boxoffice-tbody');
        if (!records || records.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state"><i class="bi bi-inbox"></i><h4>No records found</h4></div></td></tr>';
            return;
        }

        tbody.innerHTML = records.map(r => `
            <tr>
                <td>${r.movie_id}</td>
                <td>${formatCurrencyCrores(r.domestic_collection)}</td>
                <td>${formatCurrencyCrores(r.international_collection)}</td>
                <td><strong>${formatCurrencyCrores(r.total_collection)}</strong></td>
                <td>${formatCurrencyCrores(r.opening_weekend)}</td>
                <td>${r.profit_margin ? r.profit_margin + '%' : '-'}</td>
                <td>${getCollectionStatusBadge(r.collection_status)}</td>
                <td class="action-buttons">
                    <button class="btn btn-sm btn-warning" onclick="BoxOffice.showEditModal(${r.box_id})">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="BoxOffice.deleteRecord(${r.box_id})">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    },

    showCreateModal() {
        document.getElementById('boxOfficeModalTitle').textContent = 'Add Box Office Record';
        document.getElementById('boxOfficeForm').reset();
        document.getElementById('box-id').value = '';
        new bootstrap.Modal(document.getElementById('boxOfficeModal')).show();
    },

    async showEditModal(id) {
        try {
            showLoading();
            const record = await api.getBoxOfficeRecord(id);
            document.getElementById('boxOfficeModalTitle').textContent = 'Edit Box Office Record';
            document.getElementById('box-id').value = record.box_id;
            document.getElementById('box-movie-id').value = record.movie_id;
            document.getElementById('box-domestic').value = record.domestic_collection || '';
            document.getElementById('box-international').value = record.international_collection || '';
            document.getElementById('box-opening-weekend').value = record.opening_weekend || '';
            document.getElementById('box-profit-margin').value = record.profit_margin || '';
            document.getElementById('box-screens').value = record.release_screens || '';
            document.getElementById('box-status').value = record.collection_status || 'pending';
            new bootstrap.Modal(document.getElementById('boxOfficeModal')).show();
        } catch (error) {
            console.error('Error:', error);
            showToast('Failed to load record', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async saveRecord() {
        const form = document.getElementById('boxOfficeForm');
        if (!form.checkValidity()) {
            form.classList.add('was-validated');
            return;
        }

        const id = document.getElementById('box-id').value;
        const data = {
            movie_id: parseInt(document.getElementById('box-movie-id').value),
            domestic_collection: parseFloat(document.getElementById('box-domestic').value) || null,
            international_collection: parseFloat(document.getElementById('box-international').value) || null,
            opening_weekend: parseFloat(document.getElementById('box-opening-weekend').value) || null,
            profit_margin: parseFloat(document.getElementById('box-profit-margin').value) || null,
            release_screens: parseInt(document.getElementById('box-screens').value) || null,
            collection_status: document.getElementById('box-status').value,
            updated_by: 1
        };

        try {
            showLoading();
            if (id) {
                await api.updateBoxOfficeRecord(id, data);
                showToast('Record updated successfully', 'Success', 'success');
            } else {
                await api.createBoxOfficeRecord(data);
                showToast('Record created successfully', 'Success', 'success');
            }
            bootstrap.Modal.getInstance(document.getElementById('boxOfficeModal')).hide();
            await this.loadBoxOffice();
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message || 'Failed to save record', 'Error', 'error');
        } finally {
            hideLoading();
        }
    },

    async deleteRecord(id) {
        if (!confirmAction('Are you sure you want to delete this record?')) return;
        try {
            showLoading();
            await api.deleteBoxOfficeRecord(id);
            showToast('Record deleted successfully', 'Success', 'success');
            await this.loadBoxOffice();
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message || 'Failed to delete record', 'Error', 'error');
        } finally {
            hideLoading();
        }
    }
};
