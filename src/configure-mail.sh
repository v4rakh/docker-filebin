#!/bin/sh

function set_mail_config() {

cat <<EOF > /var/www/msmtprc
account filebinmail
tls on
tls_certcheck off
auth on
host ${SMTP_HOST}
port ${SMTP_PORT}
user ${SMTP_USER}
from ${EMAIL_FROM}
password ${SMTP_PASS}
EOF

  chmod 600 /var/www/msmtprc
}

set_mail_config;