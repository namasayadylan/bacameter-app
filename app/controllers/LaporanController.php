<?php

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use Dompdf\Dompdf;
use Dompdf\Options;
use OpenSpout\Writer\XLSX\Writer as XlsxStreamWriter;
use OpenSpout\Writer\XLSX\Options as XlsxStreamOptions;
use OpenSpout\Common\Entity\Cell as StreamCell;
use OpenSpout\Common\Entity\Row as StreamRow;
use OpenSpout\Common\Entity\Style\Style as StreamStyle;

/**
 * LaporanController — Soal Laporan Bacameter (lanjutan Brief Task).
 *
 * 3 laporan (Soal 1/2/3), semua: preview INLINE di halaman /laporan (form di
 * atas, hasil di kartu bawahnya -- sesuai mockup), + export PDF & Excel.
 * Query & total SELALU dihitung sekali lewat getReport1Data()/2/3 lalu
 * dipakai bareng oleh ketiga output (web/PDF/Excel) -- supaya angkanya
 * DIJAMIN sama persis di ketiganya.
 */
class LaporanController extends ControllerBase
{
    private const PERIODE_AKTIF = '202607';

    private const JENIS_LABEL = [
        1 => 'Rekap Baca Meter ',
        2 => 'Rekap per Petugas',
        3 => 'Rekap per Anomali / Kendala',
    ];

    private const KOP_NAMA   = 'PT AURORA TEKNO GLOBAL';
    private const KOP_KONTAK = 'Telp (022) 86062862  ·  info@aurorateknoglobal.com';

    private const BULAN = [
        '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
        '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
        '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember',
    ];

    
    public function indexAction()
    {
        $jenis = (int) $this->request->getQuery('jenis', 'int', 0);
        $page  = max(1, (int) $this->request->getQuery('page', 'int', 1));

        $bulanDefault = substr(self::PERIODE_AKTIF, 4, 2);
        $tahunDefault = substr(self::PERIODE_AKTIF, 0, 4);

        $periodeInput = trim((string) $this->request->getQuery('periode', 'string', ''));
        if ($periodeInput !== '' && preg_match('/^(\d{4})-(\d{2})$/', $periodeInput, $m)) {
            $tahun = $m[1];
            $bulan = $m[2];
        } else {
            $tahun = $tahunDefault;
            $bulan = $bulanDefault;
        }

        if (!isset(self::BULAN[$bulan])) {
            $bulan = $bulanDefault;
        }
        if (!preg_match('/^\d{4}$/', $tahun)) {
            $tahun = $tahunDefault;
        }

        $periode = $tahun . $bulan;

        $tahunSekarang = (int) date('Y');
        $tahunList = range($tahunSekarang + 1, $tahunSekarang - 3);

        $this->view->setVar('activeMenu', 'laporan');
        $this->view->setVar('pageTitle', 'Laporan');
        $this->view->setVar('periode', $periode);
        $this->view->setVar('bulan', $bulan);
        $this->view->setVar('tahun', $tahun);
        $this->view->setVar('periodeInputValue', $tahun . '-' . $bulan);
        $this->view->setVar('bulanList', self::BULAN);
        $this->view->setVar('tahunList', $tahunList);
        $this->view->setVar('jenisList', self::JENIS_LABEL);
        $this->view->setVar('jenisSelected', $jenis);

        if ($jenis > 0 && isset(self::JENIS_LABEL[$jenis])) {
            $this->view->setVar('jenis', $jenis);
            $this->view->setVar('periodeLabel', $this->formatPeriodeLabel($periode));

            if ($jenis === 1) {
                $pageSize = 50;
                $report = $this->getReport1Data($periode, $page, $pageSize);

                $this->view->setVar('page', $page);
                $this->view->setVar('pageSize', $pageSize);
                $this->view->setVar('totalPages', (int) ceil(max(1, $report['total_keseluruhan']) / $pageSize));
            } else {
                $report = $this->buildReportData($jenis, $periode);
            }

            $this->view->setVar('report', $report);
        }
    }

    public function previewAction()
    {
        $jenis   = (int) $this->request->getQuery('jenis', 'int', 1);
        $periode = trim((string) $this->request->getQuery('periode', 'string', self::PERIODE_AKTIF));
        if ($periode === '') {
            $periode = self::PERIODE_AKTIF;
        }
        if (!isset(self::JENIS_LABEL[$jenis])) {
            $jenis = 1;
        }

        $this->view->disableLevel(\Phalcon\Mvc\View::LEVEL_LAYOUT);

        $this->view->setVar('forPdf', false);
        $this->view->setVar('jenis', $jenis);
        $this->view->setVar('periode', $periode);
        $this->view->setVar('kopNama', self::KOP_NAMA);
        $this->view->setVar('kopKontak', self::KOP_KONTAK);
        $this->view->setVar('periodeLabel', $this->formatPeriodeLabel($periode));
        $this->view->setVar('report', $this->buildReportData($jenis, $periode));

        $this->view->pick('laporan/print');
    }

    /** Ambang batas baris aman untuk PDF -- di atas ini, generate PDF jadi terlalu berat/berhalaman ribuan. */
    private const PDF_MAX_ROWS_REPORT1 = 5000;

    public function exportPdfAction()
    {
        $jenis   = (int) $this->request->getQuery('jenis', 'int', 1);
        $periode = trim((string) $this->request->getQuery('periode', 'string', self::PERIODE_AKTIF));
        if ($periode === '') {
            $periode = self::PERIODE_AKTIF;
        }
        if (!isset(self::JENIS_LABEL[$jenis])) {
            $jenis = 1;
        }

        if ($jenis === 1) {
            $totals = $this->getReport1Totals($periode);
            if ($totals['jumlah'] > self::PDF_MAX_ROWS_REPORT1) {
                $this->view->disable();
                $this->response->setStatusCode(422, 'Unprocessable Entity');
                $this->response->setContentType('text/plain', 'UTF-8');
                $this->response->setContent(
                    "Export PDF ditolak: periode {$periode} punya {$totals['jumlah']} baris "
                    . '(maksimal ' . self::PDF_MAX_ROWS_REPORT1 . ' untuk PDF). '
                    . 'Silakan pakai Export Excel untuk data sebanyak ini, '
                    . 'atau persempit periode/filter dulu sebelum export PDF.'
                );
                return $this->response;
            }
        }

        $data = $this->buildReportData($jenis, $periode);

        $this->view->setVars([
            'forPdf'       => true,
            'jenis'        => $jenis,
            'periode'      => $periode,
            'kopNama'      => self::KOP_NAMA,
            'kopKontak'    => self::KOP_KONTAK,
            'periodeLabel' => $this->formatPeriodeLabel($periode),
            'report'       => $data,
        ]);
        $html = $this->view->getRender('laporan', 'print', [], function ($view) {
            $view->setRenderLevel(\Phalcon\Mvc\View::LEVEL_ACTION_VIEW);
        });

        $options = new Options();
        $options->set('isRemoteEnabled', false);
        $options->set('defaultFont', 'DejaVu Sans');

        $dompdf = new Dompdf($options);
        $dompdf->loadHtml($html);
        $dompdf->setPaper('A4', $jenis === 1 ? 'landscape' : 'portrait');
        $dompdf->render();

        $filename = 'Laporan_' . $jenis . '_' . $this->slug(self::JENIS_LABEL[$jenis]) . '_' . $periode . '.pdf';

        $this->view->disable();
        $this->response->setContentType('application/pdf');
        $this->response->setHeader('Content-Disposition', 'inline; filename="' . $filename . '"');
        $this->response->setContent($dompdf->output());

        return $this->response;
    }

    public function exportExcelAction()
    {
        $jenis   = (int) $this->request->getQuery('jenis', 'int', 1);
        $periode = trim((string) $this->request->getQuery('periode', 'string', self::PERIODE_AKTIF));
        if ($periode === '') {
            $periode = self::PERIODE_AKTIF;
        }
        if (!isset(self::JENIS_LABEL[$jenis])) {
            $jenis = 1;
        }

        $this->view->disable();

        if ($jenis === 1) {
            $this->streamExcelReport1($periode);
            return;                   
        }

        $spreadsheet = match ($jenis) {
            2 => $this->buildExcelReport2($this->buildReportData($jenis, $periode), $periode),
            3 => $this->buildExcelReport3($this->buildReportData($jenis, $periode), $periode),
        };

        $filename = 'Laporan_' . $jenis . '_' . $this->slug(self::JENIS_LABEL[$jenis]) . '_' . $periode . '.xlsx';

        $this->response->setContentType(
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        );
        $this->response->setHeader('Content-Disposition', 'attachment; filename="' . $filename . '"');
        $this->response->setHeader('Cache-Control', 'max-age=0');

        ob_start();
        $writer = new Xlsx($spreadsheet);
        $writer->save('php://output');
        $excelBinary = ob_get_clean();

        $this->response->setContent($excelBinary);
        return $this->response;
    }

    /** Ukuran 1 batch baca dari database untuk export Excel Soal 1. */
    private const EXCEL_CHUNK_SIZE = 5000;

    /**
     * Export Excel Soal 1 -- STREAMING MURNI ke output, untuk data besar
     * (~99.505 baris & bisa terus bertambah).
     *
     * Kenapa tidak pakai PhpSpreadsheet (Spreadsheet + Writer\Xlsx) seperti
     * Soal 2/3: PhpSpreadsheet SELALU membangun seluruh workbook sebagai
     * objek di memori PHP dulu -- proses tulis-ke-file baru terjadi SEKALI
     * di akhir lewat $writer->save(). Jadi walau baca datanya di-chunk per
     * batch dari DB, objek Spreadsheet-nya tetap menampung SEMUA ~99 ribu
     * baris sekaligus sebelum file jadi -- ini yang bikin boros RAM & lama.
     *
     * openspout/openspout beda: addRow() menulis LANGSUNG ke file/stream
     * XLSX saat itu juga, baris demi baris -- tidak pernah menahan seluruh
     * sheet di memori. Konsekuensinya: openspout TIDAK mendukung rumus
     * Excel (=SUM(), =F-E, dst) -- makanya di sini nilai Pakai & Total
     * Rekening dihitung langsung di PHP (murah, cuma tambah/kurang), dan
     * baris TOTAL pakai angka dari getReport1Totals() (query SUM/COUNT
     * terpisah di database) -- bukan rumus Excel.
     *
     * Alur memori per batch (loop while):
     *   1. Tarik $EXCEL_CHUNK_SIZE baris dari DB (OFFSET/FETCH, terurut
     *      kolom d.id yang sudah terindex sebagai PK -- aman dari data
     *      terlewat/dobel walau di-loop banyak kali, selama tidak ada
     *      insert/delete di tabel ini saat proses export berjalan).
     *   2. Tiap baris langsung $writer->addRow() -- OpenSpout langsung
     *      flush ke stream output, bukan disimpan di array PHP.
     *   3. unset($chunk) + gc_collect_cycles() sebelum baca batch berikutnya.
     *
     * set_time_limit(0): mematikan batas waktu eksekusi PHP KHUSUS untuk
     * request ini saja (bukan global/permanen ke seluruh aplikasi), supaya
     * tidak muncul "Maximum execution time exceeded" walau prosesnya lama.
     * Catatan: kalau server pakai reverse proxy (Nginx/IIS) di depan PHP,
     * proxy itu punya batas timeout SENDIRI yang terpisah dari PHP dan
     * TIDAK kena pengaruh set_time_limit() ini -- perlu dinaikkan juga di
     * konfigurasi proxy-nya kalau proses export ternyata masih terlalu
     * lama (import: dengan streaming murni begini, 99 ribuan baris
     * normalnya selesai dalam hitungan detik, bukan menit -- jadi kasus
     * itu semestinya jarang kejadian).
     */
    /**
     * Export Excel Soal 1 menggunakan OpenSpout.
     *
     * Data ditulis secara streaming agar puluhan ribu baris tidak
     * ditampung sebagai objek Spreadsheet di memory PHP.
     */
    private function streamExcelReport1(string $periode): void
    {
        set_time_limit(0);
        ini_set('memory_limit', '256M');

        $totals = $this->getReport1Totals($periode);
        $filename = 'Laporan_1_' . $this->slug('Rekap Baca Meter') . '_' . $periode . '.xlsx';

        $options = new XlsxStreamOptions();
        $writer = new XlsxStreamWriter($options);
        $writer->openToBrowser($filename);

        $boldStyle = (new StreamStyle())
            ->withFontBold(true);

        $headerStyle = (new StreamStyle())
            ->withFontBold(true)
            ->withBackgroundColor('E3E8EF');

        $italicStyle = (new StreamStyle())
            ->withFontItalic(true)
            ->withFontSize(8);

        $this->addStyledStreamRow(
            $writer,
            [self::KOP_NAMA],
            $boldStyle
        );

        $this->addStyledStreamRow(
            $writer,
            [self::KOP_KONTAK],
            $italicStyle
        );

        $writer->addRow(
            StreamRow::fromValues([''])
        );

        $this->addStyledStreamRow(
            $writer,
            ['LAPORAN REKAP BACA METER'],
            $boldStyle
        );

        $writer->addRow(
            StreamRow::fromValues([
                'Periode ' . $this->formatPeriodeLabel($periode)
                . '  ·  Total ' . number_format($totals['jumlah'], 0, ',', '.') . ' pelanggan',
            ])
        );

        $writer->addRow(
            StreamRow::fromValues([''])
        );

        $this->addStyledStreamRow(
            $writer,
            [
                'No',
                'No Pelanggan',
                'Nama',
                'Alamat',
                'St. Awal',
                'St. Akhir',
                'Pakai (M3)',
                'Kendala',
                'Harga Air',
                'Admin',
                'Total Rekening',
            ],
            $headerStyle
        );

        $sql = "SELECT d.nomor_pelanggan, d.nama, d.alamat,
                       d.stand_awal, d.stand_akhir,
                       LTRIM(RTRIM(c.kode)) AS kode_anomali,
                       c.nama AS nama_anomali,
                       d.harga_air, d.biaya_admin
                FROM bacameter.datameter d
                LEFT JOIN bacameter.cater_alasan c ON c.id = d.id_anomali
                WHERE d.periode = :periode
                ORDER BY d.id ASC
                OFFSET :offset ROWS FETCH NEXT :pagesize ROWS ONLY";

        $stmt = $this->db->prepare($sql);

        $no = 1;
        $offset = 0;

        while (true) {
            $stmt->bindValue(':periode', $periode, \PDO::PARAM_STR);
            $stmt->bindValue(':offset', $offset, \PDO::PARAM_INT);
            $stmt->bindValue(':pagesize', self::EXCEL_CHUNK_SIZE, \PDO::PARAM_INT);
            $stmt->execute();

            $chunk = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            if (count($chunk) === 0) {
                break;
            }

            foreach ($chunk as $row) {
                $standAwal = (int) $row['stand_awal'];
                $standAkhir = (int) $row['stand_akhir'];
                $hargaAir = (float) $row['harga_air'];
                $biayaAdmin = (float) $row['biaya_admin'];

                $writer->addRow(
                    StreamRow::fromValues([
                        $no++,
                        (string) $row['nomor_pelanggan'],
                        $row['nama'],
                        $row['alamat'],
                        $standAwal,
                        $standAkhir,
                        $standAkhir - $standAwal,
                        trim((string) $row['kode_anomali']) . ' · ' . $row['nama_anomali'],
                        $hargaAir,
                        $biayaAdmin,
                        $hargaAir + $biayaAdmin,
                    ])
                );
            }

            $offset += self::EXCEL_CHUNK_SIZE;

            unset($chunk);
            gc_collect_cycles();
        }

        $this->addStyledStreamRow(
            $writer,
            [
                'TOTAL',
                '',
                '',
                '',
                '',
                '',
                $totals['pakai'],
                '',
                $totals['harga_air'],
                $totals['biaya_admin'],
                $totals['total_rekening'],
            ],
            $boldStyle
        );

        $writer->addRow(
            StreamRow::fromValues([])
        );

        $this->addStyledStreamRow(
            $writer,
            [
                'Catatan: Pakai (M3) = St. Akhir - St. Awal; '
                . 'Total Rekening = Harga Air + Admin.',
            ],
            $italicStyle
        );

        $writer->close();

        exit;
    }

    /**
     * Menambahkan satu row dengan style ke OpenSpout 5.x.
     *
     * Pada OpenSpout 5.x style diterapkan pada Cell, bukan dikirim
     * sebagai argumen kedua Row::fromValues().
     */
    private function addStyledStreamRow(
        XlsxStreamWriter $writer,
        array $values,
        StreamStyle $style
    ): void {
        $cells = [];

        foreach ($values as $value) {
            $cells[] = StreamCell::fromValue($value, $style);
        }

        $writer->addRow(
            new StreamRow($cells)
        );
    }

    private function buildReportData(int $jenis, string $periode): array
    {
        return match ($jenis) {
            1 => $this->getReport1Data($periode),
            2 => $this->getReport2Data($periode),
            3 => $this->getReport3Data($periode),
        };
    }

    /**
     * Soal 1 -- Rekap Baca Meter per Periode (per pelanggan).
     *
     * $page/$pageSize null = ambil SEMUA baris (dipakai export Excel/PDF
     * lewat jalur chunked tersendiri, BUKAN lewat method ini untuk Excel --
     * lihat exportExcelReport1Streaming()).
     *
     * PENTING: totals SELALU dihitung lewat query agregat terpisah
     * (SUM/COUNT langsung di database), BUKAN dari array $rows yang
     * sedang ditampilkan -- supaya footer TOTAL tetap benar (mewakili
     * SELURUH data periode ini) walau yang ditampilkan cuma 1 halaman.
     */
    private function getReport1Data(string $periode, ?int $page = null, ?int $pageSize = null): array
    {
        $totals = $this->getReport1Totals($periode);

        $sql = "SELECT d.nomor_pelanggan, d.nama, d.alamat,
                       d.stand_awal, d.stand_akhir,
                       (d.stand_akhir - d.stand_awal) AS pakai,
                       LTRIM(RTRIM(c.kode)) AS kode_anomali, c.nama AS nama_anomali,
                       d.harga_air, d.biaya_admin,
                       (d.harga_air + d.biaya_admin) AS total_rekening,
                       p.nama AS nama_petugas
                FROM bacameter.datameter d
                LEFT JOIN bacameter.petugas p ON p.id = d.id_petugas
                LEFT JOIN bacameter.cater_alasan c ON c.id = d.id_anomali
                WHERE d.periode = :periode
                ORDER BY d.id ASC";

        $bind = ['periode' => $periode];
        $nomorAwal = 1;

        if ($page !== null && $pageSize !== null) {
            $offset = ($page - 1) * $pageSize;
            $sql .= " OFFSET :offset ROWS FETCH NEXT :pagesize ROWS ONLY";
            $bind['offset']   = $offset;
            $bind['pagesize'] = $pageSize;
            $nomorAwal = $offset + 1;
        }

        $stmt = $this->db->prepare($sql);
        foreach ($bind as $key => $val) {
            $type = is_int($val) ? \PDO::PARAM_INT : \PDO::PARAM_STR;
            $stmt->bindValue(':' . $key, $val, $type);
        }
        $stmt->execute();
        $raw = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        $rows = [];
        $no = $nomorAwal;

        foreach ($raw as $r) {
            $rows[] = [
                'no'              => $no++,
                'nomor_pelanggan' => $r['nomor_pelanggan'],
                'nama'            => $r['nama'],
                'alamat'          => $r['alamat'],
                'stand_awal'      => (int) $r['stand_awal'],
                'stand_akhir'     => (int) $r['stand_akhir'],
                'pakai'           => (int) $r['pakai'],
                'kendala'         => trim((string) $r['kode_anomali']) . ' · ' . $r['nama_anomali'],
                'harga_air'       => (float) $r['harga_air'],
                'biaya_admin'     => (float) $r['biaya_admin'],
                'total_rekening'  => (float) $r['total_rekening'],
                'nama_petugas'    => $r['nama_petugas'],
            ];
        }

        return [
            'judul'              => 'Rekap Baca Meter',
            'sub'                => 'Total ' . number_format($totals['jumlah'], 0, ',', '.') . ' pelanggan',
            'rows'               => $rows,
            'jumlah_baris'       => count($rows),
            'total_keseluruhan'  => $totals['jumlah'],
            'totals'             => [
                'pakai'          => $totals['pakai'],
                'harga_air'      => $totals['harga_air'],
                'biaya_admin'    => $totals['biaya_admin'],
                'total_rekening' => $totals['total_rekening'],
            ],
        ];
    }

    /**
     * Agregat TOTAL utuh untuk Soal 1 -- 1 query ringan (SUM/COUNT di sisi
     * database), TIDAK PERNAH menarik seluruh baris ke PHP. Dipakai baik
     * oleh tampilan web (footer TOTAL tetap benar walau lagi di halaman
     * manapun) maupun export.
     */
    private function getReport1Totals(string $periode): array
    {
        $sql = "SELECT
                    COUNT(*) AS jumlah,
                    SUM(d.stand_akhir - d.stand_awal) AS total_pakai,
                    SUM(d.harga_air) AS total_harga_air,
                    SUM(d.biaya_admin) AS total_admin,
                    SUM(d.harga_air + d.biaya_admin) AS total_rekening
                FROM bacameter.datameter d
                WHERE d.periode = :periode";

        $stmt = $this->db->prepare($sql);
        $stmt->execute(['periode' => $periode]);
        $row = $stmt->fetch(\PDO::FETCH_ASSOC);

        return [
            'jumlah'         => (int) ($row['jumlah'] ?? 0),
            'pakai'          => (int) ($row['total_pakai'] ?? 0),
            'harga_air'      => (float) ($row['total_harga_air'] ?? 0),
            'biaya_admin'    => (float) ($row['total_admin'] ?? 0),
            'total_rekening' => (float) ($row['total_rekening'] ?? 0),
        ];
    }

    /** Soal 2 -- Rekap per Petugas (agregat, GROUP BY id_petugas). */
    private function getReport2Data(string $periode): array
    {
        $sql = "SELECT p.nama AS nama_petugas,
                       COUNT(*) AS jml_pelanggan,
                       SUM(d.pakai) AS total_m3,
                       SUM(d.pakai) * 1.0 / COUNT(*) AS rata_m3,
                       SUM(d.harga_air + d.biaya_admin) AS total_rekening
                FROM bacameter.datameter d
                LEFT JOIN bacameter.petugas p ON p.id = d.id_petugas
                WHERE d.periode = :periode
                GROUP BY d.id_petugas, p.nama
                ORDER BY p.nama ASC";

        $stmt = $this->db->prepare($sql);
        $stmt->execute(['periode' => $periode]);
        $raw = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        $rows = [];
        $totalPelanggan = 0;
        $totalM3 = 0;
        $totalRekening = 0.0;

        foreach ($raw as $r) {
            $rows[] = [
                'nama_petugas'   => $r['nama_petugas'],
                'jml_pelanggan'  => (int) $r['jml_pelanggan'],
                'total_m3'       => (int) $r['total_m3'],
                'rata_m3'        => (float) $r['rata_m3'],
                'total_rekening' => (float) $r['total_rekening'],
            ];
            $totalPelanggan += (int) $r['jml_pelanggan'];
            $totalM3        += (int) $r['total_m3'];
            $totalRekening  += (float) $r['total_rekening'];
        }

        return [
            'judul'        => 'Rekap per Petugas',
            'sub'          => 'Agregat per petugas pencatat',
            'rows'         => $rows,
            'jumlah_baris' => count($rows),
            'totals'       => [
                'jml_pelanggan'  => $totalPelanggan,
                'total_m3'       => $totalM3,
                'total_rekening' => $totalRekening,
            ],
        ];
    }

    /** Soal 3 -- Rekap per Anomali/Kendala (agregat, GROUP BY id_anomali). */
    private function getReport3Data(string $periode): array
    {
        $sql = "SELECT LTRIM(RTRIM(c.kode)) AS kode, c.nama AS nama_kendala,
                       COUNT(*) AS jml_pelanggan,
                       SUM(d.pakai) AS total_m3,
                       SUM(d.harga_air + d.biaya_admin) AS total_rekening
                FROM bacameter.datameter d
                LEFT JOIN bacameter.cater_alasan c ON c.id = d.id_anomali
                WHERE d.periode = :periode
                GROUP BY d.id_anomali, c.kode, c.nama
                ORDER BY c.kode ASC";

        $stmt = $this->db->prepare($sql);
        $stmt->execute(['periode' => $periode]);
        $raw = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        $rows = [];
        $totalPelanggan = 0;
        $totalM3 = 0;
        $totalRekening = 0.0;

        foreach ($raw as $r) {
            $rows[] = [
                'kode'           => $r['kode'],
                'nama_kendala'   => $r['nama_kendala'],
                'jml_pelanggan'  => (int) $r['jml_pelanggan'],
                'total_m3'       => (int) $r['total_m3'],
                'total_rekening' => (float) $r['total_rekening'],
            ];
            $totalPelanggan += (int) $r['jml_pelanggan'];
            $totalM3        += (int) $r['total_m3'];
            $totalRekening  += (float) $r['total_rekening'];
        }

        return [
            'judul'        => 'Rekap Anomali / Kendala',
            'sub'          => 'Agregat per jenis kendala baca meter',
            'rows'         => $rows,
            'jumlah_baris' => count($rows),
            'totals'       => [
                'jml_pelanggan'  => $totalPelanggan,
                'total_m3'       => $totalM3,
                'total_rekening' => $totalRekening,
            ],
        ];
    }

    private function newSpreadsheetWithKop(string $judul, string $periode, string $sub): array
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle(substr($judul, 0, 31));

        $sheet->setCellValue('A1', self::KOP_NAMA);
        $sheet->getStyle('A1')->getFont()->setBold(true)->setSize(13);
        $sheet->setCellValue('A2', self::KOP_KONTAK);
        $sheet->getStyle('A2')->getFont()->setSize(9)->setItalic(true);

        $sheet->setCellValue('A4', 'LAPORAN ' . mb_strtoupper($judul));
        $sheet->getStyle('A4')->getFont()->setBold(true)->setSize(12);
        $sheet->setCellValue('A5', 'Periode ' . $this->formatPeriodeLabel($periode) . '  ·  ' . $sub);
        $sheet->getStyle('A5')->getFont()->setSize(10);

        return [$spreadsheet, $sheet];
    }


    private function buildExcelReport2(array $data, string $periode): Spreadsheet
    {
        [$spreadsheet, $sheet] = $this->newSpreadsheetWithKop($data['judul'], $periode, $data['sub']);

        $headers = ['Petugas', 'Jumlah Pelanggan', 'Total Pakai (M3)', 'Rata-rata Pakai (M3)', 'Total Rekening'];
        $headerRow = 7;
        $sheet->fromArray($headers, null, 'A' . $headerRow);
        $sheet->getStyle('A' . $headerRow . ':E' . $headerRow)->getFont()->setBold(true);
        $sheet->getStyle('A' . $headerRow . ':E' . $headerRow)->getFill()
            ->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('E3E8EF');

        $r = $headerRow + 1;
        foreach ($data['rows'] as $row) {
            $sheet->setCellValue("A{$r}", $row['nama_petugas']);
            $sheet->setCellValue("B{$r}", $row['jml_pelanggan']);
            $sheet->setCellValue("C{$r}", $row['total_m3']);
            $sheet->setCellValue("D{$r}", "=C{$r}/B{$r}");
            $sheet->setCellValue("E{$r}", $row['total_rekening']);
            $r++;
        }
        $lastDataRow = $r - 1;

        $totalRow = $r;
        $sheet->setCellValue("A{$totalRow}", 'TOTAL');
        $sheet->setCellValue("B{$totalRow}", "=SUM(B" . ($headerRow + 1) . ":B{$lastDataRow})");
        $sheet->setCellValue("C{$totalRow}", "=SUM(C" . ($headerRow + 1) . ":C{$lastDataRow})");
        $sheet->setCellValue("D{$totalRow}", "=C{$totalRow}/B{$totalRow}");
        $sheet->setCellValue("E{$totalRow}", "=SUM(E" . ($headerRow + 1) . ":E{$lastDataRow})");
        $sheet->getStyle("A{$totalRow}:E{$totalRow}")->getFont()->setBold(true);

        $sheet->getStyle('D' . ($headerRow + 1) . ":D{$totalRow}")->getNumberFormat()->setFormatCode('0.0');
        $sheet->getStyle('E' . ($headerRow + 1) . ":E{$totalRow}")->getNumberFormat()->setFormatCode('#,##0');

        foreach (['A' => 22, 'B' => 16, 'C' => 16, 'D' => 18, 'E' => 16] as $col => $width) {
            $sheet->getColumnDimension($col)->setWidth($width);
        }

        return $spreadsheet;
    }

    private function buildExcelReport3(array $data, string $periode): Spreadsheet
    {
        [$spreadsheet, $sheet] = $this->newSpreadsheetWithKop($data['judul'], $periode, $data['sub']);

        $headers = ['Kode', 'Nama Kendala', 'Jumlah Pelanggan', 'Total Pakai (M3)', 'Total Rekening'];
        $headerRow = 7;
        $sheet->fromArray($headers, null, 'A' . $headerRow);
        $sheet->getStyle('A' . $headerRow . ':E' . $headerRow)->getFont()->setBold(true);
        $sheet->getStyle('A' . $headerRow . ':E' . $headerRow)->getFill()
            ->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('E3E8EF');

        $r = $headerRow + 1;
        foreach ($data['rows'] as $row) {
            $sheet->setCellValueExplicit("A{$r}", $row['kode'], \PhpOffice\PhpSpreadsheet\Cell\DataType::TYPE_STRING);
            $sheet->setCellValue("B{$r}", $row['nama_kendala']);
            $sheet->setCellValue("C{$r}", $row['jml_pelanggan']);
            $sheet->setCellValue("D{$r}", $row['total_m3']);
            $sheet->setCellValue("E{$r}", $row['total_rekening']);
            $r++;
        }
        $lastDataRow = $r - 1;

        $totalRow = $r;
        $sheet->setCellValue("B{$totalRow}", 'TOTAL');
        $sheet->setCellValue("C{$totalRow}", "=SUM(C" . ($headerRow + 1) . ":C{$lastDataRow})");
        $sheet->setCellValue("D{$totalRow}", "=SUM(D" . ($headerRow + 1) . ":D{$lastDataRow})");
        $sheet->setCellValue("E{$totalRow}", "=SUM(E" . ($headerRow + 1) . ":E{$lastDataRow})");
        $sheet->getStyle("A{$totalRow}:E{$totalRow}")->getFont()->setBold(true);

        $sheet->getStyle('E' . ($headerRow + 1) . ":E{$totalRow}")->getNumberFormat()->setFormatCode('#,##0');

        foreach (['A' => 10, 'B' => 22, 'C' => 16, 'D' => 16, 'E' => 16] as $col => $width) {
            $sheet->getColumnDimension($col)->setWidth($width);
        }

        return $spreadsheet;
    }

    private function formatPeriodeLabel(string $periode): string
    {
        if (strlen($periode) === 6) {
            $tahun = substr($periode, 0, 4);
            $bulan = substr($periode, 4, 2);
            $namaBulan = self::BULAN[$bulan] ?? $bulan;
            return $periode . ' (' . $namaBulan . ' ' . $tahun . ')';
        }
        return $periode;
    }

    private function slug(string $text): string
    {
        return preg_replace('/[^A-Za-z0-9]+/', '_', $text);
    }
}