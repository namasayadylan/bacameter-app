<?php

use Phalcon\Mvc\Model;

class User extends Model
{
    public $id;
    public $username;
    public $password;
    public $nama;
    public $role;
    public $is_active;
    public $created_at;
    public $updated_at;

    public function initialize()
    {
        $this->setSchema('dbo');
        $this->setSource('user');
    }
}
