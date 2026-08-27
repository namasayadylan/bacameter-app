{% extends "layouts/main.volt" %}

{% block content %}
<div class="page-header">
    <h1>Master Petugas</h1>
    <a href="{{ url('petugas/create') }}" class="btn btn-primary">+ Tambah Petugas</a>
</div>

{% if request.get('error') == 'used' %}
<div class="alert alert-danger">
    <i class="fas fa-exclamation-triangle"></i> Data petugas tidak dapat dihapus karena masih digunakan.
</div>
{% endif %}

<div class="master-card" data-paginate>
    <div class="master-toolbar">
        Tampilkan
        <select class="master-pagesize">
            <option value="10" selected>10</option>
            <option value="25">25</option>
            <option value="50">50</option>
            <option value="100">100</option>
            <option value="all">Semua</option>
        </select>
        entri
    </div>
    <table class="master-table">
        <thead>
            <tr>
                <th>Nama</th>
                <th>Username</th>
                <th>No. Telp</th>
                <th>Tipe</th>
                <th>Zona</th>
                <th style="width:140px;">Aksi</th>
            </tr>
        </thead>
        <tbody>
            {% if petugasList is defined and petugasList|length > 0 %}
                {% for p in petugasList %}
                <tr>
                    <td>{{ p['nama'] }}</td>
                    <td>{{ p['username'] }}</td>
                    <td>{{ p['no_telp'] }}</td>
                    <td>
                        {% if p['petugas_os'] == 1 %}
                            <span class="badge badge-os">OS</span>
                        {% else %}
                            <span class="badge badge-pdam">PDAM</span>
                        {% endif %}
                    </td>
                    <td>{{ p['zona_id'] }}</td>
                    <td class="actions">
                        <a href="{{ url('petugas/edit/' ~ p['id']) }}" class="btn btn-edit btn-sm">Edit</a>
                        <a href="{{ url('petugas/delete/' ~ p['id']) }}" class="btn btn-delete btn-sm js-confirm-delete" data-confirm="Hapus petugas {{ p['nama'] }}?">Hapus</a>
                    </td>
                </tr>
                {% endfor %}
            {% else %}
                <tr class="empty-row"><td colspan="6">Belum ada data petugas.</td></tr>
            {% endif %}
        </tbody>
    </table>
    {% if petugasList is defined and petugasList|length > 0 %}
    <div class="master-pagination">
        <button type="button" class="master-page-prev">‹ Prev</button>
        <span class="master-page-info"></span>
        <button type="button" class="master-page-next">Next ›</button>
    </div>
    {% endif %}
</div>
{% endblock %}
