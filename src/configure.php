#!/usr/bin/env php
<?php

if (getenv('RECONFIGURE') === "true") {
    echo "Reconfiguring container..." . PHP_EOL;

    $confPath = '/var/www/application/config/config-local.php.tpl';
    $confTargetPath = '/var/www/application/config/config-local.php';
    $confVars = [
        'BASE_URL',
        'ENCRYPTION_KEY',
        'CACHE_BACKEND',
        'INDEX_PAGE',
        'EMAIL_FROM',
        'UPLOAD_MAX_SIZE',
        'UPLOAD_MAX_TEXT_SIZE',
        'UPLOAD_MAX_AGE',
        'ACTIONS_MAX_AGE',
        'SMALL_UPLOAD_SIZE',
        'TARBALL_MAX_SIZE',
        'TARBALL_CACHE_TIME',
        'MAX_INVITATION_KEYS'
    ];
    contentsReplace($confVars, $confPath, $confTargetPath);

    $dbPath = '/var/www/application/config/database.php.tpl';
    $dbTargetPath = '/var/www/application/config/database.php';
    $dbVars = [
        'DB_DSN',
        'DB_HOST',
        'DB_PORT',
        'DB_DRIVER',
        'DB_NAME',
        'DB_USER',
        'DB_PASS',
        'DB_PREFIX',
        'DB_PCONNECT',
        'DB_DEBUG',
        'DB_CHAR_SET',
        'DB_COLLAT',
        'DB_SWAP_PRE',
        'DB_ENCRYPT',
        'DB_COMPRESS',
        'DB_STRICTON',
        'DB_SAVE_QUERIES'
    ];
    contentsReplace($dbVars, $dbPath, $dbTargetPath);
} else {
    echo "Will not reconfigure container..." . PHP_EOL;
}

if (getenv('MIGRATE') === "true") {
    echo "Migrating..." . PHP_EOL;

    exec("php /var/www/index.php tools update_database");
    exec("composer --working-dir=/var/www install --no-dev --no-plugins --no-scripts");
    exec("chown -R nobody:nginx /var/www");
} else {
    echo "Will not migrate..." . PHP_EOL;
}

function contentsReplace($envNames = array(), $filePath, $targetFilePath)
{
    $fileContent = file_get_contents($filePath);

    foreach ($envNames as $env) {
        $fileContent = preg_replace("/%%%" . strtoupper($env) . "%%%/", env($env), $fileContent);
    }


    file_put_contents($targetFilePath, $fileContent);
}


function env($name, $default = null)
{
    $v = getenv($name) ?: $default;

    if ($v === null) {
        return "''";
    }

    return "'" . $v . "'";
}
