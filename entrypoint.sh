#!/bin/bash

mkdir -p /config/storage /config/uploads /config/logs
cd "${PREV_DIR}"

# copy config files
PREV_DIR=$(pwd)

	cd /defaults/storage
	shopt -s globstar nullglob
	for i in *
 	do
	[[ ! -e "/config/storage/${i}" ]] && cp -r "${i}" "/config/storage/${i}"
	done

	cd /defaults/uploads
	shopt -s globstar nullglob
	for i in *
 	do
	[[ ! -e "/config/uploads/${i}" ]] && cp -r "${i}" "/config/uploads/${i}"
	done
cd "${PREV_DIR}"

# make symlinks
[[ ! -L /var/www/html/storage ]] && \
        ln -sf /config/storage /var/www/html/storage
[[ ! -L /var/www/html/public/uploads ]] && \
        ln -sf /config/uploads /var/www/html/public/uploads

if [ ! -f "/var/www/html/database/migrations/*create_oauth*" ]; then
  cp -a /var/www/html/vendor/laravel/passport/database/migrations/* /var/www/html/database/migrations/
fi

# Upgrading engine and run DB migration scripts
PREV_DIR=$(pwd)
cd /var/www/html
php artisan down
composer dump
php artisan cache:clear
php artisan view:clear
php artisan config:clear
composer install --no-dev --prefer-source
composer dump-autoload
php artisan up
cd "${PREV_DIR}"

chown -R nginx:nginx /config /var/www/html

/usr/bin/supervisord -c /etc/supervisord.conf --logfile=/config/logs/supervisord.log -j /run/supervisord.pid