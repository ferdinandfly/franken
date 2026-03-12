FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts --optimize-autoloader

FROM dunglas/frankenphp:1-php8.3-bookworm

WORKDIR /app

COPY . /app

COPY --from=vendor /app/vendor /app/vendor

COPY ./Caddyfile /etc/caddy/Caddyfile

EXPOSE 80

CMD ["frankenphp", "run", "--config=/etc/caddy/Caddyfile"]

