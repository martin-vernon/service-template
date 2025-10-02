FROM php:8.4.6-fpm-alpine

ARG UID
ARG GID
ARG GITHUB_OAUTH_TOKEN

ENV UID=${UID}
ENV GID=${GID}

# Install system dependencies
RUN apk add --no-cache \
    linux-headers \
    $PHPIZE_DEPS \
    libpq-dev \
    postgresql-dev \
    zlib-dev \
    libzip-dev \
    autoconf \
    g++ \
    make \
    git \
    openssh \
    zip \
    unzip \
    curl \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    supervisor

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql pgsql intl zip bcmath sockets mbstring xml

# GD dependencies and extension
RUN apk add --no-cache libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Redis extension
RUN pecl install redis \
    && docker-php-ext-enable redis

# Set timezone on Server
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Europe/London /etc/localtime \
    && echo "Europe/London" > /etc/timezone \
    && echo "date.timezone=Europe/London" > /usr/local/etc/php/conf.d/timezone.ini
ENV TZ=Europe/London

# remove dependencies no longer needed
RUN apk del autoconf g++ make

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copy the .env file for composer install tasks
COPY ./.env.example ./.env

# Copy only composer files first for better caching
COPY ./composer.json ./composer.lock ./

# Install dependencies
RUN composer config --global github-oauth.github.com ${GITHUB_OAUTH_TOKEN}
# SSH trust fix (if needed)
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Now copy the rest of the Laravel project
COPY . .

COPY ./docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./docker/php/worker-entrypoint.sh /usr/local/bin/worker-entrypoint.sh
COPY ./docker/php/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/worker-entrypoint.sh

# Create supervisor logs directory
RUN mkdir -p /var/log/supervisor && chown -R laravel:laravel /var/log/supervisor

# Ensure permissions (optional)
RUN chown -R laravel:laravel /var/www/html/storage /var/www/html/bootstrap/cache

USER laravel
