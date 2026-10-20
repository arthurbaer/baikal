# syntax=docker/dockerfile:1

# ---- Stage 1: Baikal-Quelltext holen und Abhängigkeiten installieren ----
FROM composer:2 AS build
ARG BAIKAL_VERSION=0.13.0
RUN apk add --no-cache git
WORKDIR /src
RUN git clone --depth 1 --branch "${BAIKAL_VERSION}" https://github.com/sabre-io/Baikal.git . \
 && composer config platform.php 8.2 \
 && composer install --no-dev --no-interaction --optimize-autoloader \
 && rm -rf .git tests

# ---- Stage 2: Laufzeit-Image (Apache + PHP) ----
FROM php:8.3-apache
ARG BAIKAL_VERSION=0.13.0
LABEL org.opencontainers.image.title="Baikal" \
      org.opencontainers.image.version="${BAIKAL_VERSION}" \
      org.opencontainers.image.source="https://github.com/sabre-io/Baikal" \
      org.opencontainers.image.licenses="GPL-3.0-only"

# pdo_sqlite, dom und zlib sind im Basis-Image enthalten; pdo_mysql optional für MySQL/MariaDB
RUN docker-php-ext-install pdo_mysql \
 && a2enmod rewrite headers expires \
 && sed -ri 's!/var/www/html!/var/www/baikal/html!g' /etc/apache2/sites-available/*.conf \
 && printf '%s\n' \
      '<Directory /var/www/baikal/html>' \
      '    Options FollowSymLinks' \
      '    AllowOverride All' \
      '    Require all granted' \
      '</Directory>' \
      > /etc/apache2/conf-available/baikal.conf \
 && a2enconf baikal

COPY --from=build --chown=www-data:www-data /src /var/www/baikal
RUN mkdir -p /var/www/baikal/config /var/www/baikal/Specific/db \
 && chown -R www-data:www-data /var/www/baikal/config /var/www/baikal/Specific

# Persistente Daten: Konfiguration (baikal.yaml) und SQLite-DB
VOLUME ["/var/www/baikal/config", "/var/www/baikal/Specific"]

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
  CMD curl -fsS -o /dev/null http://localhost/ || exit 1
