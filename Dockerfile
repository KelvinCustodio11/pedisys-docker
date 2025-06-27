FROM php:8.3-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git ffmpeg unzip \
    libzip-dev zlib1g-dev \
    libfreetype6-dev libicu-dev libgmp-dev \
    libjpeg62-turbo-dev libpng-dev libwebp-dev libxpm-dev \
    libmagickwand-dev libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd intl bcmath calendar exif gmp mysqli pdo pdo_mysql zip \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# Instalar Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/local/bin/composer

# Instalar Node.js (com npm e npx incluídos)
COPY --from=node:23 /usr/local /usr/local

WORKDIR /var/www/html
