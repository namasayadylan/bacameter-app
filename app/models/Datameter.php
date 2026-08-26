<?php

use Phalcon\Mvc\Model;

class Datameter extends Model
{
    public $id;
    public $nomor_pelanggan;
    public $nama;
    public $alamat;
    public $stand_awal;
    public $stand_akhir;
    public $pakai;
    public $stand_catatpetugas;
    public $harga_air;
    public $biaya_admin;
    public $status_baca;
    public $id_petugas;
    public $id_anomali;
    public $tanggal_catat;
    public $waktu_catat;
    public $bulan;
    public $tahun;
    public $periode;
    public $lat_long;
    public $nomor_meter;
    public $watermeter_name;
    public $periode1;
    public $pakai1;
    public $periode2;
    public $pakai2;
    public $periode3;
    public $pakai3;

    public function initialize()
    {
        $this->setSchema('bacameter');
        $this->setSource('datameter');
    }
}
