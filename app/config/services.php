<?php

use Phalcon\Di\FactoryDefault;
use Phalcon\Mvc\View;
use Phalcon\Mvc\View\Engine\Volt as VoltEngine;
use Phalcon\Mvc\Url as UrlResolver;
use Phalcon\Session\Manager as SessionManager;
use Phalcon\Session\Adapter\Stream as SessionStream;

/** @var \Phalcon\Config\Config $config  */

$di = new FactoryDefault();

$di->setShared('config', function () use ($config) {
    return $config;
});

$di->setShared('db', function () {
    $host     = getenv('DB_HOST');
    $port     = getenv('DB_PORT') ?: '1433';
    $database = getenv('DB_DATABASE') ?: 'erp';
    $username = getenv('DB_USERNAME');
    $password = getenv('DB_PASSWORD');

    if (str_contains($host, '\\')) {
        $dsn = "sqlsrv:Server={$host};Database={$database}";
    } else {
        $dsn = "sqlsrv:Server={$host},{$port};Database={$database}";
    }

    try {
        $pdo = new \PDO($dsn, $username, $password, [
            \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION,
        ]);
    } catch (\PDOException $e) {
     
        throw new \Exception(
            'Koneksi database gagal. Cek: (1) DB_HOST/DB_PORT/DB_DATABASE di .env, '
            . '(2) extension pdo_sqlsrv & sqlsrv aktif di php.ini, '
            . '(3) SQL Server sedang berjalan. Detail: ' . $e->getMessage()
        );
    }

    return $pdo;
});

$di->setShared('url', function () use ($config) {
    $url = new UrlResolver();
    $url->setBaseUri($config->application->baseUri);
    return $url;
});

$di->setShared('router', function () {
    return require APP_PATH . '/config/router.php';
});

$di->setShared('session', function () {
    $session = new SessionManager();
    $files   = new SessionStream(['savePath' => sys_get_temp_dir()]);

    $session->setAdapter($files);
    $session->start();

    return $session;
});

$di->setShared('view', function () use ($config, $di) {
    $view = new View();
    $view->setViewsDir($config->application->viewsDir);

    $voltCacheDir = BASE_PATH . '/storage/volt_cache/';
    if (!is_dir($voltCacheDir)) {
        mkdir($voltCacheDir, 0777, true);
    }

    $view->registerEngines([
        '.volt' => function ($view) use ($di, $voltCacheDir) {
            $volt = new VoltEngine($view, $di);

            $volt->setOptions([
                'path'          => $voltCacheDir,
                'separator'     => '_',
                'always'        => false,
            ]);

            $compiler = $volt->getCompiler();
            $compiler->addFunction('number_format', 'number_format');

            return $volt;
        },
    ]);

    return $view;
});

return $di;