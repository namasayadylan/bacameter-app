document.addEventListener('DOMContentLoaded', function () {

    document.querySelectorAll('.js-confirm-delete').forEach(function (link) {
        link.addEventListener('click', function (e) {
            var msg = link.dataset.confirm || 'Yakin mau menghapus data ini?';
            if (!window.confirm(msg)) {
                e.preventDefault();
            }
        });
    });

    var map = null;
    var marker = null;
    var currentLat = null;
    var currentLng = null;

    document.querySelectorAll('.dm-tab').forEach(function (t) {
        t.addEventListener('click', function () {
            document.querySelectorAll('.dm-tab').forEach(function (x) { x.classList.remove('on'); });
            document.querySelectorAll('.dm-tabpane').forEach(function (x) { x.classList.remove('on'); });
            t.classList.add('on');
            var pane = document.getElementById('dm-tab-' + t.dataset.tab);
            if (pane) { pane.classList.add('on'); }
            if (t.dataset.tab === 'loc') { initMap(); }
        });
    });

    function initMap() {
        var mapEl = document.getElementById('dmMap');
        if (!mapEl || currentLat === null || currentLng === null) { return; }

        if (!map) {
            map = L.map('dmMap').setView([currentLat, currentLng], 17);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '&copy; OpenStreetMap'
            }).addTo(map);
            marker = L.marker([currentLat, currentLng]).addTo(map).bindPopup('Lokasi pelanggan').openPopup();
            return;
        }

        map.setView([currentLat, currentLng], 17);
        if (marker) {
            marker.setLatLng([currentLat, currentLng]).openPopup();
        } else {
            marker = L.marker([currentLat, currentLng]).addTo(map).bindPopup('Lokasi pelanggan').openPopup();
        }
        setTimeout(function () { map.invalidateSize(); }, 100);
    }

    function clearMapMarker() {
        if (map && marker) {
            map.removeLayer(marker);
            marker = null;
        }
    }

    var overlay = document.getElementById('dmOverlay');
    var btnCari = document.getElementById('btnCari');
    var btnClose = document.getElementById('dmBtnClose');
    var btnApply = document.getElementById('dmBtnApply');
    var filterForm = document.getElementById('dmFilterForm');

    if (overlay && btnCari) {
        btnCari.addEventListener('click', function () { overlay.classList.add('show'); });
        btnClose.addEventListener('click', function () { overlay.classList.remove('show'); });
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) { overlay.classList.remove('show'); }
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'F2') { e.preventDefault(); overlay.classList.toggle('show'); }
            if (e.key === 'Escape') { overlay.classList.remove('show'); }
        });

        document.querySelectorAll('.dm-frow .dm-sw-t input').forEach(function (t) {
            t.addEventListener('change', function () {
                t.closest('.dm-frow').classList.toggle('dis', !t.checked);
            });
        });

        btnApply.addEventListener('click', function () {
            var params = new URLSearchParams();
            document.querySelectorAll('.dm-frow').forEach(function (row) {
                var isActive = row.querySelector('.dm-sw-t input').checked;
                if (!isActive) { return; }
                row.querySelectorAll('input, select').forEach(function (field) {
                    if (field.type === 'checkbox') { return; }
                    if (field.value !== '') { params.set(field.name, field.value); }
                });
            });
            window.location.href = filterForm.action + '?' + params.toString();
        });
    }

    var btnRefresh = document.getElementById('btnRefresh');
    if (btnRefresh) {
        btnRefresh.addEventListener('click', function () { window.location.reload(); });
    }

    var rows = document.querySelectorAll('.dm-row-click');

    function formatRupiah(n) {
        return new Intl.NumberFormat('id-ID').format(Math.round(n));
    }

    function loadDetail(id, rowEl) {
        fetch('datameter/detail/' + id)
            .then(function (res) { return res.json(); })
            .then(function (d) {
                if (d.error) { return; }

                rows.forEach(function (r) { r.classList.remove('sel'); });
                if (rowEl) { rowEl.classList.add('sel'); }

                document.getElementById('dmInfoEmpty').style.display = 'none';
                document.getElementById('dmInfoFilled').style.display = 'block';

                document.getElementById('dmNama').textContent = d.nama || '-';
                document.getElementById('dmNoPel').textContent = d.nomor_pelanggan || '-';
                document.getElementById('dmAlamat').textContent = d.alamat || '-';
                document.getElementById('dmMeteran').textContent =
                    (d.watermeter_name || '-') + ' · ' + (d.nomor_meter || '-');
                document.getElementById('dmPetugas').textContent = d.nama_petugas || '-';
                document.getElementById('dmTglCatat').textContent = d.tanggal_catat || '-';
                document.getElementById('dmWaktuCatat').textContent = d.waktu_catat || '-';

                var body = document.getElementById('dmLastBody');
                var periods = [
                    [d.periode1, d.stand_awal1, d.stand_akhir1, d.pakai1],
                    [d.periode2, d.stand_awal2, d.stand_akhir2, d.pakai2],
                    [d.periode3, d.stand_awal3, d.stand_akhir3, d.pakai3]
                ];
                body.innerHTML = '';
                periods.forEach(function (p) {
                    if (!p[0]) { return; }
                    var tr = document.createElement('tr');
                    tr.innerHTML = '<td>' + p[0] + '</td><td>' + p[1] + ' \u2013 ' + p[2] + '</td><td>' + p[3] + '</td>';
                    body.appendChild(tr);
                });
                if (!body.children.length) {
                    body.innerHTML = '<tr><td colspan="3" style="color:#9aa4b2;">Tidak ada histori.</td></tr>';
                }
                document.getElementById('dmAvg3').textContent = d.avg3 != null ? d.avg3.toFixed(2) : '-';

                currentLat = d.lat;
                currentLng = d.lng;
                var hint = document.getElementById('dmLatLongHint');
                if (currentLat !== null && currentLng !== null) {
                    hint.textContent = 'lat_long: ' + d.lat_long + ' \u2192 [lat ' + currentLat.toFixed(4) + ', lng ' + currentLng.toFixed(4) + ']';
                    if (map) { initMap(); } // map sudah pernah dibuka -> update langsung
                } else {
                    hint.textContent = 'Data lokasi tidak tersedia.';
                    clearMapMarker();
                }

                var img = document.getElementById('dmFotoImg');
                var fallback = document.getElementById('dmFotoFallback');
                var ref = Date.now() + Math.random();
                var url = 'https://wamena.tirtapatriot.net/' + d.periode + '/' + d.nomor_pelanggan + '.jpg?ref=' + ref;

                img.style.display = 'none';
                fallback.style.display = 'flex';
                img.onerror = function () {
                    img.style.display = 'none';
                    fallback.style.display = 'flex';
                };
                img.onload = function () {
                    img.style.display = 'block';
                    fallback.style.display = 'none';
                };
                img.src = url;

                document.getElementById('dmFotoKendala').textContent = d.nama_anomali || '-';
                document.getElementById('dmFotoStand').textContent =
                    String(d.stand_akhir).padStart(4, '0');
                fallback.querySelector('.dm-lcd').textContent = String(d.stand_akhir).padStart(5, '0');
                document.getElementById('dmFotoUrlHint').textContent = url;
            })
            .catch(function () {  });
    }

    rows.forEach(function (row) {
        row.addEventListener('click', function () {
            loadDetail(row.dataset.id, row);
        });
    });

    if (rows.length > 0) {
        loadDetail(rows[0].dataset.id, rows[0]);
    }

    var dmBodyRows   = Array.prototype.slice.call(document.querySelectorAll('.dm-table tbody tr.dm-row-click'));
    var dmShowSelect = document.getElementById('dmShowEntries');
    var dmCheckAll   = document.getElementById('dmCheckAll');
    var dmSelectedInfo = document.getElementById('dmSelectedInfo');
    var dmPagePrev   = document.getElementById('dmPagePrev');
    var dmPageNext   = document.getElementById('dmPageNext');
    var dmPageInfo   = document.getElementById('dmPageInfo');

    var dmCurrentPage = 1;
    var dmCheckedIds  = {};

    function dmPageSize() {
        var v = dmShowSelect ? dmShowSelect.value : '25';
        return v === 'all' ? (dmBodyRows.length || 1) : parseInt(v, 10);
    }

    function dmTotalPages() {
        return Math.max(1, Math.ceil(dmBodyRows.length / dmPageSize()));
    }

    function dmRenderPage() {
        var size = dmPageSize();
        var totalPages = dmTotalPages();
        if (dmCurrentPage > totalPages) { dmCurrentPage = totalPages; }
        if (dmCurrentPage < 1) { dmCurrentPage = 1; }

        var start = (dmCurrentPage - 1) * size;
        var end = start + size;

        dmBodyRows.forEach(function (tr, idx) {
            var visible = idx >= start && idx < end;
            tr.classList.toggle('dm-row-hidden', !visible);
        });

        if (dmPageInfo) { dmPageInfo.textContent = 'Hal ' + dmCurrentPage + ' / ' + totalPages; }
        if (dmPagePrev) { dmPagePrev.disabled = (dmCurrentPage <= 1); }
        if (dmPageNext) { dmPageNext.disabled = (dmCurrentPage >= totalPages); }

        dmUpdateCheckAllState();
    }

    function dmUpdateCheckAllState() {
        if (!dmCheckAll) { return; }
        var visible = dmBodyRows.filter(function (tr) { return !tr.classList.contains('dm-row-hidden'); });
        dmCheckAll.checked = visible.length > 0 && visible.every(function (tr) {
            return !!dmCheckedIds[tr.dataset.id];
        });
    }

    function dmUpdateTotals() {
        var checkedRows = dmBodyRows.filter(function (tr) { return dmCheckedIds[tr.dataset.id]; });

        var elP = document.getElementById('dmTotalPelanggan');
        var elM = document.getElementById('dmTotalM3');
        var elR = document.getElementById('dmTotalRekening');
        var lbl1 = document.getElementById('dmTotalLabel1');
        var lbl2 = document.getElementById('dmTotalLabel2');
        var lbl3 = document.getElementById('dmTotalLabel3');

        if (checkedRows.length === 0) {
            var tfootEl = document.querySelector('.dm-tfoot');
            var all = tfootEl ? {
                totalPelanggan: parseFloat(tfootEl.dataset.totalPelanggan) || 0,
                totalM3: parseFloat(tfootEl.dataset.totalM3) || 0,
                totalRekening: parseFloat(tfootEl.dataset.totalRekening) || 0
            } : { totalPelanggan: 0, totalM3: 0, totalRekening: 0 };
            if (elP) { elP.textContent = all.totalPelanggan; }
            if (elM) { elM.textContent = all.totalM3; }
            if (elR) { elR.textContent = 'Rp ' + formatRupiah(all.totalRekening); }
            if (lbl1) { lbl1.textContent = 'Total Pelanggan'; }
            if (lbl2) { lbl2.textContent = 'Total Kubikasi M³'; }
            if (lbl3) { lbl3.textContent = 'Total Tagihan Rekening'; }
            if (dmSelectedInfo) { dmSelectedInfo.textContent = ''; }
            return;
        }

        var sumM3 = 0;
        var sumRekening = 0;
        checkedRows.forEach(function (tr) {
            sumM3 += parseFloat(tr.dataset.pakai) || 0;
            sumRekening += parseFloat(tr.dataset.total) || 0;
        });

        if (elP) { elP.textContent = checkedRows.length; }
        if (elM) { elM.textContent = sumM3; }
        if (elR) { elR.textContent = 'Rp ' + formatRupiah(sumRekening); }
        if (lbl1) { lbl1.textContent = 'Pelanggan Terpilih'; }
        if (lbl2) { lbl2.textContent = 'Kubikasi M³ Terpilih'; }
        if (lbl3) { lbl3.textContent = 'Tagihan Rekening Terpilih'; }
        if (dmSelectedInfo) { dmSelectedInfo.textContent = checkedRows.length + ' baris dicentang'; }
    }

    if (dmShowSelect) {
        dmShowSelect.addEventListener('change', function () {
            dmCurrentPage = 1;
            dmRenderPage();
        });
    }
    if (dmPagePrev) {
        dmPagePrev.addEventListener('click', function () { dmCurrentPage--; dmRenderPage(); });
    }
    if (dmPageNext) {
        dmPageNext.addEventListener('click', function () { dmCurrentPage++; dmRenderPage(); });
    }
    if (dmCheckAll) {
        dmCheckAll.addEventListener('change', function () {
            var visible = dmBodyRows.filter(function (tr) { return !tr.classList.contains('dm-row-hidden'); });
            visible.forEach(function (tr) {
                dmCheckedIds[tr.dataset.id] = dmCheckAll.checked;
                var chk = tr.querySelector('.dm-rowchk');
                if (chk) { chk.checked = dmCheckAll.checked; }
            });
            dmUpdateTotals();
        });
    }
    document.querySelectorAll('.dm-rowchk').forEach(function (chk) {
        chk.addEventListener('change', function () {
            dmCheckedIds[chk.dataset.id] = chk.checked;
            dmUpdateCheckAllState();
            dmUpdateTotals();
        });
    });

    if (dmBodyRows.length > 0) {
        dmRenderPage();
        dmUpdateTotals();
    }

    function initMasterTable(root) {
        var table = root.querySelector('table');
        if (!table) { return; }

        var tbody = table.querySelector('tbody');
        var allRows = Array.prototype.slice.call(tbody.querySelectorAll('tr:not(.empty-row)'));
        if (allRows.length === 0) { return; }

        var select   = root.querySelector('.master-pagesize');
        var pageInfo = root.querySelector('.master-page-info');
        var btnPrev  = root.querySelector('.master-page-prev');
        var btnNext  = root.querySelector('.master-page-next');
        if (!select) { return; }

        var currentPage = 1;

        function getPageSize() {
            return select.value === 'all' ? allRows.length : parseInt(select.value, 10);
        }

        function render() {
            var pageSize   = getPageSize();
            var totalPages = Math.max(1, Math.ceil(allRows.length / pageSize));
            if (currentPage > totalPages) { currentPage = totalPages; }

            var start = (currentPage - 1) * pageSize;
            var end   = start + pageSize;

            allRows.forEach(function (tr, i) {
                tr.style.display = (i >= start && i < end) ? '' : 'none';
            });

            if (pageInfo) {
                pageInfo.textContent = 'Hal ' + currentPage + ' / ' + totalPages + ' (' + allRows.length + ' entri)';
            }
            if (btnPrev) { btnPrev.disabled = currentPage <= 1; }
            if (btnNext) { btnNext.disabled = currentPage >= totalPages; }
        }

        select.addEventListener('change', function () {
            currentPage = 1;
            render();
        });
        if (btnPrev) {
            btnPrev.addEventListener('click', function () {
                if (currentPage > 1) { currentPage--; render(); }
            });
        }
        if (btnNext) {
            btnNext.addEventListener('click', function () {
                var totalPages = Math.max(1, Math.ceil(allRows.length / getPageSize()));
                if (currentPage < totalPages) { currentPage++; render(); }
            });
        }

        render();
    }

    document.querySelectorAll('.master-card[data-paginate]').forEach(function (root) {
        initMasterTable(root);
    });
});
document.addEventListener('DOMContentLoaded', function () {
    var moreBtn = document.getElementById('topbarMoreBtn');
    var moreList = document.getElementById('topbarMoreList');
    if (!moreBtn || !moreList) { return; }

    moreBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        moreList.classList.toggle('show');
    });
    document.addEventListener('click', function (e) {
        if (!moreList.contains(e.target) && e.target !== moreBtn) {
            moreList.classList.remove('show');
        }
    });
});