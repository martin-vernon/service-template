# Quick Start Example

## Create a new service called "notification"

```bash
cd /Users/mart/Documents/dev/services/service-template
./setup-service.sh notification
```

This will create:
- Directory: `../notification-service`
- Nginx port: Auto-assigned (likely 8085)
- PostgreSQL port: Auto-assigned (likely 5435)

## Complete setup

```bash
cd ../notification-service

# Install dependencies
composer install

# Setup environment
cp .env.example .env
php artisan key:generate

# Start services
docker compose up -d

# Run migrations
docker compose exec notification php artisan migrate

# Test the service
curl http://localhost:8085
```

## Development workflow

```bash
# Format code
composer format

# Run tests
composer test

# Check git hooks work
echo "test" > test.php
git add test.php
git commit -m "test commit"  # This will trigger Laravel Pint
```

Your service is now ready for development with:
✅ Auto-formatting on save in VS Code  
✅ Pre-commit hooks for code quality  
✅ Docker containerization  
✅ Testing framework  
✅ Consistent structure with other services
