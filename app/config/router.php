<?php

use Phalcon\Mvc\Router;

$router = new Router(false);


$router->setDefaultController('auth');
$router->setDefaultAction('login');


$router->add('/login', [
    'controller' => 'auth',
    'action'     => 'login',
]);
$router->add('/logout', [
    'controller' => 'auth',
    'action'     => 'logout',
]);

$router->add('/dashboard', [
    'controller' => 'dashboard',
    'action'     => 'index',
]);

$router->add('/petugas', [
    'controller' => 'petugas',
    'action'     => 'index',
]);
$router->add('/petugas/create', [
    'controller' => 'petugas',
    'action'     => 'create',
]);
$router->add('/petugas/edit/{id:[0-9]+}', [
    'controller' => 'petugas',
    'action'     => 'edit',
]);
$router->add('/petugas/delete/{id:[0-9]+}', [
    'controller' => 'petugas',
    'action'     => 'delete',
]);

$router->add('/anomali', [
    'controller' => 'anomali',
    'action'     => 'index',
]);
$router->add('/anomali/create', [
    'controller' => 'anomali',
    'action'     => 'create',
]);
$router->add('/anomali/edit/{id:[0-9]+}', [
    'controller' => 'anomali',
    'action'     => 'edit',
]);
$router->add('/anomali/delete/{id:[0-9]+}', [
    'controller' => 'anomali',
    'action'     => 'delete',
]);

$router->add('/datameter', [
    'controller' => 'datameter',
    'action'     => 'index',
]);
$router->add('/datameter/detail/{id:[0-9]+}', [
    'controller' => 'datameter',
    'action'     => 'detail',
]);

$router->add('/laporan', [
    'controller' => 'laporan',
    'action'     => 'index',
]);

return $router;
