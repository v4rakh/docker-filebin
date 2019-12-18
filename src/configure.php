#!/usr/bin/env php
<?php

if (getenv('RECONFIGURE') === "true") {
    echo "Reconfiguring database and local settings..." . PHP_EOL;

    // configure database
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

    // configure local settings
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

    // configure mail if enabled
    $mailPath = '/var/www/application/config/email.php.tpl';
    $mailTargetPath = '/var/www/application/config/email.php';
    $mailVars = [
        'SMTP_PROTOCOL',
        'SMTP_HOST',
        'SMTP_PORT',
        'SMTP_CRYPTO',
        'SMTP_USER',
        'SMTP_PASS'
    ];
    contentsReplace($mailVars, $mailPath, $mailTargetPath);

    if (getenv('SMTP_ENABLED') === 'true') {
        echo "Applying mail configuration..." . PHP_EOL;
        exec('sh /var/www/configure-mail.sh');
    } else {
        echo "Will not apply mail configuration..." . PHP_EOL;
    }
} else {
    echo "Will not reconfigure database and local settings..." . PHP_EOL;
}

if (getenv('MIGRATE') === "true") {
    echo "Migrating database and dependencies..." . PHP_EOL;

    exec("php /var/www/index.php tools update_database");
    exec("composer --working-dir=/var/www install --no-dev --no-plugins --no-scripts");
    exec("chown -R nobody:nginx /var/www");
} else {
    echo "Will not migrate database and dependencies..." . PHP_EOL;
}

function contentsReplace($envNames, $filePath, $targetFilePath)
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
