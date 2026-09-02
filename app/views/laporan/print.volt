<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>{{ report['judul'] }} - Bacameter</title>
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'DejaVu Sans', Arial, sans-serif;
            color: #1f2937;
            margin: 0;
            font-size: 12px;
        }
        body.mode-web { padding: 24px; background: #f4f6f8; }
        body.mode-pdf { padding: 0; background: #fff; }

        .sheet {
            max-width: 1000px;
            margin: 0 auto;
            background: #fff;
            padding: 28px 32px;
        }
        .mode-web .sheet {
            border: 1px solid #e3e8ef;
            border-radius: 10px;
            box-shadow: 0 4px 16px -4px rgba(15,38,67,.10);
        }

        .kop { border-bottom: 2px solid #1a3d6d; padding-bottom: 10px; margin-bottom: 14px; }
        .kop-table { width: 100%; border-collapse: collapse; }
        .kop-logo-cell { width: 54px; vertical-align: middle; padding: 0 12px 0 0; }
        .kop-logo { width: 42px; height: auto; display: block; }
        .kop-text-cell { vertical-align: middle; }
        .kop-nama { font-size: 16px; font-weight: 700; color: #1a3d6d; margin: 0; }
        .kop-kontak { font-size: 10.5px; color: #6b7280; margin: 2px 0 0; }

        .judul { font-size: 14px; font-weight: 700; text-align: center; margin: 14px 0 2px; text-transform: uppercase; }
        .sub { font-size: 11.5px; text-align: center; color: #4b5563; margin: 0 0 16px; }

        table.rpt { width: 100%; border-collapse: collapse; font-size: 11px; }
        table.rpt th, table.rpt td { border: 1px solid #cfd6e0; padding: 5px 7px; }
        table.rpt th { background: #eef1f5; color: #1a3d6d; font-weight: 700; text-align: center; }
        table.rpt td.num { text-align: right; }
        table.rpt td.center { text-align: center; }
        table.rpt tfoot td { font-weight: 700; background: #f7f9fc; }

        .catatan { font-size: 9.5px; color: #6b7280; font-style: italic; margin-top: 10px; }

        .toolbar { display: flex; justify-content: flex-end; gap: 10px; margin-bottom: 16px; }
        .toolbar a {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 600;
            text-decoration: none; color: #fff;
        }
        .btn-pdf   { background: #dc2626; }
        .btn-excel { background: #2f8a52; }
        .btn-back  { background: #6b7280; }
    </style>
</head>
<body class="{% if forPdf %}mode-pdf{% else %}mode-web{% endif %}">

    {% if not forPdf %}
    <div class="toolbar">
        <a href="{{ url('laporan') }}" class="btn-back">&larr; Kembali</a>
        <a href="{{ url('laporan/export-pdf') }}?jenis={{ jenis }}&periode={{ periode }}" class="btn-pdf" target="_blank">&#128196; Export PDF</a>
        <a href="{{ url('laporan/export-excel') }}?jenis={{ jenis }}&periode={{ periode }}" class="btn-excel">&#128202; Export Excel</a>
    </div>
    {% endif %}

    <div class="sheet">
        <div class="kop">
            <table class="kop-table" cellpadding="0" cellspacing="0">
                <tr>
                    {% if logoSrc is defined and logoSrc %}
                    <td class="kop-logo-cell"><img src="{{ logoSrc }}" class="kop-logo" alt="Logo"></td>
                    {% endif %}
                    <td class="kop-text-cell">
                        <p class="kop-nama">{{ kopNama }}</p>
                        <p class="kop-kontak">{{ kopKontak }}</p>
                    </td>
                </tr>
            </table>
        </div>

        {% if (logoSrc is not defined or not logoSrc) and logoDebugPaths is defined and logoDebugPaths %}
        <div style="background:#fef3c7; border:1px solid #f2c94c; color:#92400e; font-size:9.5px; padding:6px 10px; margin-bottom:12px; border-radius:4px;">
            &#9888; Logo tidak ditemukan. Path yang sudah dicoba:
            {% for p in logoDebugPaths %}<br>&middot; {{ p }}{% endfor %}
        </div>
        {% endif %}

        <div class="judul">LAPORAN {{ report['judul'] }}</div>
        <div class="sub">Periode {{ periodeLabel }}{% if report['sub'] is defined and report['sub'] %} &middot; {{ report['sub'] }}{% endif %}</div>

        {% if jenis == 1 %}
        <table class="rpt">
            <thead>
                <tr>
                    <th>No</th><th>No Pelanggan</th><th>Nama</th><th>Alamat</th>
                    <th>St. Awal</th><th>St. Akhir</th><th>Pakai (M&sup3;)</th>
                    <th>Kendala</th><th>Harga Air</th><th>Admin</th><th>Total Rekening</th>
                </tr>
            </thead>
            <tbody>
                {% for r in report['rows'] %}
                <tr>
                    <td class="center">{{ r['no'] }}</td>
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
                    <td colspan="6" class="center">TOTAL</td>
                    <td class="num">{{ report['totals']['pakai'] }}</td>
                    <td></td>
                    <td class="num">Rp {{ number_format(report['totals']['harga_air'], 0, ',', '.') }}</td>
                    <td class="num">Rp {{ number_format(report['totals']['biaya_admin'], 0, ',', '.') }}</td>
                    <td class="num">Rp {{ number_format(report['totals']['total_rekening'], 0, ',', '.') }}</td>
                </tr>
            </tfoot>
        </table>
        <p class="catatan">Catatan: Pakai (M&sup3;) = St. Akhir &minus; St. Awal; Total Rekening = Harga Air + Admin.</p>
        {% endif %}

        {% if jenis == 2 %}
        <table class="rpt">
            <thead>
                <tr>
                    <th>Petugas</th><th>Jumlah Pelanggan</th><th>Total Pakai (M&sup3;)</th>
                    <th>Rata&ndash;rata Pakai (M&sup3;)</th><th>Total Rekening</th>
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
                    <td class="center">TOTAL</td>
                    <td class="num">{{ report['totals']['jml_pelanggan'] }}</td>
                    <td class="num">{{ report['totals']['total_m3'] }}</td>
                    <td></td>
                    <td class="num">Rp {{ number_format(report['totals']['total_rekening'], 0, ',', '.') }}</td>
                </tr>
            </tfoot>
        </table>
        <p class="catatan">Catatan: Rata&ndash;rata Pakai = Total Pakai &divide; Jumlah Pelanggan (per petugas).</p>
        {% endif %}

        {% if jenis == 3 %}
        <table class="rpt">
            <thead>
                <tr>
                    <th>Kode</th><th>Nama Kendala</th><th>Jumlah Pelanggan</th>
                    <th>Total Pakai (M&sup3;)</th><th>Total Rekening</th>
                </tr>
            </thead>
            <tbody>
                {% for r in report['rows'] %}
                <tr>
                    <td class="center">{{ r['kode'] }}</td>
                    <td>{{ r['nama_kendala'] }}</td>
                    <td class="num">{{ r['jml_pelanggan'] }}</td>
                    <td class="num">{{ r['total_m3'] }}</td>
                    <td class="num">Rp {{ number_format(r['total_rekening'], 0, ',', '.') }}</td>
                </tr>
                {% endfor %}
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="2" class="center">TOTAL</td>
                    <td class="num">{{ report['totals']['jml_pelanggan'] }}</td>
                    <td class="num">{{ report['totals']['total_m3'] }}</td>
                    <td class="num">Rp {{ number_format(report['totals']['total_rekening'], 0, ',', '.') }}</td>
                </tr>
            </tfoot>
        </table>
        {% endif %}
    </div>
</body>
</html>
