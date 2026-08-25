#!/bin/sh

set -e

echo "Starting Laravel..."

cd /var/www

# Laravel storage link
php artisan storage:link || true

# Create nginx configuration for Railway
cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen ${PORT};
    listen [::]:${PORT};

    server_name _;

    root /var/www/public;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT \$document_root;
        fastcgi_pass 127.0.0.1:9000;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

echo "Starting PHP-FPM..."
php-fpm -D

echo "Starting Nginx on port ${PORT}..."

nginx -g "daemon off;"
