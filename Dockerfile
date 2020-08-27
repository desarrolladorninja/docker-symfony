FROM php:7.2-apache

ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD php.ini /usr/local/etc/php/php.ini

RUN a2enmod rewrite && a2enmod headers && a2enmod env
RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN apt-get update && \
    apt-get install -y \
    zlib1g-dev

RUN docker-php-ext-install mbstring

RUN apt-get install -y libzip-dev unzip
RUN docker-php-ext-install zip

RUN apt-get update && apt-get install -y \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxpm-dev \
        libfreetype6-dev \
        libwebp-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN apt-get update && apt-get install -y \
    imagemagick \
    libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick

RUN apt-get update -y && \
    apt-get install -y libmcrypt-dev && \
    pecl install mcrypt-1.0.1 && \
    docker-php-ext-enable mcrypt

RUN pecl install xdebug redis \
  && docker-php-ext-enable xdebug redis

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN mkdir -p /var/www/public && echo "<h1 style='text-align: center;'>PHP/Apache for Symfony</h1><?php phpinfo(); ?>" > /var/www/public/index.php

WORKDIR /var/www
