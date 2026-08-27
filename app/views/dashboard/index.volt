{% extends "layouts/main.volt" %}

{% block content %}
<div class="page-header">
    <h1>Dashboard</h1>
</div>

<div class="dashboard-boxes">
    <div class="dashboard-box db-card">
        <div class="db-card-top">
            <div>
                <div class="db-title">Total Kubikasi <span>Bulan ini</span></div>
                <div class="db-value">0 m³</div>
            </div>
            <span class="db-badge db-badge-red">0 %</span>
        </div>
        <div class="db-sub">
            <span>Kubikasi bulan lalu</span>
            <strong>0 m³</strong>
        </div>
    </div>

    <div class="dashboard-box db-card">
        <div class="db-card-top">
            <div>
                <div class="db-title">Estimasi DRD <span>Bulan ini</span></div>
                <div class="db-value db-value-green">Rp.0</div>
            </div>
            <span class="db-badge db-badge-green">0 %</span>
        </div>
        <div class="db-sub">
            <span>DRD bulan lalu</span>
            <strong>Rp.0</strong>
        </div>
    </div>

    <div class="dashboard-box db-card dashboard-box-tall">
        <div class="db-title">Progress Per Zona <span>Pencatatan</span></div>

        <div class="db-zona-row">
            <div class="db-zona-label">Zona I <strong>0 / 0</strong></div>
            <div class="db-bar"><div class="db-bar-fill" style="width:0%"></div></div>
            <div class="db-zona-label db-zona-sub">Terverifikasi <strong>0 / 0</strong></div>
            <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:0%"></div></div>
        </div>
        <div class="db-zona-row">
            <div class="db-zona-label">Zona II <strong>0 / 0</strong></div>
            <div class="db-bar"><div class="db-bar-fill" style="width:0%"></div></div>
            <div class="db-zona-label db-zona-sub">Terverifikasi <strong>0 / 0</strong></div>
            <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:0%"></div></div>
        </div>
        <div class="db-zona-row">
            <div class="db-zona-label">Zona III <strong>0 / 0</strong></div>
            <div class="db-bar"><div class="db-bar-fill" style="width:0%"></div></div>
            <div class="db-zona-label db-zona-sub">Terverifikasi <strong>0 / 0</strong></div>
            <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:0%"></div></div>
        </div>
        <div class="db-zona-row">
            <div class="db-zona-label">Zona IV <strong>0 / 0</strong></div>
            <div class="db-bar"><div class="db-bar-fill" style="width:0%"></div></div>
            <div class="db-zona-label db-zona-sub">Terverifikasi <strong>0 / 0</strong></div>
            <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:0%"></div></div>
        </div>
    </div>

    <div class="dashboard-box db-card dashboard-box-tall">
        <div class="db-title">Anomali Pencatatan <span>Anomali Terbanyak</span></div>
        <div class="db-donut-wrap">
            <div class="db-donut" style="background: conic-gradient(#5a9e3f 0% 45%, #f2c744 45% 65%, #e0563a 65% 78%, #1a3d1a 78% 85%, #8fa03f 85% 90%, #b9b9b9 90% 96%, #d94f97 96% 100%);">
                <div class="db-donut-center">
                    <div class="db-donut-total">27.119</div>
                    <div class="db-donut-caption">total</div>
                </div>
            </div>
            <ul class="db-legend">
                <li><span class="dot" style="background:#5a9e3f"></span>Rumah terkunci</li>
                <li><span class="dot" style="background:#e0563a"></span>Rumah Kosong</li>
                <li><span class="dot" style="background:#1a3d1a"></span>Meter Rusak/Mati</li>
                <li><span class="dot" style="background:#8fa03f"></span>Meter Buram</li>
                <li><span class="dot" style="background:#b9b9b9"></span>Meter di kunci</li>
                <li><span class="dot" style="background:#f2c744"></span>Meter Umur Teknis</li>
            </ul>
        </div>
    </div>

    <div class="dashboard-box dashboard-box-wide db-card db-card-flat">
        <div class="db-split">
            <div class="db-split-col">
                <div class="db-split-header">Total Sudah Baca Bulan Ini <span>Jumlah Pencatatan</span></div>
                <ul class="db-list">
                    <li><span>Belum :</span><strong>9.725</strong></li>
                    <li><span>Hari ini :</span><strong>2.074</strong></li>
                    <li><span>Kemarin :</span><strong>6.592</strong></li>
                    <li><span>Anomali :</span><strong>120.082 (92.51%)</strong></li>
                </ul>
            </div>
            <div class="db-split-col">
                <div class="db-split-header">Info Data Terverifikasi</div>
                <ul class="db-list">
                    <li><span>Belum Terverifikasi :</span><strong>20.626</strong></li>
                    <li><span>Terverifikasi :</span><strong>109.181</strong></li>
                    <li><span>Persentase :</span><strong>84.11%</strong></li>
                    <li><span>Total Pencatatan :</span><strong>120.082</strong></li>
                </ul>
            </div>
        </div>
    </div>
</div>

//garafik sama perapihan belum 
 <div class="dashboard-box db-card db-chart-box">
        <div class="db-title">Grafik Pencatatan <span>Progress Pencatatan</span></div>
        <div class="db-donut-wrap db-donut-center-wrap">
            <div class="db-donut db-donut-lg" style="background: conic-gradient(#5a6fd8 0% 92.51%, #f5e07a 92.51% 100%);">
                <div class="db-donut-center">
                    <div class="db-donut-caption">progress</div>
                    <div class="db-donut-total">92.51%</div>
                </div>
            </div>
        </div>
    </div>

    <div class="dashboard-box dashboard-box-wide3 db-card db-chart-box">
        <div class="db-title">Grafik Pencatatan per Hari <span>Progress Pencatatan per Hari</span></div>
        <div class="db-line-legend">
            <span><i style="background:#3fae6b"></i>Total Tercatat</span>
            <span><i style="background:#f2b544"></i>Tercatat Normal</span>
            <span><i style="background:#e0564a"></i>Tercatat Abnormal</span>
        </div>
        <div class="db-line-chart-static"></div>
    </div>
</div>
{% endblock %}