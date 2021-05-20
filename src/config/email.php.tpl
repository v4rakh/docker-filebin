<?php

// SMTP mail settings if enabled
if (getenv('SMTP_ENABLED') === 'true') {
    $config = [
        'protocol' => %%%SMTP_PROTOCOL%%%,
        'smtp_host' => %%%SMTP_HOST%%%,
        'smtp_port' => intval(%%%SMTP_PORT%%%),
        'smtp_crypto' => %%%SMTP_CRYPTO%%%,
        'smtp_user' => %%%SMTP_USER%%%,
        'smtp_pass' => %%%SMTP_PASS%%%,
    ];
}
