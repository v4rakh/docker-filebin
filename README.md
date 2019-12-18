# FileBin 🐋

A docker image for [FileBin](https://github.com/Bluewind/filebin) to have it up and running in seconds.

Visit project on [GitHub](https://github.com/v4rakh/docker-filebin).

## Getting started

The easierst and recommended way to get started is to use the example `docker-compose.yml` file and make yourself familiar with the environment variables which can be set. Defaults should do as a starting point.

_Be sure to read persisting volumes_ section and execute the required command.

Default database is PostgreSQL. Other databases are supported and can be configured via exposed environment variables. Please refer to the original documentation of the application for further details. PHP modules for MySQL are included in the image.

After your database and the application docker container is up and running, add a first user by executing a command within the docker container:

```
docker exec -it filebin_app /bin/sh
php /var/www/index.php user add_user
```

### Persisting volumes

You'll probably want the `uploads/` folder to be persistent across container restarts.

Here's an example on how to persist the `data/uploads/` folder of the application.

* Create folder: `mkdir -p ./filebin_data`
* Afterwards, adjust permissions so that the folder can be used within the docker container: `chown -R 65534:102 <host-mount>` (`nobody:nginx`)
* Reference the folder as a docker volume, e.g. with `./filebin_data:/var/www/data/uploads`

### Cron jobs

Application specific cron jobs are run every 15 minutes.

### Advanced configuration: customize non-exposed configuration variables

If you need to make frequent changes or adapt configuration values which
are not exposed as environment variables, you probably want have the `config-local.php` and `database.php` or the entire `config/` folder on the hosts file system.

In order to do so, first _extract_ the current configuration, e.g. by extracting only the required `.php` files or by extracting the entire `config/` folder. In this example we'll just use  entire folder.

```
docker cp filebin_app:/var/www/application/config/ ./filebin_config
chown -R 65534:102 ./filebin_config
```

Add the `./filebin_config` folder as a host bind to the application docker container, e.g. with `./filebin_config:/var/www/application/config/`

### Available environment variables

Please have a look into `Dockerfile` for available environment variables, they're all exposed there.

All variables to FileBin itself should be self-explaining. You should also be familiar with the `php.ini` variables. They're only inserted on build, if you like to increase the file limit above the used php variable values of this image, you'll need to rebuild the docker image.

There are two environment variables introduced by this image:

* `RECONFIGURE`: If all defined environment should be re-applied to the provided `.tpl` files within the image. You probably want this to be `1` unless you mounted your `config/` folder on the host
* `MIGRATE`: Calls FileBin database migration every time the container is started and updates dependencies via `composer`
* `SMTP_ENABLED`: Set to `true` in order to enable sending mails via an external SMTP server, set to `false` to use PHP's internal mailer, see other `SMTP_` variables in the `Dockerfile`

### Setting up a nginx proxy

Be sure to set the environment variable `BASE_URL` to the same where you expose it, e.g. `BASE_URL=https://fb.domain.tld`.

An example nginx configuration might look like the following.

```
upstream filebin {
    server 127.0.0.1:181;
}

server {
    listen 80;
    server_name  fb.domain.tld;
    return 301 https://fb.domain.tld$request_uri;
}

server {
    listen 443 ssl;
    server_name  fb.domain.tld;

    ssl_certificate /etc/letsencrypt/live/fb.domain.tld/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/fb.domain.tld/privkey.pem;

    gzip on;
    access_log off;

    location / {
        proxy_redirect off;
        proxy_pass http://filebin;

        proxy_set_header  Host                $http_host;
        proxy_set_header  X-Real-IP           $remote_addr;
        proxy_set_header  X-Forwarded-Ssl     on;
        proxy_set_header  X-Forwarded-For     $proxy_add_x_forwarded_for;
        proxy_set_header  X-Forwarded-Proto   $scheme;
        proxy_set_header  X-Frame-Options     SAMEORIGIN;

        client_body_buffer_size     128k;

        proxy_buffer_size           4k;
        proxy_buffers               4 32k;
        proxy_busy_buffers_size     64k;
        proxy_temp_file_write_size  64k;
    }
}
```

## Updates

Just use a newly released image version. Configuration should be compatible.

## Backup

Backup the host binds for `uploads/` and the database manually.

If you're using the provided `docker-compose.yml` file you probably can do something like the following and afterwards backup the extracted file from `/tmp` of your host system:


```
docker exec filebin_db bash -c "/usr/bin/pg_dumpall -U fb|gzip -c > /filebin_db.sql.gz";
docker cp filebin_db/:/var:/filebin_db.sql.gz /tmp/;
docker exec filebin_db bash -c "rm /filebin_db.sql.gz";
```

## Building

Steps:

* Clone to local `build/` folder which is later added
* Build image
* Push to registry or use locally

Example:

```
export FILEBIN_VERSION=3.4.1
mkdir -p build
git clone --branch ${FILEBIN_VERSION} https://github.com/Bluewind/filebin --depth=1 build/
docker build -t varakh/filebin:${FILEBIN_VERSION} -t varakh/filebin:latest .
```