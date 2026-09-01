{% extends "layouts/main.volt" %}

{% block content %}
<div class="page-header">
    <h1>Laporan</h1>
</div>

<div class="master-card rpt-card" style="margin-bottom: 20px;">
    <div class="rpt-card-head">Laporan Bacameter</div>

    <form method="get" action="{{ url('laporan') }}" id="rptForm" class="rpt-form">
        <div class="form-group">
            <label for="rptJenis">Jenis <span class="required">*</span></label>
            <select name="jenis" id="rptJenis" required>
                <option value="">- Jenis Laporan -</option>
                {% for id, label in jenisList %}
                    <option value="{{ id }}" {% if jenisSelected is defined and jenisSelected == id %}selected{% endif %}>
                     {{ label }}
                    </option>
                {% endfor %}
            </select>
        </div>
        <div class="form-group" id="rptPeriodeGroup">
            <label for="rptPeriode">Periode</label>
            <input type="month" name="periode" id="rptPeriode" value="{{ periodeInputValue }}">
        </div>
    </form>

    <div class="rpt-form-footer">
        <button type="submit" form="rptForm" class="btn btn-primary">&#128065; Preview</button>
    </div>
</div>

{% if report is defined %}
<div class="master-card rpt-card"{% if jenis != 1 %} data-paginate{% endif %}>
    <div class="rpt-card-head rpt-preview-head">
        <div class="rpt-preview-title">
            Preview &mdash; {{ report['judul'] }}
            <span class="rpt-preview-count">&#9776; {{ report['jumlah_baris'] }} baris</span>
        </div>
        <div class="rpt-preview-actions">
            <a href="{{ url('laporan/export-excel') }}?jenis={{ jenis }}&periode={{ periode }}" class="btn-rpt-excel"> Excel</a>
            <a href="{{ url('laporan/export-pdf') }}?jenis={{ jenis }}&periode={{ periode }}" class="btn-rpt-pdf" target="_blank"> PDF</a>
        </div>
    </div>

    {% if report['jumlah_baris'] > 0 and jenis != 1 %}
    <div class="master-toolbar">
        Tampilkan
        <select class="master-pagesize">
            <option value="10">10</option>
            <option value="25">25</option>
            <option value="50">50</option>
            <option value="100" selected>100</option>
            <option value="all">Semua</option>
        </select>
        data per halaman
    </div>
    {% endif %}

    {% if jenis == 1 and report['total_keseluruhan'] is defined %}
    <div class="master-toolbar">
        Menampilkan {{ report['jumlah_baris'] }} dari total
        <strong>{{ report['total_keseluruhan'] }}</strong> pelanggan periode ini
        (halaman {{ page }} / {{ totalPages }})
    </div>
    {% endif %}

    <div class="rpt-table-wrap">
        {% if jenis == 1 %}
        <table class="rpt-table">
            <thead>
                <tr>
                    <th>No</th><th>No Pelanggan</th><th>Nama</th><th>Alamat</th>
                    <th class="num">St. Awal</th><th class="num">St. Akhir</th><th class="num">Pakai (M&sup3;)</th>
                    <th>Kendala</th><th class="num">Harga Air</th><th class="num">Admin</th><th class="num">Total Rekening</th>
                </tr>
            </thead>
            <tbody>
                {% for r in report['rows'] %}
                <tr>
                    <td>{{ r['no'] }}</td>
                    <td>{{ r['nomor_pelanggan'] }}</td>
                    <td>{{ r['nama'] }}</td>
                    <td>{{ r['alamat'] }}</td>
                    <td class="num">{{ r['stand_awal'] }}</td>
                    <td class="num">{{ r['stand_akhir'] }}</td>
                    <td class="num">{{ r['pakai'] }}</td>
                    <td>{{ r['kendala'] }}</td>
                    <td class="num">Rp {{ number_format(r['harga_air'], 0, ',', '.') }}</td>
                    <td class="num">Rp {{ number_format(r['biaya_admin'], 0, ',', '.') }}</td>
                    <td class="num">Rp {{ number_format(r['total_rekening'], 0, ',', '.') }}</td>
                </tr>
                {% endfor %}
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="6">TOTAL</td>
                    <td class="num">{{ report['totals']['pakai'] }}</td>
                    <td></td>
                    <td class="num">Rp {{ number_format(report['totals']['harga_air'], 0, ',', '.') }}</td>
                    <td class="num">Rp {{ number_format(report['totals']['biaya_admin'], 0, ',', '.') }}</td>
                    <td class="num">Rp {{ number_format(report['totals']['total_rekening'], 0, ',', '.') }}</td>
                </tr>
            </tfoot>
        </table>

        {% if totalPages is defined and totalPages > 1 %}
        <div class="master-pagination">
            {% if page > 1 %}
            <a href="{{ url('laporan') }}?jenis=1&periode={{ periodeInputValue }}&page={{ page - 1 }}" class="btn btn-secondary">&larr; Sebelumnya</a>
            {% else %}
            <button type="button" disabled>&larr; Sebelumnya</button>
            {% endif %}

            <span class="master-page-info">Halaman {{ page }} dari {{ totalPages }}</span>

            {% if page < totalPages %}
            <a href="{{ url('laporan') }}?jenis=1&periode={{ periodeInputValue }}&page={{ page + 1 }}" class="btn btn-secondary">Berikutnya &rarr;</a>
            {% else %}
            <button type="button" disabled>Berikutnya &rarr;</button>
            {% endif %}
        </div>
        {% endif %}
        {% endif %}
        {% if jenis == 2 %}
        <table class="rpt-table">
            <thead>
                <tr>
                    <th>Petugas</th><th class="num">Jumlah Pelanggan</th><th class="num">Total Pakai (M&sup3;)</th>
                    <th class="num">Rata&ndash;rata Pakai (M&sup3;)</th><th class="num">Total Rekening</th>
                </tr>
            </thead>
            <tbody>
                {% for r in report['rows'] %}
                <tr>
                    <td>{{ r['nama_petugas'] }}</td>
                    <td class="num">{{ r['jml_pelanggan'] }}</td>
                    <td class="num">{{ r['total_m3'] }}</td>
                    <td class="num">{{ number_format(r['rata_m3'], 1, ',', '.') }}</td>
                    <td class="num">Rp {{ number_format(r['total_rekening'], 0, ',', '.') }}</td>
                </tr>
                {% endfor %}
            </tbody>
            <tfoot>
                <tr>
                    <td>TOTAL</td>
                    <td class="num">{{ report['totals']['jml_pelanggan'] }}</td>
                    <td class="num">{{ report['totals']['total_m3'] }}</td>
                    <td></td>
                    <td class="num">Rp {{ number_format(report['totals']['total_rekening'], 0, ',', '.') }}</td>
                </tr>
            </tfoot>
        </table>
        {% endif %}

        {# ============== SOAL 3: Rekap per anomali/kendala ============== #}
        {% if jenis == 3 %}
        <table class="rpt-table">
            <thead>
                <tr>
                    <th>Kode</th><th>Nama Kendala</th><th class="num">Jumlah Pelanggan</th>
                    <th class="num">Total Pakai (M&sup3;)</th><th class="num">Total Rekening</th>
                </tr>
            </thead>
            <tbody>
                {% for r in report['rows'] %}
                <tr>
                    <td>{{ r['kode'] }}</td>
                    <td>{{ r['nama_kendala'] }}</td>
                    <td class="num">{{ r['jml_pelanggan'] }}</td>
                    <td class="num">{{ r['total_m3'] }}</td>
                    <td class="num">Rp {{ number_format(r['total_rekening'], 0, ',', '.') }}</td>
                </tr>
                {% endfor %}
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="2">TOTAL</td>
                    <td class="num">{{ report['totals']['jml_pelanggan'] }}</td>
                    <td class="num">{{ report['totals']['total_m3'] }}</td>
                    <td class="num">Rp {{ number_format(report['totals']['total_rekening'], 0, ',', '.') }}</td>
                </tr>
            </tfoot>
        </table>
        {% endif %}
    </div>

    {% if report['jumlah_baris'] > 0 %}
    <div class="master-pagination">
        <button type="button" class="master-page-prev">&larr; Sebelumnya</button>
        <span class="master-page-info"></span>
        <button type="button" class="master-page-next">Berikutnya &rarr;</button>
    </div>
    {% endif %}
</div>
{% endif %}
{% endblock %}
