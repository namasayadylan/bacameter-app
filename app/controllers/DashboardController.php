<?php

class DashboardController extends ControllerBase
{
    private const PALETTE = [
        '#3d7de0', '#f2c744', '#e0563a', '#5a9e3f', '#8e5ac2',
        '#e0729a', '#2fb5a6', '#c98a3e', '#4c6ef5',
    ];
    private const WARNA_LAINNYA = '#b9b9b9';
    private const MAX_SLICE = 9;

    private const NAMA_BULAN = [
        1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April',
        5 => 'Mei', 6 => 'Juni', 7 => 'Juli', 8 => 'Agustus',
        9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember',
    ];

    public function indexAction()
    {
        $periodeIni  = $this->resolvePeriodeDariFilter();
        $periodeLalu = $this->periodeMundurSatuBulan($periodeIni);

        $agg = $this->fetchRingkasanAgregat($periodeIni, $periodeLalu);

        $this->view->setVar('filterPeriode', [
            'value' => substr($periodeIni, 0, 4) . '-' . substr($periodeIni, 4, 2), 
            'label' => $this->labelPeriode($periodeIni),
            'label_lalu' => $this->labelPeriode($periodeLalu),
        ]);
        $this->view->setVar('kubikasi', $this->buildKubikasiBox($agg));
        $this->view->setVar('drd', $this->buildDrdBox($agg));
        $this->view->setVar('zonaProgress', $this->buildZonaProgress($periodeIni));
        $this->view->setVar('anomaliChart', $this->buildAnomaliChart($periodeIni));
        $this->view->setVar('ringkasan', $this->buildRingkasanBaca($periodeIni));
        $this->view->setVar('grafikHarian', $this->buildGrafikHarian($periodeIni));
    }

   
    private function resolvePeriodeDariFilter(): string
    {
        $raw = $this->request->getQuery('periode', 'string', '');

        if (preg_match('/^(\d{4})-(\d{2})$/', $raw, $m)) {
            return $m[1] . $m[2]; // '2026-07' -> '202607'
        }

        return date('Ym');
    }

    
    private function periodeMundurSatuBulan(string $periodeYm): string
    {
        $dt = \DateTime::createFromFormat('Ymd', $periodeYm . '01');
        $dt->modify('-1 month');

        return $dt->format('Ym');
    }

    private function labelPeriode(string $periodeYm): string
    {
        $tahun = (int) substr($periodeYm, 0, 4);
        $bulan = (int) substr($periodeYm, 4, 2);

        return (self::NAMA_BULAN[$bulan] ?? $bulan) . ' ' . $tahun;
    }

    private function fetchRingkasanAgregat(string $periodeIni, string $periodeLalu): array
    {
        $sql = "SELECT
                    SUM(CASE WHEN d.periode = :ini1 THEN d.pakai ELSE 0 END) AS pakai_bulan_ini,
                    SUM(CASE WHEN d.periode = :ini2 AND d.status_verifikasi1 = 1 THEN d.pakai ELSE 0 END) AS pakai_terverifikasi,
                    SUM(CASE WHEN d.periode = :lalu1 THEN d.pakai ELSE 0 END) AS pakai_bulan_lalu,
                    SUM(CASE WHEN d.periode = :ini3 THEN d.harga_air + d.biaya_admin ELSE 0 END) AS drd_bulan_ini,
                    SUM(CASE WHEN d.periode = :ini4 AND d.status_verifikasi1 = 1 THEN d.harga_air + d.biaya_admin ELSE 0 END) AS drd_terverifikasi,
                    SUM(CASE WHEN d.periode = :lalu2 THEN d.harga_air + d.biaya_admin ELSE 0 END) AS drd_bulan_lalu
                FROM bacameter.datameter d
                WHERE d.periode IN (:ini5, :lalu3)";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'ini1' => $periodeIni, 'ini2' => $periodeIni, 'ini3' => $periodeIni,
            'ini4' => $periodeIni, 'ini5' => $periodeIni,
            'lalu1' => $periodeLalu, 'lalu2' => $periodeLalu, 'lalu3' => $periodeLalu,
        ]);
        $row = $stmt->fetch(\PDO::FETCH_ASSOC);

        return [
            'pakai_bulan_ini'      => (float) ($row['pakai_bulan_ini'] ?? 0),
            'pakai_terverifikasi'  => (float) ($row['pakai_terverifikasi'] ?? 0),
            'pakai_bulan_lalu'     => (float) ($row['pakai_bulan_lalu'] ?? 0),
            'drd_bulan_ini'        => (float) ($row['drd_bulan_ini'] ?? 0),
            'drd_terverifikasi'    => (float) ($row['drd_terverifikasi'] ?? 0),
            'drd_bulan_lalu'       => (float) ($row['drd_bulan_lalu'] ?? 0),
        ];
    }

    private function buildKubikasiBox(array $agg): array
    {
        return [
            'bulan_ini'      => $agg['pakai_bulan_ini'],
            'bulan_lalu'     => $agg['pakai_bulan_lalu'],
            'terverifikasi'  => $agg['pakai_terverifikasi'],
            'pct'            => $this->hitungPersenPerubahan($agg['pakai_bulan_ini'], $agg['pakai_bulan_lalu']),
        ];
    }

    private function buildDrdBox(array $agg): array
    {
        return [
            'bulan_ini'      => $agg['drd_bulan_ini'],
            'bulan_lalu'     => $agg['drd_bulan_lalu'],
            'terverifikasi'  => $agg['drd_terverifikasi'],
            'pct'            => $this->hitungPersenPerubahan($agg['drd_bulan_ini'], $agg['drd_bulan_lalu']),
        ];
    }

    private function hitungPersenPerubahan(float $bulanIni, float $bulanLalu): ?float
    {
        if ($bulanLalu == 0.0) {
            return null;
        }

        return round((($bulanIni - $bulanLalu) / $bulanLalu) * 100, 2);
    }

   
    private function buildZonaProgress(string $periodeIni): array
    {
        $sql = "SELECT
                    z.zona_id,
                    COUNT(d.id) AS total,
                    ISNULL(SUM(CASE WHEN d.status_baca = 1 THEN 1 ELSE 0 END), 0) AS sudah_baca,
                    ISNULL(SUM(CASE WHEN d.status_verifikasi1 = 1 THEN 1 ELSE 0 END), 0) AS terverifikasi
                FROM (SELECT DISTINCT zona_id FROM bacameter.datameter WHERE zona_id IS NOT NULL) z
                LEFT JOIN bacameter.datameter d ON d.zona_id = z.zona_id AND d.periode = :periode
                GROUP BY z.zona_id
                ORDER BY z.zona_id";

        $stmt = $this->db->prepare($sql);
        $stmt->execute(['periode' => $periodeIni]);
        $raw = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        $result = [];
        foreach ($raw as $row) {
            $total = (int) $row['total'];
            $sudahBaca = (int) $row['sudah_baca'];
            $terverifikasi = (int) $row['terverifikasi'];

            $result[] = [
                'label'          => 'Zona ' . $this->angkaRomawi((int) $row['zona_id']),
                'total'          => $total,
                'sudah_baca'     => $sudahBaca,
                'pct_baca'       => $total > 0 ? round(($sudahBaca / $total) * 100, 2) : 0.0,
                'terverifikasi'  => $terverifikasi,
                'pct_verif'      => $total > 0 ? round(($terverifikasi / $total) * 100, 2) : 0.0,
            ];
        }

        return $result;
    }

   
    private function buildRingkasanBaca(string $periodeIni): array
    {
        $sql = "SELECT
                    COUNT(*) AS total,
                    SUM(CASE WHEN d.status_baca = 1 THEN 1 ELSE 0 END) AS sudah_baca,
                    SUM(CASE WHEN d.status_baca <> 1 OR d.status_baca IS NULL THEN 1 ELSE 0 END) AS belum,
                    SUM(CASE WHEN CAST(d.tanggal_catat AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS hari_ini,
                    SUM(CASE WHEN CAST(d.tanggal_catat AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) THEN 1 ELSE 0 END) AS kemarin,
                    SUM(CASE WHEN c.kode IS NOT NULL AND LTRIM(RTRIM(c.kode)) <> '00' THEN 1 ELSE 0 END) AS anomali,
                    SUM(CASE WHEN d.status_verifikasi1 = 1 THEN 1 ELSE 0 END) AS terverifikasi,
                    SUM(CASE WHEN d.status_verifikasi1 <> 1 OR d.status_verifikasi1 IS NULL THEN 1 ELSE 0 END) AS belum_verifikasi
                FROM bacameter.datameter d
                LEFT JOIN bacameter.cater_alasan c ON c.id = d.id_anomali
                WHERE d.periode = :periode";

        $stmt = $this->db->prepare($sql);
        $stmt->execute(['periode' => $periodeIni]);
        $row = $stmt->fetch(\PDO::FETCH_ASSOC);

        $total = (int) ($row['total'] ?? 0);
        $sudahBaca = (int) ($row['sudah_baca'] ?? 0);
        $anomali = (int) ($row['anomali'] ?? 0);
        $terverifikasi = (int) ($row['terverifikasi'] ?? 0);

        $pct = fn (int $bagian) => $total > 0 ? round(($bagian / $total) * 100, 2) : 0.0;

        return [
            'total'              => $total,
            'sudah_baca'         => $sudahBaca,
            'baca_pct'           => $pct($sudahBaca),
            'belum'              => (int) ($row['belum'] ?? 0),
            'hari_ini'           => (int) ($row['hari_ini'] ?? 0),
            'kemarin'            => (int) ($row['kemarin'] ?? 0),
            'anomali'            => $anomali,
            'anomali_pct'        => $pct($anomali),
            'terverifikasi'      => $terverifikasi,
            'terverifikasi_pct'  => $pct($terverifikasi),
            'belum_verifikasi'   => (int) ($row['belum_verifikasi'] ?? 0),
        ];
    }

    private function buildGrafikHarian(string $periodeIni): array
    {
        $tahun = (int) substr($periodeIni, 0, 4);
        $bulan = (int) substr($periodeIni, 4, 2);
        $jumlahHari = (int) (new \DateTime("{$tahun}-{$bulan}-01"))->format('t');

        $sql = "SELECT
                    DAY(d.tanggal_catat) AS tgl,
                    COUNT(*) AS total_tercatat,
                    SUM(CASE WHEN LTRIM(RTRIM(c.kode)) = '00' THEN 1 ELSE 0 END) AS normal,
                    SUM(CASE WHEN c.kode IS NULL OR LTRIM(RTRIM(c.kode)) <> '00' THEN 1 ELSE 0 END) AS abnormal
                FROM bacameter.datameter d
                LEFT JOIN bacameter.cater_alasan c ON c.id = d.id_anomali
                WHERE d.periode = :periode AND d.status_baca = 1 AND d.tanggal_catat IS NOT NULL
                GROUP BY DAY(d.tanggal_catat)
                ORDER BY tgl";

        $stmt = $this->db->prepare($sql);
        $stmt->execute(['periode' => $periodeIni]);
        $raw = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        $perHari = [];
        foreach ($raw as $row) {
            $perHari[(int) $row['tgl']] = [
                'total'    => (int) $row['total_tercatat'],
                'normal'   => (int) $row['normal'],
                'abnormal' => (int) $row['abnormal'],
            ];
        }

        $totals = $normals = $abnormals = [];
        for ($d = 1; $d <= $jumlahHari; $d++) {
            $totals[]    = $perHari[$d]['total'] ?? 0;
            $normals[]   = $perHari[$d]['normal'] ?? 0;
            $abnormals[] = $perHari[$d]['abnormal'] ?? 0;
        }

        $left = 55; $right = 1180; $top = 15; $bottom = 265;
        $plotW = $right - $left;
        $plotH = $bottom - $top;

        $yMax = $this->niceCeilMax(max($totals ?: [0]));

        $x = function (int $i) use ($left, $plotW, $jumlahHari) {
            return $jumlahHari > 1 ? $left + $i * ($plotW / ($jumlahHari - 1)) : $left;
        };
        $y = function (float $v) use ($bottom, $plotH, $yMax) {
            return $yMax > 0 ? $bottom - ($v / $yMax) * $plotH : $bottom;
        };

        $buildPoints = function (array $vals) use ($x, $y) {
            $pts = [];
            foreach ($vals as $i => $v) {
                $pts[] = round($x($i), 1) . ',' . round($y((float) $v), 1);
            }
            return implode(' ', $pts);
        };

        $yTicks = [];
        for ($i = 0; $i <= 5; $i++) {
            $val = (int) round($yMax * $i / 5);
            $yTicks[] = ['value' => $val, 'y' => round($y((float) $val), 1)];
        }

        $xLabels = [];
        for ($d = 1; $d <= $jumlahHari; $d++) {
            $xLabels[] = ['day' => $d, 'x' => round($x($d - 1), 1)];
        }

        return [
            'points_total'    => $buildPoints($totals),
            'points_normal'   => $buildPoints($normals),
            'points_abnormal' => $buildPoints($abnormals),
            'y_ticks'         => $yTicks,
            'x_labels'        => $xLabels,
            'left'            => $left,
            'right'           => $right,
            'bottom_label_y'  => $bottom + 18,
        ];
    }

    private function niceCeilMax(int $max): int
    {
        if ($max <= 0) {
            return 10;
        }

        $exp = (int) floor(log10($max));
        $base = 10 ** $exp;
        $frac = $max / $base;

        if ($frac <= 1) {
            $niceFrac = 1;
        } elseif ($frac <= 2) {
            $niceFrac = 2;
        } elseif ($frac <= 5) {
            $niceFrac = 5;
        } else {
            $niceFrac = 10;
        }

        return (int) ($niceFrac * $base);
    }

    private function angkaRomawi(int $n): string
    {
        if ($n <= 0) {
            return (string) $n;
        }

        $map = [
            50 => 'L', 40 => 'XL', 10 => 'X', 9 => 'IX',
            5 => 'V', 4 => 'IV', 1 => 'I',
        ];
        $out = '';
        foreach ($map as $val => $sym) {
            while ($n >= $val) {
                $out .= $sym;
                $n -= $val;
            }
        }

        return $out;
    }

    private function buildAnomaliChart(string $periodeIni): array
    {
        $sql = "SELECT
                    COALESCE(NULLIF(LTRIM(RTRIM(c.nama)), ''), 'Tanpa Kendala') AS nama,
                    COUNT(*) AS jumlah
                FROM bacameter.datameter d
                LEFT JOIN bacameter.cater_alasan c ON c.id = d.id_anomali
                WHERE d.periode = :periode
                GROUP BY c.nama
                ORDER BY jumlah DESC";

        $stmt = $this->db->prepare($sql);
        $stmt->execute(['periode' => $periodeIni]);
        $raw = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        $totalKeseluruhan = array_sum(array_column($raw, 'jumlah'));

        if ($totalKeseluruhan === 0) {
            return ['total' => 0, 'legend' => [], 'gradient' => '#e5e7eb 0% 100%'];
        }

        $top = array_slice($raw, 0, self::MAX_SLICE);
        $sisa = array_slice($raw, self::MAX_SLICE);
        $jumlahLainnya = array_sum(array_column($sisa, 'jumlah'));

        $legend = [];
        $gradientParts = [];
        $cumulativePct = 0.0;

        foreach ($top as $i => $row) {
            $pct = round(($row['jumlah'] / $totalKeseluruhan) * 100, 1);
            $color = self::PALETTE[$i % count(self::PALETTE)];

            $startPct = $cumulativePct;
            $cumulativePct += $pct;

            $legend[] = [
                'nama'  => $row['nama'],
                'pct'   => $pct,
                'color' => $color,
            ];
            $gradientParts[] = "{$color} " . round($startPct, 2) . '% ' . round($cumulativePct, 2) . '%';
        }

        if ($jumlahLainnya > 0) {
            $pctLainnya = round(($jumlahLainnya / $totalKeseluruhan) * 100, 1);
            $startPct = $cumulativePct;
            $cumulativePct = 100.0; 

            $legend[] = [
                'nama'  => 'Lainnya',
                'pct'   => $pctLainnya,
                'color' => self::WARNA_LAINNYA,
            ];
            $gradientParts[] = self::WARNA_LAINNYA . ' ' . round($startPct, 2) . '% 100%';
        }

        return [
            'total'    => $totalKeseluruhan,
            'legend'   => $legend,
            'gradient' => implode(', ', $gradientParts),
        ];
    }
}