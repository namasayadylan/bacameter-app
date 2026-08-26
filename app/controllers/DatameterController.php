<?php
class DatameterController extends ControllerBase
{
    private const PERIODE_AKTIF = '202607';
    private const PCT_ANOMALI_THRESHOLD = 50;

    public function indexAction()
    {
        $periode = self::PERIODE_AKTIF;

        $filter = [
            'no_pel'     => trim((string) $this->request->getQuery('no_pel', 'string', '')),
            'nama'       => trim((string) $this->request->getQuery('nama', 'string', '')),
            'alamat'     => trim((string) $this->request->getQuery('alamat', 'string', '')),
            'id_anomali' => (int) $this->request->getQuery('id_anomali', 'int', 0),
            'tgl1'       => trim((string) $this->request->getQuery('tgl1', 'string', '')),
            'tgl2'       => trim((string) $this->request->getQuery('tgl2', 'string', '')),
            'pakai_val'  => trim((string) $this->request->getQuery('pakai_val', 'string', '')),
            'pakai_op'   => trim((string) $this->request->getQuery('pakai_op', null, '=')),
            'no_meter'   => trim((string) $this->request->getQuery('no_meter', 'string', '')),
        ];

        $where = ['d.periode = :periode'];
        $bind  = ['periode' => $periode];

        if ($filter['no_pel'] !== '') {
            $where[] = 'd.nomor_pelanggan LIKE :no_pel';
            $bind['no_pel'] = '%' . $filter['no_pel'] . '%';
        }
        if ($filter['nama'] !== '') {
            $where[] = 'd.nama LIKE :nama';
            $bind['nama'] = '%' . $filter['nama'] . '%';
        }
        if ($filter['alamat'] !== '') {
            $where[] = 'd.alamat LIKE :alamat';
            $bind['alamat'] = '%' . $filter['alamat'] . '%';
        }
        if ($filter['id_anomali'] > 0) {
            $where[] = 'd.id_anomali = :id_anomali';
            $bind['id_anomali'] = $filter['id_anomali'];
        }
        if ($filter['tgl1'] !== '' && $filter['tgl2'] !== '') {
            $where[] = 'd.tanggal_catat BETWEEN :tgl1 AND :tgl2';
            $bind['tgl1'] = $filter['tgl1'];
            $bind['tgl2'] = $filter['tgl2'];
        }
        if ($filter['pakai_val'] !== '' && in_array($filter['pakai_op'], ['=', '<', '>'], true)) {
            $where[] = "d.pakai {$filter['pakai_op']} :pakai_val";
            $bind['pakai_val'] = (int) $filter['pakai_val'];
        }
        if ($filter['no_meter'] !== '') {
            $where[] = 'd.nomor_meter LIKE :no_meter';
            $bind['no_meter'] = '%' . $filter['no_meter'] . '%';
        }

        $whereSql = implode(' AND ', $where);

        $hasFilter = count($bind) > 1;

        $countSql = "SELECT COUNT(*) AS jumlah FROM bacameter.datameter d WHERE {$whereSql}";
        $stmtCount = $this->db->prepare($countSql);
        $stmtCount->execute($bind);
        $totalMatch = (int) $stmtCount->fetchColumn();
        $rowLimit = 500;
        $isCapped = $hasFilter && $totalMatch > $rowLimit;

        $sql = "SELECT TOP {$rowLimit} d.id, d.tanggal_catat, d.nomor_pelanggan, d.nama, d.alamat,
                       d.stand_awal, d.stand_akhir, d.stand_catatpetugas, d.pakai, d.pakai1,
                       d.harga_air, d.biaya_admin,
                       p.nama AS nama_petugas,
                       c.kode AS kode_anomali, c.nama AS nama_anomali, c.tipe AS tipe_anomali
                FROM bacameter.datameter d
                LEFT JOIN bacameter.petugas p ON p.id = d.id_petugas
                LEFT JOIN bacameter.cater_alasan c ON c.id = d.id_anomali
                WHERE {$whereSql}
                ORDER BY d.tanggal_catat DESC";

        $stmt = $this->db->prepare($sql);
        $stmt->execute($bind);
        $raw = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        $rows = [];
        $totalM3 = 0;
        $totalRekening = 0.0;

        foreach ($raw as $r) {
            $pakai  = (int) $r['pakai'];
            $pakai1 = (int) $r['pakai1'];

            if ($pakai1 === 0) {
                $pct = null;
                $pctClass = 'zero';
            } else {
                $pct = round((($pakai - $pakai1) / $pakai1) * 100, 2);
                $pctClass = abs($pct) > self::PCT_ANOMALI_THRESHOLD ? 'high' : 'normal';
            }

            $totalM3 += $pakai;
            $totalRekening += (float) $r['harga_air'] + (float) $r['biaya_admin'];

            $rows[] = [
                'id'                 => $r['id'],
                'tanggal_catat'      => $r['tanggal_catat'],
                'nomor_pelanggan'    => $r['nomor_pelanggan'],
                'nama'               => $r['nama'],
                'alamat'             => $r['alamat'],
                'stand_awal'         => $r['stand_awal'],
                'stand_akhir'        => $r['stand_akhir'],
                'stand_catatpetugas' => $r['stand_catatpetugas'],
                'pakai'              => $pakai,
                'pakai1'             => $pakai1,
                'kode_anomali'       => trim((string) $r['kode_anomali']),
                'nama_anomali'       => $r['nama_anomali'],
                'kendala_class'      => $r['kode_anomali'] !== null && trim((string) $r['kode_anomali']) === '00' ? 'ok' : 'warn',
                'pct'                => $pct,
                'pct_class'          => $pctClass,
                'nama_petugas'       => $r['nama_petugas'],
                'harga_air'          => $r['harga_air'],
                'biaya_admin'        => $r['biaya_admin'],
                'total_rekening'     => (float) $r['harga_air'] + (float) $r['biaya_admin'],
            ];
        }
        $totalPelanggan = count($rows);

        $stmtA = $this->db->query(
            'SELECT id, kode, nama FROM bacameter.cater_alasan ORDER BY kode ASC'
        );
        $anomaliOptionsRaw = $stmtA->fetchAll(\PDO::FETCH_ASSOC);
        $anomaliOptions = array_map(function ($a) {
            return [
                'id'   => $a['id'],
                'kode' => trim($a['kode']),
                'nama' => $a['nama'],
            ];
        }, $anomaliOptionsRaw);

        $this->view->setVar('pageTitle', 'Pengolahan Data');
        $this->view->setVar('periode', $periode);
        $this->view->setVar('rows', $rows);
        $this->view->setVar('filter', $filter);
        $this->view->setVar('anomaliOptions', $anomaliOptions);
        $this->view->setVar('totalPelanggan', $totalPelanggan);
        $this->view->setVar('totalM3', $totalM3);
        $this->view->setVar('totalRekening', $totalRekening);
        $this->view->setVar('totalMatch', $totalMatch);
        $this->view->setVar('isCapped', $isCapped);
        $this->view->setVar('rowLimit', $rowLimit);
    }

    public function detailAction(int $id)
    {
        $this->view->disable();
        $this->response->setContentType('application/json', 'UTF-8');

        $sql = "SELECT d.*,
                       p.nama AS nama_petugas,
                       c.kode AS kode_anomali, c.nama AS nama_anomali
                FROM bacameter.datameter d
                LEFT JOIN bacameter.petugas p ON p.id = d.id_petugas
                LEFT JOIN bacameter.cater_alasan c ON c.id = d.id_anomali
                WHERE d.id = :id";

        $stmt = $this->db->prepare($sql);
        $stmt->execute(['id' => $id]);
        $d = $stmt->fetch(\PDO::FETCH_ASSOC);

        if (!$d) {
            $this->response->setContent(json_encode(['error' => 'Data tidak ditemukan']));
            return $this->response;
        }
        $periods = [
            ['periode' => $d['periode1'] ?? null, 'pakai' => $d['pakai1'] ?? null],
            ['periode' => $d['periode2'] ?? null, 'pakai' => $d['pakai2'] ?? null],
            ['periode' => $d['periode3'] ?? null, 'pakai' => $d['pakai3'] ?? null],
        ];
        $validPakai = array_filter($periods, function ($p) {
            return $p['periode'] !== null && $p['periode'] !== 0;
        });
        $avg3 = count($validPakai) > 0
            ? round(array_sum(array_column($validPakai, 'pakai')) / count($validPakai), 2)
            : null;
        $lat = null;
        $lng = null;
        if (!empty($d['lat_long']) && str_contains($d['lat_long'], ',')) {
            $parts = explode(',', $d['lat_long']);
            if (count($parts) === 2 && is_numeric(trim($parts[0])) && is_numeric(trim($parts[1]))) {
                $lng = (float) trim($parts[0]); 
                $lat = (float) trim($parts[1]); 
            }
        }

        $result = [
            'nama'             => $d['nama'],
            'nomor_pelanggan'  => $d['nomor_pelanggan'],
            'alamat'           => $d['alamat'],
            'watermeter_name'  => $d['watermeter_name'],
            'nomor_meter'      => $d['nomor_meter'],
            'nama_petugas'     => $d['nama_petugas'],
            'tanggal_catat'    => $d['tanggal_catat'],
            'waktu_catat'      => $d['waktu_catat'],

            'periode1' => $d['periode1'], 'stand_awal1' => $d['stand_awal1'], 'stand_akhir1' => $d['stand_akhir1'], 'pakai1' => $d['pakai1'],
            'periode2' => $d['periode2'], 'stand_awal2' => $d['stand_awal2'], 'stand_akhir2' => $d['stand_akhir2'], 'pakai2' => $d['pakai2'],
            'periode3' => $d['periode3'], 'stand_awal3' => $d['stand_awal3'], 'stand_akhir3' => $d['stand_akhir3'], 'pakai3' => $d['pakai3'],
            'avg3'     => $avg3,

            'lat_long' => $d['lat_long'],
            'lat'      => $lat,
            'lng'      => $lng,

            'periode'      => $d['periode'],
            'stand_akhir'  => $d['stand_akhir'],
            'nama_anomali' => $d['nama_anomali'],
        ];

        $this->response->setContent(json_encode($result));
        return $this->response;
    }
}