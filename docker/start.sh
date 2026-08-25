#!/bin/sh

set -e

# Railway provides PORT automatically
sed -i "s/__PORT__/${PORT}/g" /etc/nginx/conf.d/default.conf

# Laravel storage link
php artisan storage:link || true

# Start PHP-FPM
php-fpm -D

# Start Nginx in foreground
nginx -g "daemon off;"
