<?php

class DashboardController extends ControllerBase
{
    private const PERIODE_AKTIF = '202607';

    private const PALETTE = [
        '#3d7de0', '#f2c744', '#e0563a', '#5a9e3f', '#8e5ac2',
        '#e0729a', '#2fb5a6', '#c98a3e', '#4c6ef5',
    ];
    private const WARNA_LAINNYA = '#b9b9b9';
    private const MAX_SLICE = 9;

    public function indexAction()
    {
        $this->view->setVar('anomaliChart', $this->buildAnomaliChart());
    }

    private function buildAnomaliChart(): array
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
        $stmt->execute(['periode' => self::PERIODE_AKTIF]);
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