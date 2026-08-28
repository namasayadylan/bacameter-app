{% extends "layouts/main.volt" %}

{% block content %}
<div class="page-header">
    <h1>Dashboard</h1>
</div>

<div class="dashboard-boxes">
    <div class="dashboard-box dashboard-box-tall db-card db-pos-1">
        <div class="db-card-top">
            <div>
                <div class="db-title">Total Kubikasi <span>Bulan ini</span></div>
                <div class="db-value">-1.816.452 m³</div>
            </div>
            <span class="db-badge db-badge-red">-208.30%</span>
        </div>
        <div class="db-sub">
            <span>Kubikasi bulan lalu</span>
            <strong>1.677.244 m³</strong>
        </div>

        <div class="db-verif">
            <div>
                <div class="db-title">Kubikasi Terverifikasi</div>
                <div class="db-value">2.049.130 m³</div>
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
                <div class="db-value db-value-green">Rp.29.155.450.700</div>
            </div>
            <span class="db-badge db-badge-green">48.84 %</span>
        </div>
        <div class="db-sub">
            <span>DRD bulan lalu</span>
            <strong>Rp.19.588.858.700</strong>
        </div>

        <div class="db-verif">
            <div>
                <div class="db-title">DRD Terverifikasi</div>
                <div class="db-value db-value-green">Rp.24.514.721.000</div>
            </div>
        </div>
        <div class="db-sub">
            <span>Estimasi DRD hasil pencatatan terverifikasi</span>
        </div>
    </div>

    <div class="dashboard-box db-card dashboard-box-tallest db-pos-3 db-box-flex">
        <div class="db-title">Progress Per Zona <span>Pencatatan</span></div>

        <div class="db-zona-list">
            <div class="db-zona-row">
                <div class="db-zona-label">Zona I <strong>67.636 / 73.960</strong></div>
                <div class="db-bar"><div class="db-bar-fill" style="width:93.62%"></div></div>
                <div class="db-zona-label db-zona-sub">Terverifikasi <strong>60.220 / 73.960</strong></div>
                <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:86.10%"></div></div>
            </div>
            <div class="db-zona-row">
                <div class="db-zona-label">Zona II <strong>7.574/ 8.021</strong></div>
                <div class="db-bar"><div class="db-bar-fill" style="width:96.72%"></div></div>
                <div class="db-zona-label db-zona-sub">Terverifikasi <strong>6.551/ 8.021</strong></div>
                <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:87.09%"></div></div>
            </div>
            <div class="db-zona-row">
                <div class="db-zona-label">Zona III <strong>11.837 / 12.635</strong></div>
                <div class="db-bar"><div class="db-bar-fill" style="width:98.74%"></div></div>
                <div class="db-zona-label db-zona-sub">Terverifikasi <strong>11.498 / 12.635</strong></div>
                <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:95.80%"></div></div>
            </div>
            <div class="db-zona-row">
                <div class="db-zona-label">Zona IV <strong>18.863 / 19.612</strong></div>
                <div class="db-bar"><div class="db-bar-fill" style="width:98.53%"></div></div>
                <div class="db-zona-label db-zona-sub">Terverifikasi <strong>17.628 / 19.612</strong></div>
                <div class="db-bar db-bar-light"><div class="db-bar-fill" style="width:96.14%"></div></div>
            </div>
        </div>
    </div>

    <div class="dashboard-box db-card dashboard-box-tallest db-pos-4 db-box-flex">
        <div class="db-title">Anomali Pencatatan <span>Anomali Terbanyak</span></div>
        <div class="db-donut-wrap db-donut-wrap-grow">
            {% if anomaliChart['total'] == 0 %}
                <p style="color:#9aa4b2; text-align:center; padding:20px 10px;">Belum ada data anomali.</p>
            {% else %}
                <div class="db-donut" style="background: conic-gradient({{ anomaliChart['gradient'] }});">
                    <div class="db-donut-center">
                        <div class="db-donut-total">{{ anomaliChart['total'] }}</div>
                        <div class="db-donut-caption">total</div>
                    </div>
                </div>
                <ul class="db-legend">
                    {% for item in anomaliChart['legend'] %}
                    <li><span class="dot" style="background:{{ item['color'] }}"></span><span class="db-legend-name">{{ item['nama'] }}</span><span class="db-legend-pct">{{ item['pct'] }}%</span></li>
                    {% endfor %}
                </ul>
            {% endif %}
        </div>
    </div>

    <div class="dashboard-box dashboard-box-wide db-pos-5 db-card db-card-flat">
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
                    <li><span>Total Pencatatan :</span><strong>120.082 (92.51%)</strong></li>
                </ul>
            </div>
        </div>
    </div>
</div>

<div class="dashboard-charts-row">
    <div class="db-card db-chart-box">
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

    <div class="db-card db-chart-box db-chart-box-wide">
        <div class="db-title">Grafik Pencatatan per Hari <span>Progress Pencatatan per Hari</span></div>
        <div class="db-line-legend">
            <span><i style="background:#3fae6b"></i>Total Tercatat</span>
            <span><i style="background:#f2b544"></i>Tercatat Normal</span>
            <span><i style="background:#e0564a"></i>Tercatat Abnormal</span>
        </div>
        <div class="db-line-scroll">
        <svg viewBox="0 0 1200 300" class="db-line-svg">
            {# Gridline + label sumbu Y (0..7480, step 680) #}
            <line x1="55" y1="265.0" x2="1180" y2="265.0" class="db-grid"/><text x="47" y="268.0" class="db-ylabel">0</text>
            <line x1="55" y1="242.3" x2="1180" y2="242.3" class="db-grid"/><text x="47" y="245.3" class="db-ylabel">680</text>
            <line x1="55" y1="219.5" x2="1180" y2="219.5" class="db-grid"/><text x="47" y="222.5" class="db-ylabel">1360</text>
            <line x1="55" y1="196.8" x2="1180" y2="196.8" class="db-grid"/><text x="47" y="199.8" class="db-ylabel">2040</text>
            <line x1="55" y1="174.1" x2="1180" y2="174.1" class="db-grid"/><text x="47" y="177.1" class="db-ylabel">2720</text>
            <line x1="55" y1="151.4" x2="1180" y2="151.4" class="db-grid"/><text x="47" y="154.4" class="db-ylabel">3400</text>
            <line x1="55" y1="128.6" x2="1180" y2="128.6" class="db-grid"/><text x="47" y="131.6" class="db-ylabel">4080</text>
            <line x1="55" y1="105.9" x2="1180" y2="105.9" class="db-grid"/><text x="47" y="108.9" class="db-ylabel">4760</text>
            <line x1="55" y1="83.2"  x2="1180" y2="83.2"  class="db-grid"/><text x="47" y="86.2"  class="db-ylabel">5440</text>
            <line x1="55" y1="60.5"  x2="1180" y2="60.5"  class="db-grid"/><text x="47" y="63.5"  class="db-ylabel">6120</text>
            <line x1="55" y1="37.7"  x2="1180" y2="37.7"  class="db-grid"/><text x="47" y="40.7"  class="db-ylabel">6800</text>
            <line x1="55" y1="15.0"  x2="1180" y2="15.0"  class="db-grid"/><text x="47" y="18.0"  class="db-ylabel">7480</text>

            {# Label sumbu X (tanggal 2..28) #}
            <text x="55.0" y="283" class="db-xlabel">2</text>
            <text x="98.3" y="283" class="db-xlabel">3</text>
            <text x="141.5" y="283" class="db-xlabel">4</text>
            <text x="184.8" y="283" class="db-xlabel">5</text>
            <text x="228.1" y="283" class="db-xlabel">6</text>
            <text x="271.3" y="283" class="db-xlabel">7</text>
            <text x="314.6" y="283" class="db-xlabel">8</text>
            <text x="357.9" y="283" class="db-xlabel">9</text>
            <text x="401.2" y="283" class="db-xlabel">10</text>
            <text x="444.4" y="283" class="db-xlabel">11</text>
            <text x="487.7" y="283" class="db-xlabel">12</text>
            <text x="531.0" y="283" class="db-xlabel">13</text>
            <text x="574.2" y="283" class="db-xlabel">14</text>
            <text x="617.5" y="283" class="db-xlabel">15</text>
            <text x="660.8" y="283" class="db-xlabel">16</text>
            <text x="704.0" y="283" class="db-xlabel">17</text>
            <text x="747.3" y="283" class="db-xlabel">18</text>
            <text x="790.6" y="283" class="db-xlabel">19</text>
            <text x="833.8" y="283" class="db-xlabel">20</text>
            <text x="877.1" y="283" class="db-xlabel">21</text>
            <text x="920.4" y="283" class="db-xlabel">22</text>
            <text x="963.7" y="283" class="db-xlabel">23</text>
            <text x="1006.9" y="283" class="db-xlabel">24</text>
            <text x="1050.2" y="283" class="db-xlabel">25</text>
            <text x="1093.5" y="283" class="db-xlabel">26</text>
            <text x="1136.7" y="283" class="db-xlabel">27</text>
            <text x="1180.0" y="283" class="db-xlabel">28</text>

            {# Garis Total Tercatat (hijau) #}
            <polyline class="db-line-total" fill="none"
                points="55.0,251.6 98.3,234.9 141.5,158.0 184.8,101.2 228.1,144.7 271.3,154.7 314.6,141.3 357.9,154.7 401.2,15.0 444.4,77.8 487.7,74.5 531.0,61.1 574.2,74.5 617.5,74.5 660.8,234.9 704.0,244.9 747.3,27.7 790.6,21.0 833.8,15.0 877.1,74.5 920.4,81.2 963.7,121.3 1006.9,24.4 1050.2,121.3 1093.5,74.5 1136.7,67.8 1180.0,255.0"/>

            {# Garis Tercatat Normal (kuning/oranye) #}
            <polyline class="db-line-normal" fill="none"
                points="55.0,255.0 98.3,241.6 141.5,178.1 184.8,128.0 228.1,168.1 271.3,178.1 314.6,164.7 357.9,174.8 401.2,60.5 444.4,107.9 487.7,104.6 531.0,94.5 574.2,107.9 617.5,107.9 660.8,241.6 704.0,248.3 747.3,61.1 790.6,57.8 833.8,60.5 877.1,104.6 920.4,111.3 963.7,148.0 1006.9,84.5 1050.2,148.0 1093.5,104.6 1136.7,101.2 1180.0,256.6"/>

            {# Garis Tercatat Abnormal (merah) #}
            <polyline class="db-line-abnormal" fill="none"
                points="55.0,261.7 98.3,258.3 141.5,244.9 184.8,238.3 228.1,241.6 271.3,241.6 314.6,241.6 357.9,244.9 401.2,219.5 444.4,234.9 487.7,234.9 531.0,231.6 574.2,231.6 617.5,231.6 660.8,258.3 704.0,261.7 747.3,231.6 790.6,228.2 833.8,219.5 877.1,234.9 920.4,234.9 963.7,238.3 1006.9,204.8 1050.2,238.3 1093.5,234.9 1136.7,231.6 1180.0,263.3"/>
        </svg>
        </div>
    </div>
</div>
{% endblock %}
