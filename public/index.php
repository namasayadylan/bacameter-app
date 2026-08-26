<?php

error_reporting(E_ALL);
ini_set('display_errors', '1');

define('BASE_PATH', dirname(__DIR__));
define('APP_PATH', BASE_PATH . '/app');

require APP_PATH . '/config/env.php';
loadEnv(BASE_PATH . '/.env');

if (!extension_loaded('phalcon')) {
    die('Extension php_phalcon belum aktif. Cek php.ini (lihat Bab 2.4 Brief Task).');
}

try {
    $config = require APP_PATH . '/config/config.php';

    $di = require APP_PATH . '/config/services.php';

    require APP_PATH . '/config/loader.php';

    $application = new \Phalcon\Mvc\Application($di);

    echo $application->handle($_SERVER['REQUEST_URI'])->getContent();
} catch (\Throwable $e) {
    echo '<h3>Error</h3><pre>' . htmlspecialchars($e->getMessage()) . '</pre>';
}
