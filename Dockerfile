FROM php:7.4.21-fpm-alpine3.13

## WP CLI
RUN apk update && apk add curl \
  && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && php wp-cli.phar --info --allow-root \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp \
  && wp --info --allow-root \
  && apk del curl \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

## PHP EXTENSION: EXIF
RUN docker-php-ext-install -j$(nproc) exif

## PHP EXTENSION: ICONV
RUN docker-php-ext-install -j$(nproc) iconv

## PHP EXTENSION: OPCACHE
RUN docker-php-ext-install -j$(nproc) opcache

## PHP EXTENSION: PDO + PDO_MYSQL
RUN docker-php-ext-install -j$(nproc) pdo pdo_mysql mysqli 

## PHP EXTENSION: ZIP
RUN apk update && apk add coreutils libzip libzip-dev \
  && docker-php-ext-install -j$(nproc) zip \
  && apk del coreutils libzip-dev \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

## PHP EXTENSION: SOAP
RUN apk update && apk add libxml2 libxml2-dev \
  && docker-php-ext-install -j$(nproc) soap \
  && apk del libxml2-dev \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

## PHP EXTENSION: GD
RUN apk upgrade --update && apk add \
  # common development tools
    autoconf bash binutils binutils-dev coreutils m4 file gcc g++ isl libatomic libc-dev make mpc1 musl-dev perl re2c \
  # common runtime libs
    libstdc++ libgcc gmp libgomp \
  && apk add \
    # specific runtime libs
    freetype \
    libjpeg-turbo \
    libpng \ 
    # specific development libs
    freetype-dev \
    libjpeg-turbo-dev \
    libltdl \
    libpng-dev \
  && docker-php-ext-configure gd  \
    --with-jpeg=/usr/include/ \
    --with-freetype=/usr/include/ \  
  && docker-php-ext-install -j$(nproc) gd \
  && apk del \
    # common development tools
    autoconf bash binutils binutils-dev coreutils m4 file gcc g++ isl libatomic libc-dev make mpc1 musl-dev perl pkgconf pkgconfig readline re2c \
    # common runtime libs
    libgomp libattr libmagic \
    # specific development libs
    freetype-dev \
    libjpeg-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

## Extension: MEMCACHED
RUN apk update && apk add --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
  # common development tools
    autoconf bash binutils binutils-dev coreutils cyrus-sasl-dev file g++ gcc git gmp isl libatomic libc-dev libgcc libgomp m4 make mpc1 musl-dev perl re2c \
  # common runtime libs
  # specific runtime libs
    libmemcached zlib \
  # specific development libs
    libmemcached-dev zlib-dev\
  && git clone -c advice.detachedHead=false --depth 1 --branch v3.1.5 https://github.com/php-memcached-dev/php-memcached.git /usr/src/php/ext/memcached \
  && cd /usr/src/php/ext/memcached \
  && docker-php-ext-configure memcached --disable-memcached-sasl \
  && docker-php-ext-install memcached \
  && apk del \
    autoconf bash binutils binutils-dev coreutils cyrus-sasl-dev file g++ gcc git gmp isl libatomic libattr libc-dev m4 make mpc1 musl-dev perl pkgconf pkgconfig readline re2c \
    # common runtime libs
    libgomp libmagic libstdc++ \
    # specific runtime libs
    # specific development libs
    libmemcached-dev zlib-dev \
  && rm -fr /usr/src/php/ext/memcached \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*

## Extension Imagick
RUN set -ex \
  && apk update && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
  && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
  && pecl install imagick-3.4.3 \
  && docker-php-ext-enable imagick \
  && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
  && apk del .phpize-deps \
  && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*
