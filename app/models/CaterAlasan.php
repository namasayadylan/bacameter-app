<?php

use Phalcon\Mvc\Model;
class CaterAlasan extends Model
{
    public $id;
    public $nama;
    public $kode;
    public $status; 

    public function initialize()
    {
        $this->setSchema('bacameter');
        $this->setSource('cater_alasan');
    }
}
