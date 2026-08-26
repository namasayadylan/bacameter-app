<?php

use Phalcon\Mvc\Model;

class Petugas extends Model
{
    public $id;
    public $username;
    public $nama;
    public $no_telp;
    public $petugas_os; 
    public $zona_id;

    public function initialize()
    {
        $this->setSchema('bacameter');
        $this->setSource('petugas');
    }
}
