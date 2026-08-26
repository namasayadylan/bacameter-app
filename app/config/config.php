<?php
return new \Phalcon\Config\Config([
    'application' => [
        'controllersDir' => __DIR__ . '/../controllers/',
        'modelsDir'       => __DIR__ . '/../models/',
        'viewsDir'        => __DIR__ . '/../views/',
        'baseUri'         => '/',
    ],
]);
