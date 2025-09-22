#!/bin/bash

# Service Template Setup Script
# This script helps create a new Laravel service from the template

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <service-name> [options]"
    echo ""
    echo "Options:"
    echo "  -p, --nginx-port PORT         Nginx port (default: auto-assign)"
    echo "  -d, --db-port PORT            PostgreSQL port (default: auto-assign)"
    echo "  -t, --github-token TOKEN      GitHub OAuth token"
    echo "  -h, --help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 notification --github-token ghp_xxxxxxxxxxxxxxxxxxxx"
    echo "  $0 payment-service --nginx-port 8085 --db-port 5436 --github-token ghp_xxxxxxxxxxxxxxxxxxxx"
}

# Parse command line arguments
SERVICE_NAME=""
NGINX_PORT=""
POSTGRES_PORT=""
GITHUB_OAUTH_TOKEN=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--nginx-port)
            NGINX_PORT="$2"
            shift 2
            ;;
        -d|--db-port)
            POSTGRES_PORT="$2"
            shift 2
            ;;
        -t|--github-token)
            GITHUB_OAUTH_TOKEN="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            print_error "Unknown option $1"
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$SERVICE_NAME" ]; then
                SERVICE_NAME="$1"
            else
                print_error "Multiple service names provided"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate service name
if [ -z "$SERVICE_NAME" ]; then
    print_error "Service name is required"
    show_usage
    exit 1
fi

# Validate GitHub OAuth token
if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
    print_error "GitHub OAuth token is required"
    show_usage
    exit 1
fi

# Clean service name (remove -service suffix if present)
SERVICE_NAME=$(echo "$SERVICE_NAME" | sed 's/-service$//')

# Validate service name format
if ! echo "$SERVICE_NAME" | grep -qE '^[a-z][a-z0-9-]*[a-z0-9]$'; then
    print_error "Service name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens"
    exit 1
fi

# Auto-assign ports if not provided
if [ -z "$NGINX_PORT" ]; then
    # Find next available port starting from 8080
    NGINX_PORT=8080
    while lsof -i :$NGINX_PORT >/dev/null 2>&1; do
        NGINX_PORT=$((NGINX_PORT + 1))
    done
fi

if [ -z "$POSTGRES_PORT" ]; then
    # Find next available port starting from 5430
    POSTGRES_PORT=5430
    while lsof -i :$POSTGRES_PORT >/dev/null 2>&1; do
        POSTGRES_PORT=$((POSTGRES_PORT + 1))
    done
fi

# Derived variables
SERVICE_NAME_TITLE=$(echo "$SERVICE_NAME" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
SERVICE_NAME_UPPER=$(echo "$SERVICE_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
TARGET_DIR="../${SERVICE_NAME}-service"

print_status "Creating new service: $SERVICE_NAME"
print_status "Service title: $SERVICE_NAME_TITLE"
print_status "Target directory: $TARGET_DIR"
print_status "Nginx port: $NGINX_PORT"
print_status "PostgreSQL port: $POSTGRES_PORT"
print_status "GitHub OAuth token: configured"

# Check if target directory already exists
if [ -d "$TARGET_DIR" ]; then
    print_error "Directory $TARGET_DIR already exists"
    exit 1
fi

# Copy template directory
print_status "Copying template files..."
cp -r . "$TARGET_DIR"

# Remove setup script from new service
rm -f "$TARGET_DIR/setup-service.sh"

cd "$TARGET_DIR"

# Process template files
print_status "Processing template files..."

# Process docker-compose.yml
if [ -f "docker-compose.yml.template" ]; then
    sed "s/{{SERVICE_NAME}}/$SERVICE_NAME/g; s/{{NGINX_PORT}}/$NGINX_PORT/g; s/{{POSTGRES_PORT}}/$POSTGRES_PORT/g" docker-compose.yml.template > docker-compose.yml
    rm docker-compose.yml.template
    print_success "Created docker-compose.yml"
fi

# Process README.md
if [ -f "README.md.template" ]; then
    sed "s/{{SERVICE_NAME}}/$SERVICE_NAME/g; s/{{SERVICE_NAME_TITLE}}/$SERVICE_NAME_TITLE/g; s/{{SERVICE_NAME_UPPER}}/$SERVICE_NAME_UPPER/g; s/{{NGINX_PORT}}/$NGINX_PORT/g; s/{{POSTGRES_PORT}}/$POSTGRES_PORT/g; s/{{SERVICE_DESCRIPTION}}/[TODO: Add service description]/g" README.md.template > README.md
    rm README.md.template
    print_success "Created README.md"
fi

# Process .env.example
if [ -f ".env.example.template" ]; then
    sed "s/{{SERVICE_NAME}}/$SERVICE_NAME/g; s/{{SERVICE_NAME_TITLE}}/$SERVICE_NAME_TITLE/g; s/{{NGINX_PORT}}/$NGINX_PORT/g; s/{{GITHUB_OAUTH_TOKEN}}/$GITHUB_OAUTH_TOKEN/g" .env.example.template > .env.example
    rm .env.example.template
    print_success "Created .env.example"
fi

# Process nginx default.conf
if [ -f "docker/nginx/default.conf.template" ]; then
    sed "s/{{SERVICE_NAME}}/$SERVICE_NAME/g" docker/nginx/default.conf.template > docker/nginx/default.conf
    rm docker/nginx/default.conf.template
    print_success "Created nginx default.conf"
fi

# Setup git repository and hooks
print_status "Initializing git repository..."
git init

# Copy git hooks
if [ -f ".git-hooks/pre-commit.template" ]; then
    mkdir -p .git/hooks
    sed "s/{{SERVICE_NAME}}/$SERVICE_NAME/g" .git-hooks/pre-commit.template > .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    rm -rf .git-hooks
    print_success "Created git pre-commit hook"
fi

# Create basic Laravel files
print_status "Creating basic Laravel files..."

# Create artisan file
cat > artisan << 'EOF'
#!/usr/bin/env php
<?php

define('LARAVEL_START', microtime(true));

// Register the Composer autoloader...
require __DIR__.'/vendor/autoload.php';

// Bootstrap Laravel and handle the command...
$app = require_once __DIR__.'/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);

$status = $kernel->handle(
    $input = new Symfony\Component\Console\Input\ArgvInput,
    new Symfony\Component\Console\Output\ConsoleOutput
);

$kernel->terminate($input, $status);

exit($status);
EOF
chmod +x artisan

# Create basic bootstrap files
mkdir -p bootstrap
cat > bootstrap/app.php << 'EOF'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Mvernon\CommonPackage\App\Middleware\AuthMiddleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        //web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        //commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'auth.jwt' => AuthMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
EOF

cat > bootstrap/providers.php << 'EOF'
<?php

return [
    App\Providers\AppServiceProvider::class,
];
EOF

# Create basic routes
mkdir -p routes
cat > routes/api.php << EOF
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::prefix('$SERVICE_NAME')->group(function () {
    Route::middleware('auth.jwt')->group(function () {

    });
});
EOF

cat > routes/web.php << 'EOF'
<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});
EOF

cat > routes/console.php << 'EOF'
<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');
EOF

# Create public/index.php
mkdir -p public
cat > public/index.php << 'EOF'
<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/../vendor/autoload.php';

// Bootstrap Laravel and handle the request...
(require_once __DIR__.'/../bootstrap/app.php')
    ->handleRequest(Request::capture());
EOF

# Create basic test files
mkdir -p tests/Feature tests/Unit

cat > tests/TestCase.php << 'EOF'
<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    //
}
EOF

cat > tests/Feature/ExampleTest.php << 'EOF'
<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }
}
EOF

cat > tests/Unit/ExampleTest.php << 'EOF'
<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    public function test_that_true_is_true(): void
    {
        $this->assertTrue(true);
    }
}
EOF

# Create basic app structure
mkdir -p app/Providers

cat > app/Providers/AppServiceProvider.php << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
EOF

print_success "Service $SERVICE_NAME created successfully!"
print_status "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. composer install"
echo "  3. cp .env.example .env <- !important"
echo "  4. php artisan key:generate"
echo "  5. docker compose up -d"
echo "  6. docker compose exec $SERVICE_NAME php artisan migrate"
echo ""
print_status "Ports assigned:"
echo "  - Nginx: http://localhost:$NGINX_PORT"
echo "  - PostgreSQL: localhost:$POSTGRES_PORT"
