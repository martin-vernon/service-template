#!/bin/sh

set -e

# Defaults
: "${APP_ENV:=production}"
: "${DB_RUN_MIGRATIONS:=false}"
: "${DB_RESEED:=false}"
: "${WAIT_FOR_DB:=false}"

echo "🔧 Environment: $APP_ENV"
echo "🔧 DB_RUN_MIGRATIONS: $DB_RUN_MIGRATIONS"
echo "🔧 DB_RESEED: $DB_RESEED"

echo "🔧 Running Laravel setup commands..."

# Wait for the database to be ready (optional but helpful)
if [ "$WAIT_FOR_DB" = "true" ]; then
  echo "⏳ Waiting for database to be ready..."
  until php -r "new PDO(getenv('DB_CONNECTION') . ':host=' . getenv('DB_HOST') . ';dbname=' . getenv('DB_DATABASE'), getenv('DB_USERNAME'), getenv('DB_PASSWORD'));" > /dev/null 2>&1; do
    sleep 2
  done
  echo "✅ Database is ready!"
fi

# Finish up Laravel install
php artisan package:discover --ansi
# Laravel cache and setup commands
php artisan config:clear
php artisan route:clear
#php artisan view:clear
php artisan config:cache
php artisan route:cache
#php artisan view:cache

# Run migrations if needed (optional)
if [ "$DB_RUN_MIGRATIONS" = "true" ] && ( [ "$APP_ENV" = "local" ] || [ "$APP_ENV" = "development" ] ); then
  echo "🔄 Running database migrations..."
  if [ "$DB_RESEED" = "true" ]; then
    php artisan migrate:fresh --force --seed
  else
    php artisan migrate --force
  fi
fi

echo "🚀 Starting PHP-FPM..."
exec php-fpm -y /usr/local/etc/php-fpm.conf -R
