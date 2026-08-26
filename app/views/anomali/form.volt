{% extends "layouts/main.volt" %}

{% block content %}
<div class="page-header">
    <h1>{{ pageTitle }}</h1>
</div>

<div class="master-card form-card">
    {% if errors is defined and errors|length > 0 %}
        <div class="alert alert-error">
            <ul>
                {% for e in errors %}
                    <li>{{ e }}</li>
                {% endfor %}
            </ul>
        </div>
    {% endif %}

    <form method="post" action="{{ formAction }}" class="form-grid">
        <div class="form-group">
            <label for="kode">Kode <span class="required">*</span></label>
            <input type="text" id="kode" name="kode" value="{{ anomali['kode'] is defined ? anomali['kode'] : '' }}" maxlength="3" required>
        </div>

        <div class="form-group">
            <label for="nama">Nama <span class="required">*</span></label>
            <input type="text" id="nama" name="nama" value="{{ anomali['nama'] is defined ? anomali['nama'] : '' }}" required>
        </div>

        <div class="form-group">
            <label for="status">Status</label>
            <select id="status" name="status">
                <option value="1" {% if (anomali['status'] is defined ? anomali['status'] : 1) == 1 %}selected{% endif %}>Aktif</option>
                <option value="0" {% if (anomali['status'] is defined ? anomali['status'] : 1) == 0 %}selected{% endif %}>Nonaktif</option>
            </select>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Simpan</button>
            <a href="{{ url('anomali') }}" class="btn btn-secondary">Batal</a>
        </div>
    </form>
</div>
{% endblock %}
