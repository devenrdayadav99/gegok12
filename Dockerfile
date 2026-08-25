FROM php:8.4-fpm

# ----------------------------
# System dependencies
# ----------------------------
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    unzip \
    curl \
    zip \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libicu-dev \
    libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql \
        mbstring \
        zip \
        exif \
        pcntl \
        bcmath \
        gd \
        intl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Node.js 20
# ----------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node -v \
    && npm -v

# ----------------------------
# Composer
# ----------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ----------------------------
# Laravel directory
# ----------------------------
WORKDIR /var/www

COPY . .

# ----------------------------
# Composer dependencies
# ----------------------------
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction

# ----------------------------
# Frontend
# ----------------------------
RUN if [ -f package.json ]; then \
        npm install && npm run production; \
    fi

# ----------------------------
# Laravel directories & permissions
# ----------------------------
RUN mkdir -p \
        storage/framework/cache \
        storage/framework/sessions \
        storage/framework/views \
        storage/logs \
        bootstrap/cache \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# ----------------------------
# Nginx configuration
# ----------------------------
RUN rm -f /etc/nginx/sites-enabled/default \
          /etc/nginx/sites-available/default

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# ----------------------------
# Start script
# ----------------------------
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
