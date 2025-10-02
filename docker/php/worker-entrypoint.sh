#!/bin/sh

set -e

# Defaults
: "${APP_ENV:=production}"
: "${RABBITMQ_HOST:=false}"
: "${RABBITMQ_PORT:=false}"
: "${WORKER_TIMEOUT:=60}"
: "${WAIT_FOR_RABBITMQ:=false}"
: "${WAIT_FOR_DB:=false}"

echo "🔧 Security Worker Environment: $APP_ENV"
echo "🔧 RABBITMQ_HOST: $RABBITMQ_HOST"
echo "🔧 RABBITMQ_PORT: $RABBITMQ_PORT"
echo "🔧 WORKER_TIMEOUT: $WORKER_TIMEOUT"
echo "🔧 WAIT_FOR_RABBITMQ: $WAIT_FOR_RABBITMQ"

echo "🔧 Running Laravel setup commands..."

# Wait for the database to be ready (optional but helpful)
if [ "$WAIT_FOR_DB" = "true" ]; then
  echo "⏳ Waiting for database to be ready..."
  until php -r "new PDO(getenv('DB_CONNECTION') . ':host=' . getenv('DB_HOST') . ';dbname=' . getenv('DB_DATABASE'), getenv('DB_USERNAME'), getenv('DB_PASSWORD'));" > /dev/null 2>&1; do
    sleep 2
  done
  echo "✅ Database is ready!"
fi

# Wait for RabbitMQ
if [ "$WAIT_FOR_RABBITMQ" = "true" ]; then
  echo "⏳ Waiting for RabbitMQ to be ready..."
  until nc -z $RABBITMQ_HOST $RABBITMQ_PORT; do
    sleep 2
    echo "🔄 Still waiting for RabbitMQ at $RABBITMQ_HOST:$RABBITMQ_PORT..."
  done
  echo "✅ RabbitMQ is ready!"
fi

# Laravel cache and setup commands
echo "🧹 Clearing Laravel cache..."
php artisan config:clear
php artisan config:cache

# Ensure queue tables exist (for database queue driver fallback)
echo "📋 Setting up RabbitMQ queues..."
# php artisan rabbitmq:queue-declare audit || true

echo "Starting Security Service Queue Worker..."
echo "Processing queues: ** New queue name here **"
echo "Connection: $QUEUE_CONNECTION"
echo "RabbitMQ Host: $RABBITMQ_HOST:$RABBITMQ_PORT"
echo "Worker timeout: $WORKER_TIMEOUT seconds"

# Export environment variables for supervisord
export WORKER_TIMEOUT

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
