{% extends "layouts/main.volt" %}

{% block content %}
<div class="page-header">
    <h1>Master Anomali</h1>
    <a href="{{ url('anomali/create') }}" class="btn btn-primary">+ Tambah Anomali</a>
</div>

{% if request.get('error') == 'used' %}
<div class="alert alert-danger">
    <i class="fas fa-exclamation-triangle"></i> Data anomali tidak dapat dihapus karena masih digunakan.
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
                <th style="width:80px;">Kode</th>
                <th>Nama</th>
                <th>Status</th>
                <th style="width:140px;">Aksi</th>
            </tr>
        </thead>
        <tbody>
            {% if anomaliList is defined and anomaliList|length > 0 %}
                {% for a in anomaliList %}
                <tr>
                    <td>{{ a['kode'] }}</td>
                    <td>{{ a['nama'] }}</td>
                    <td>
                        {% if a['status'] == 1 %}
                            <span class="badge badge-active">Aktif</span>
                        {% else %}
                            <span class="badge badge-inactive">Nonaktif</span>
                        {% endif %}
                    </td>
                    <td class="actions">
                        <a href="{{ url('anomali/edit/' ~ a['id']) }}" class="btn btn-edit btn-sm">Edit</a>
                        <a href="{{ url('anomali/delete/' ~ a['id']) }}" class="btn btn-delete btn-sm js-confirm-delete" data-confirm="Hapus anomali {{ a['nama'] }}?">Hapus</a>
                    </td>
                </tr>
                {% endfor %}
            {% else %}
                <tr class="empty-row"><td colspan="4">Belum ada data anomali.</td></tr>
            {% endif %}
        </tbody>
    </table>
    {% if anomaliList is defined and anomaliList|length > 0 %}
    <div class="master-pagination">
        <button type="button" class="master-page-prev">‹ Prev</button>
        <span class="master-page-info"></span>
        <button type="button" class="master-page-next">Next ›</button>
    </div>
    {% endif %}
</div>
{% endblock %}
