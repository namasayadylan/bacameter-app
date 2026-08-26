{% extends "layouts/main.volt" %}

{% block content %}
<div class="page-header">
    <h1>{{ pageTitle }} <small style="font-size:12px; color:#7c8aa0; font-weight:400;">— Periode {{ periode }}</small></h1>
</div>

<div class="dm-wrap">
    <div class="dm-left">
        <div class="dm-card">
            <div class="dm-card-h">👤 Info Pelanggan</div>
            <div class="dm-tabs">
                <div class="dm-tab on" data-tab="info">👤 Info</div>
                <div class="dm-tab" data-tab="last">🏷️ Last M³</div>
                <div class="dm-tab" data-tab="loc">📍 Lokasi</div>
            </div>

            <div class="dm-tabpane on" id="dm-tab-info">
                <div class="dm-info" id="dmInfoEmpty">
                    <p style="color:#9aa4b2; text-align:center; padding:20px 10px;">
                        Klik salah satu baris di tabel untuk menampilkan detail pelanggan.
                    </p>
                </div>
                <div class="dm-info" id="dmInfoFilled" style="display:none;">
                    <div class="dm-row"><span class="dm-k">Nama</span><span class="dm-v" id="dmNama">-</span></div>
                    <div class="dm-row"><span class="dm-k">No Pelanggan</span><span class="dm-v" id="dmNoPel">-</span></div>
                    <div class="dm-row"><span class="dm-k">Alamat</span><span class="dm-v" id="dmAlamat">-</span></div>
                    <div class="dm-row"><span class="dm-k">Info Meteran</span><span class="dm-v" id="dmMeteran">-</span></div>
                    <div class="dm-row"><span class="dm-k">Petugas</span><span class="dm-v" id="dmPetugas">-</span></div>
                    <div class="dm-row"><span class="dm-k">Tanggal Catat</span><span class="dm-v" id="dmTglCatat">-</span></div>
                    <div class="dm-row"><span class="dm-k">Waktu Catat</span><span class="dm-v" id="dmWaktuCatat">-</span></div>
                </div>
            </div>
            <div class="dm-tabpane" id="dm-tab-last">
                <table class="dm-lastm">
                    <thead><tr><th>Periode</th><th>Stand</th><th>M³</th></tr></thead>
                    <tbody id="dmLastBody">
                        <tr><td colspan="3" style="color:#9aa4b2;">-</td></tr>
                    </tbody>
                </table>
                <div class="dm-avg3"><span>Rata² 3 Bln</span><span class="dm-avg-val" id="dmAvg3">-</span></div>
            </div>

            <div class="dm-tabpane" id="dm-tab-loc">
                <div id="dmMap"></div>
                <div class="dm-urlhint" id="dmLatLongHint" style="border-top:0;">Belum ada data lokasi.</div>
            </div>
        </div>

        <div class="dm-card dm-foto">
            <div class="dm-card-h">🖼️ Foto Stand</div>
            <div class="dm-foto-cap"><span id="dmFotoKendala">-</span> <span class="dm-stand" id="dmFotoStand">-</span></div>
            <div class="dm-meter">
                <img class="dm-fotostand" id="dmFotoImg" src="" alt="Foto stand meter" style="display:none;">
                <div id="dmFotoFallback" class="dm-dial"><div class="dm-lcd">-----</div></div>
            </div>
            <div class="dm-urlhint"><code id="dmFotoUrlHint">wamena.tirtapatriot.net/{periode}/{nomor_pelanggan}.jpg?ref={uniq}</code></div>
        </div>
    </div>

    <div class="dm-card dm-right">
        <div class="dm-rh">
            <div class="dm-title">📝 Monitoring Data</div>
            <div class="dm-btns">
                <button type="button" class="btn btn-secondary" id="btnRefresh">🔄 Refresh</button>
                <button type="button" class="btn btn-primary" id="btnCari">🔍 Pencarian (F2)</button>
            </div>
        </div>

        <div class="dm-toolbar">
            <label class="dm-show-entries">
                Tampilkan
                <select id="dmShowEntries">
                    <option value="10">10</option>
                    <option value="25" selected>25</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
                    <option value="all">Semua</option>
                </select>
                entri
            </label>
            <div class="dm-selected-info" id="dmSelectedInfo"></div>
        </div>

        {% if isCapped is defined and isCapped %}
        <div class="dm-capped-notice">
            ⚠️ Menampilkan {{ rowLimit }} dari {{ totalMatch }} hasil yang cocok. Perhalus pencarian (nomor pelanggan, tanggal, dsb) untuk mempersempit hasil.
        </div>
        {% endif %}

        <div class="dm-twrap">
            <table class="dm-table">
                <thead>
                    <tr>
                        <th class="dm-th-chk"><input type="checkbox" id="dmCheckAll" title="Pilih semua (halaman ini)"></th>
                        <th>Tgl<br>Catat</th>
                        <th>No Pel</th>
                        <th>Nama</th>
                        <th>Alamat</th>
                        <th>St.<br>Awal</th>
                        <th>St.<br>Akhir</th>
                        <th>St. Ctt<br>Ptgs</th>
                        <th>M³</th>
                        <th>M³<br>Lalu</th>
                        <th>Kendala</th>
                        <th>%</th>
                        <th>Petugas</th>
                        <th>Harga<br>Air</th>
                        <th>Admin</th>
                        <th>Total<br>Rekening</th>
                    </tr>
                </thead>
                <tbody>
                    {% if rows is empty %}
                        <tr><td colspan="16" class="dm-empty">Tidak ada data untuk filter/periode ini.</td></tr>
                    {% else %}
                        {% for r in rows %}
                        <tr class="dm-row-click" data-id="{{ r['id'] }}" data-pakai="{{ r['pakai'] }}" data-total="{{ r['total_rekening'] }}">
                            <td class="dm-td-chk" onclick="event.stopPropagation();"><input type="checkbox" class="dm-rowchk" data-id="{{ r['id'] }}"></td>
                            <td>{{ r['tanggal_catat'] }}</td>
                            <td class="num">{{ r['nomor_pelanggan'] }}</td>
                            <td class="l dm-nama">{{ r['nama'] }}</td>
                            <td class="l dm-alamat">{{ r['alamat'] }}</td>
                            <td class="num">{{ r['stand_awal'] }}</td>
                            <td class="num">{{ r['stand_akhir'] }}</td>
                            <td class="num">{{ r['stand_catatpetugas'] }}</td>
                            <td class="num">{{ r['pakai'] }}</td>
                            <td class="num">{{ r['pakai1'] }}</td>
                            <td class="l dm-kendala-{{ r['kendala_class'] }}">{{ r['kode_anomali'] }} · {{ r['nama_anomali'] }}</td>
                            <td class="dm-pct {% if r['pct'] == null %}zero{% else %}{{ r['pct_class'] }}{% endif %}">
                                {% if r['pct'] == null %}—{% else %}{{ r['pct'] }}%{% endif %}
                            </td>
                            <td><span class="dm-petugas">{{ r['nama_petugas'] }}</span></td>
                            <td class="num">{{ number_format(r['harga_air'], 0, ',', '.') }}</td>
                            <td class="num">{{ number_format(r['biaya_admin'], 0, ',', '.') }}</td>
                            <td class="num">{{ number_format(r['total_rekening'], 0, ',', '.') }}</td>
                        </tr>
                        {% endfor %}
                    {% endif %}
                </tbody>
            </table>
        </div>

        <div class="dm-tfoot" data-total-pelanggan="{{ totalPelanggan }}" data-total-m3="{{ totalM3 }}" data-total-rekening="{{ totalRekening }}">
            <div class="dm-totals">
                <div class="dm-trow"><span class="dm-tk" id="dmTotalLabel1">Total Pelanggan</span><span class="dm-tv" id="dmTotalPelanggan">{{ totalPelanggan }}</span></div>
                <div class="dm-trow"><span class="dm-tk" id="dmTotalLabel2">Total Kubikasi M³</span><span class="dm-tv" id="dmTotalM3">{{ totalM3 }}</span></div>
                <div class="dm-trow"><span class="dm-tk" id="dmTotalLabel3">Total Tagihan Rekening</span><span class="dm-tv" id="dmTotalRekening">Rp {{ number_format(totalRekening, 0, ',', '.') }}</span></div>
            </div>
            <div class="dm-pagination">
                <button type="button" id="dmPagePrev">‹ Prev</button>
                <span class="dm-page-info" id="dmPageInfo">Hal 1 / 1</span>
                <button type="button" id="dmPageNext">Next ›</button>
            </div>
        </div>
    </div>
</div>

<div class="dm-overlay" id="dmOverlay">
    <div class="dm-modal">
        <div class="dm-modal-h">
            <div class="dm-mt">🔍 Pencarian — Monitoring Data</div>
            <div class="dm-x" id="dmBtnClose">✕</div>
        </div>
        <form class="dm-modal-b" id="dmFilterForm" method="get" action="{{ url('datameter') }}">
            <div class="dm-frow {% if filter['no_pel'] == '' %}dis{% endif %}">
                <label class="dm-sw-t"><input type="checkbox" {% if filter['no_pel'] != '' %}checked{% endif %}><span class="dm-sl"></span></label>
                <span class="dm-flabel">Nomor Pelanggan</span>
                <input type="text" name="no_pel" value="{{ filter['no_pel'] }}" placeholder="mis. 010101028017">
            </div>
            <div class="dm-frow {% if filter['id_anomali'] == 0 %}dis{% endif %}">
                <label class="dm-sw-t"><input type="checkbox" {% if filter['id_anomali'] != 0 %}checked{% endif %}><span class="dm-sl"></span></label>
                <span class="dm-flabel">Kendala / Alasan</span>
                <select name="id_anomali">
                    <option value="0">- Pilih Kendala -</option>
                    {% for a in anomaliOptions %}
                    <option value="{{ a['id'] }}" {% if filter['id_anomali'] == a['id'] %}selected{% endif %}>{{ a['kode'] }} — {{ a['nama'] }}</option>
                    {% endfor %}
                </select>
            </div>
            <div class="dm-frow {% if filter['nama'] == '' %}dis{% endif %}">
                <label class="dm-sw-t"><input type="checkbox" {% if filter['nama'] != '' %}checked{% endif %}><span class="dm-sl"></span></label>
                <span class="dm-flabel">Nama</span>
                <input type="text" name="nama" value="{{ filter['nama'] }}" placeholder="mis. BAMBANG">
            </div>
            <div class="dm-frow {% if filter['tgl1'] == '' %}dis{% endif %}">
                <label class="dm-sw-t"><input type="checkbox" {% if filter['tgl1'] != '' %}checked{% endif %}><span class="dm-sl"></span></label>
                <span class="dm-flabel">Tanggal Baca</span>
                <div class="dm-rangewrap">
                    <input type="date" name="tgl1" value="{{ filter['tgl1'] }}"><span>s.d</span><input type="date" name="tgl2" value="{{ filter['tgl2'] }}">
                </div>
            </div>
            <div class="dm-frow {% if filter['alamat'] == '' %}dis{% endif %}">
                <label class="dm-sw-t"><input type="checkbox" {% if filter['alamat'] != '' %}checked{% endif %}><span class="dm-sl"></span></label>
                <span class="dm-flabel">Alamat</span>
                <input type="text" name="alamat" value="{{ filter['alamat'] }}" placeholder="mis. D2/17">
            </div>
            <div class="dm-frow {% if filter['pakai_val'] == '' %}dis{% endif %}">
                <label class="dm-sw-t"><input type="checkbox" {% if filter['pakai_val'] != '' %}checked{% endif %}><span class="dm-sl"></span></label>
                <span class="dm-flabel">Pemakaian (m³)</span>
                <div class="dm-rangewrap">
                    <select name="pakai_op" style="flex:0 0 64px;">
                        <option value="=" {% if filter['pakai_op'] == '=' %}selected{% endif %}>=</option>
                        <option value="<" {% if filter['pakai_op'] == '<' %}selected{% endif %}>&lt;</option>
                        <option value=">" {% if filter['pakai_op'] == '>' %}selected{% endif %}>&gt;</option>
                    </select>
                    <input type="number" name="pakai_val" value="{{ filter['pakai_val'] }}" placeholder="mis. 20">
                </div>
            </div>
            <div class="dm-frow {% if filter['no_meter'] == '' %}dis{% endif %}">
                <label class="dm-sw-t"><input type="checkbox" {% if filter['no_meter'] != '' %}checked{% endif %}><span class="dm-sl"></span></label>
                <span class="dm-flabel">Nomor Meter</span>
                <input type="text" name="no_meter" value="{{ filter['no_meter'] }}" placeholder="mis. 309403">
            </div>
        </form>
        <div class="dm-modal-f">
            <a href="{{ url('datameter') }}" class="btn btn-secondary">Reset</a>
            <button type="button" class="btn btn-primary" id="dmBtnApply">Terapkan Filter →</button>
        </div>
    </div>
</div>
{% endblock %}
