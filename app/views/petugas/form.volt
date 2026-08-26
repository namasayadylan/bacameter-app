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
            <label for="username">Username <span class="required">*</span></label>
            <input type="text" id="username" name="username" value="{{ petugas['username'] is defined ? petugas['username'] : '' }}" required>
        </div>

        <div class="form-group">
            <label for="nama">Nama <span class="required">*</span></label>
            <input type="text" id="nama" name="nama" value="{{ petugas['nama'] is defined ? petugas['nama'] : '' }}" required>
        </div>

        <div class="form-group">
            <label for="no_telp">No. Telp</label>
            <input type="text" id="no_telp" name="no_telp" value="{{ petugas['no_telp'] is defined ? petugas['no_telp'] : '' }}">
        </div>

        <div class="form-group">
            <label for="alamat">Alamat</label>
            <input type="text" id="alamat" name="alamat" value="{{ petugas['alamat'] is defined ? petugas['alamat'] : '' }}">
        </div>

        <div class="form-group">
            <label for="petugas_os">Tipe</label>
            <select id="petugas_os" name="petugas_os">
                <option value="0" {% if (petugas['petugas_os'] is defined ? petugas['petugas_os'] : 0) == 0 %}selected{% endif %}>PDAM</option>
                <option value="1" {% if (petugas['petugas_os'] is defined ? petugas['petugas_os'] : 0) == 1 %}selected{% endif %}>OS</option>
            </select>
        </div>

        <div class="form-group">
            <label for="zona_id">Zona</label>
            <input type="number" id="zona_id" name="zona_id" value="{{ petugas['zona_id'] is defined ? petugas['zona_id'] : '' }}">
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Simpan</button>
            <a href="{{ url('petugas') }}" class="btn btn-secondary">Batal</a>
        </div>
    </form>
</div>
{% endblock %}
