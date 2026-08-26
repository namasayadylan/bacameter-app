<?php

use Phalcon\Autoload\Loader;

/** @var \Phalcon\Config\Config $config */

$loader = new Loader();

$loader->setDirectories([
    $config->application->controllersDir,
    $config->application->modelsDir,
]);

$loader->register();