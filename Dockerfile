FROM alpine:3

LABEL maintainer="Varakh<varakh@varakh.de>"

# Expose variables to ease overwriting
ENV RECONFIGURE true
ENV MIGRATE true

# php.ini
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          1024M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        1024M

# database.php
ENV DB_DSN ''
ENV DB_HOST localhost
ENV DB_PORT 5432
ENV DB_DRIVER postgre
ENV DB_NAME fb
ENV DB_USER fb
ENV DB_PASS fb
ENV DB_PREFIX ''
ENV DB_PCONNECT '0'
ENV DB_DEBUG '1'
ENV DB_CHAR_SET utf8
ENV DB_COLLAT utf8_bin
ENV DB_SWAP_PRE ''
ENV DB_ENCRYPT '0'
ENV DB_COMPRESS '0'
ENV DB_STRICTON '0'
ENV DB_SAVE_QUERIES '0'

# config-local.php
ENV BASE_URL ''
ENV INDEX_PAGE ''
ENV ENCRYPTION_KEY ''
ENV CACHE_BACKEND dummy
ENV EMAIL_FROM ''
ENV UPLOAD_MAX_SIZE 1073741824
ENV UPLOAD_MAX_TEXT_SIZE 2097152
ENV UPLOAD_MAX_AGE 432000
ENV ACTIONS_MAX_AGE 86400
ENV SMALL_UPLOAD_SIZE 5120
ENV TARBALL_MAX_SIZE 1073741824
ENV TARBALL_CACHE_TIME 300
ENV MAX_INVITATION_KEYS 3
ENV SMTP_ENABLED false
ENV SMTP_PROTOCOL 'smtp'
ENV SMTP_HOST ''
ENV SMTP_PORT 587
ENV SMTP_CRYPTO 'tls'
ENV SMTP_USER ''
ENV SMTP_PASS ''

# add script for database
ADD src/wait-for.sh /wait-for.sh

# add upstream application
ADD build/ /var/www

# install dependencies
RUN chmod -x /wait-for.sh && \
    apk add --update --no-cache \
        nginx \
        s6 \
        curl \
        python3 \
        py-pygments \
        composer \
        php7 \
        php7-intl \
        php7-fpm \
        php7-cli \
        php7-curl \
        php7-fileinfo \
        php7-mbstring \
        php7-gd \
        php7-json \
        php7-dom \
        php7-pcntl \
        php7-posix \
        php7-pgsql \
        php7-exif \
        php7-mcrypt \
        php7-session \
        php7-pdo \
        php7-pdo_pgsql \
        php7-ctype \
        php7-mysqli \
        php7-pecl-memcached \
        memcached \
        ca-certificates && \
    rm -rf /var/cache/apk/* && \
    apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted && \
    # prepare www dir
    cp -r /var/www/application/config/example/* /var/www/application/config && \
    # set environments
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini && \
    # clean up and permissions
    rm -rf /var/cache/apk/* && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    chown nobody:nginx -R /var/www

# Add nginx config
ADD src/filebin.nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

# add templates for replace env variables in the application
ADD src/config/database.php.tpl /var/www/application/config/database.php.tpl
ADD src/config/config-local.php.tpl /var/www/application/config/config-local.php.tpl
ADD src/configure.php /configure.php
ADD src/crontab /etc/periodic/15min/crontab

# add overlay
ADD src/s6/ /etc/s6/

# expose start
CMD php /configure.php && exec s6-svscan /etc/s6/
