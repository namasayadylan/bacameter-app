{% extends "layouts/main.volt" %}

{% block content %}
<div class="page-header">
    <h1>Dashboard</h1>
    <form method="get" action="{{ url('dashboard') }}" class="db-filter-periode">
        <input type="month" name="periode" value="{{ filterPeriode['value'] }}" onchange="this.form.submit()" title="Periode: {{ filterPeriode['label'] }} · bulan lalu: {{ filterPeriode['label_lalu'] }}">
        <noscript><button type="submit" class="btn btn-primary btn-sm">Tampilkan</button></noscript>
    </form>
</div>

<div class="dashboard-boxes">
    <div class="dashboard-box dashboard-box-tall db-card db-pos-1">
        <div class="db-card-top">
            <div>
                <div class="db-title">Total Kubikasi <span>Bulan ini</span></div>
                <div class="db-value">{{ number_format(kubikasi['bulan_ini'], 0, ',', '.') }} m³</div>
            </div>
            {% if kubikasi['pct'] is not null %}
                <span class="db-badge {{ kubikasi['pct'] < 0 ? 'db-badge-red' : 'db-badge-green' }}">{{ number_format(kubikasi['pct'], 2, '.', '') }}%</span>
            {% endif %}
        </div>
        <div class="db-sub">
            <span>Kubikasi bulan lalu</span>
            <strong>{{ number_format(kubikasi['bulan_lalu'], 0, ',', '.') }} m³</strong>
        </div>

        <div class="db-verif">
            <div>
                <div class="db-title">Kubikasi Terverifikasi</div>
                <div class="db-value">{{ number_format(kubikasi['terverifikasi'], 0, ',', '.') }} m³</div>
            </div>
        </div>
        <div class="db-sub">
            <span>Berdasarkan data yang sudah terverifikasi</span>
        </div>
    </div>

    <div class="dashboard-box dashboard-box-tall db-card db-pos-2">
        <div class="db-card-top">
            <div>
                <div class="db-title">Estimasi DRD <span>Bulan ini</span></div>
                <div class="db-value db-value-green">Rp.{{ number_format(drd['bulan_ini'], 0, ',', '.') }}</div>
            </div>
            {% if drd['pct'] is not null %}
                <span class="db-badge {{ drd['pct'] < 0 ? 'db-badge-red' : 'db-badge-green' }}">{{ number_format(drd['pct'], 2, '.', '') }} %</span>
            {% endif %}
        </div>
        <div class="db-sub">
            <span>DRD bulan lalu</span>
            <strong>Rp.{{ number_format(drd['bulan_lalu'], 0, ',', '.') }}</strong>
        </div>

        <div class="db-verif">
            <div>
                <div class="db-title">DRD Terverifikasi</div>
                <div class="db-value db-value-green">Rp.{{ number_format(drd['terverifikasi'], 0, ',', '.') }}</div>
            </div>
        </div>
        <div class="db-sub">
            <span>Estimasi DRD hasil pencatatan terverifikasi</span>
        </div>
    </div>

    <div class="dashboard-box db-card dashboard-box-tallest db-pos-3 db-box-flex">
        <div class="db-title">Progress Per Zona <span>Pencatatan</span></div>

        <div class="db-zona-list">
            {% if zonaProgress is defined and zonaProgress|length > 0 %}
                {% for zona in zonaProgress %}
                <div class="db-zona-row">
                    <div class="db-zona-label">{{ zona['label'] }} <span><strong>{{ number_format(zona['sudah_baca'], 0, ',', '.') }} / {{ number_format(zona['total'], 0, ',', '.') }}</strong></span></div>
                    <div class="db-bar"><div class="db-bar-fill" style="width:{{ zona['pct_baca'] }}%"></div></div>
                    <div class="db-zona-label db-zona-sub">Terverifikasi <span><strong>{{ number_format(zona['terverifikasi'], 0, ',', '.') }} / {{ number_format(zona['total'], 0, ',', '.') }}</strong></span></div>
                    <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:{{ zona['pct_verif'] }}%"></div></div>
                </div>
                {% endfor %}
            {% else %}
                <p style="color:#9aa4b2; text-align:center; padding:20px 10px;">Belum ada zona tercatat di database.</p>
            {% endif %}
        </div>
    </div>

    <div class="dashboard-box db-card dashboard-box-tallest db-pos-4 db-box-flex">
        <div class="db-title">Anomali Pencatatan <span>Anomali Terbanyak</span></div>
        <div class="db-donut-wrap db-donut-wrap-grow">
            <div class="db-donut" style="background: conic-gradient({{ anomaliChart['gradient'] }});">
                <div class="db-donut-center">
                    <div class="db-donut-total">{{ anomaliChart['total'] }}</div>
                    <div class="db-donut-caption">total</div>
                </div>
            </div>
            <ul class="db-legend">
                {% if anomaliChart['legend']|length > 0 %}
                    {% for item in anomaliChart['legend'] %}
                    <li><span class="dot" style="background:{{ item['color'] }}"></span><span class="db-legend-name">{{ item['nama'] }}</span><span class="db-legend-pct">{{ item['pct'] }}%</span></li>
                    {% endfor %}
                {% else %}
                    <li><span class="dot" style="background:#e5e7eb"></span><span class="db-legend-name">Tidak ada anomali</span><span class="db-legend-pct">0%</span></li>
                {% endif %}
            </ul>
        </div>
    </div>

    <div class="dashboard-box dashboard-box-wide db-pos-5 db-card db-card-flat">
        <div class="db-split">
            <div class="db-split-col">
                <div class="db-split-header">Total Sudah Baca Bulan Ini <span>Jumlah Pencatatan</span></div>
                <ul class="db-list">
                    <li><span>Belum :</span><strong>{{ number_format(ringkasan['belum'], 0, ',', '.') }}</strong></li>
                    <li><span>Hari ini :</span><strong>{{ number_format(ringkasan['hari_ini'], 0, ',', '.') }}</strong></li>
                    <li><span>Kemarin :</span><strong>{{ number_format(ringkasan['kemarin'], 0, ',', '.') }}</strong></li>
                    <li><span>Anomali :</span><strong>{{ number_format(ringkasan['anomali'], 0, ',', '.') }} ({{ number_format(ringkasan['anomali_pct'], 2, '.', '') }}%)</strong></li>
                </ul>
            </div>
            <div class="db-split-col">
                <div class="db-split-header">Info Data Terverifikasi</div>
                <ul class="db-list">
                    <li><span>Belum Terverifikasi :</span><strong>{{ number_format(ringkasan['belum_verifikasi'], 0, ',', '.') }}</strong></li>
                    <li><span>Terverifikasi :</span><strong>{{ number_format(ringkasan['terverifikasi'], 0, ',', '.') }}</strong></li>
                    <li><span>Persentase :</span><strong>{{ number_format(ringkasan['terverifikasi_pct'], 2, '.', '') }}%</strong></li>
                    <li><span>Total Pencatatan :</span><strong>{{ number_format(ringkasan['sudah_baca'], 0, ',', '.') }} ({{ number_format(ringkasan['baca_pct'], 2, '.', '') }}%)</strong></li>
                </ul>
            </div>
        </div>
    </div>
</div>

<div class="dashboard-charts-row">
    <div class="db-card db-chart-box">
        <div class="db-title">Grafik Pencatatan <span>Progress Pencatatan</span></div>
        <div class="db-donut-wrap db-donut-center-wrap">
            <div class="db-donut db-donut-lg" style="background: conic-gradient(#5a6fd8 0% {{ ringkasan['baca_pct'] }}%, #f5e07a {{ ringkasan['baca_pct'] }}% 100%);">
                <div class="db-donut-center">
                    <div class="db-donut-caption">progress</div>
                    <div class="db-donut-total">{{ number_format(ringkasan['baca_pct'], 2, '.', '') }}%</div>
                </div>
            </div>
        </div>
    </div>

    <div class="db-card db-chart-box db-chart-box-wide">
        <div class="db-title">Grafik Pencatatan per Hari <span>Progress Pencatatan per Hari</span></div>
        <div class="db-line-legend">
            <span><i style="background:#3fae6b"></i>Total Tercatat</span>
            <span><i style="background:#f2b544"></i>Tercatat Normal</span>
            <span><i style="background:#e0564a"></i>Tercatat Abnormal</span>
        </div>
        <div class="db-line-scroll">
        <svg viewBox="0 0 1200 300" class="db-line-svg">
            {# Gridline + label sumbu Y -- dihitung realtime di controller (niceCeilMax) #}
            {% for tick in grafikHarian['y_ticks'] %}
            <line x1="{{ grafikHarian['left'] }}" y1="{{ tick['y'] }}" x2="{{ grafikHarian['right'] }}" y2="{{ tick['y'] }}" class="db-grid"/><text x="{{ grafikHarian['left'] - 8 }}" y="{{ tick['y'] + 3 }}" class="db-ylabel">{{ number_format(tick['value'], 0, ',', '.') }}</text>
            {% endfor %}

            {# Label sumbu X -- tanggal 1..akhir bulan periode berjalan #}
            {% for xl in grafikHarian['x_labels'] %}
            <text x="{{ xl['x'] }}" y="{{ grafikHarian['bottom_label_y'] }}" class="db-xlabel">{{ xl['day'] }}</text>
            {% endfor %}

            {# Garis Total Tercatat (hijau) #}
            <polyline class="db-line-total" fill="none" points="{{ grafikHarian['points_total'] }}"/>

            {# Garis Tercatat Normal (kuning/oranye) #}
            <polyline class="db-line-normal" fill="none" points="{{ grafikHarian['points_normal'] }}"/>

            {# Garis Tercatat Abnormal (merah) #}
            <polyline class="db-line-abnormal" fill="none" points="{{ grafikHarian['points_abnormal'] }}"/>
        </svg>
        </div>
    </div>
</div>
{% endblock %}
