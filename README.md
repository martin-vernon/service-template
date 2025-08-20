# Laravel Service Template

This is a boilerplate template for creating new Laravel 12 microservices that conform to the same design patterns used across your service architecture.

## Features

- **Laravel 12**: Latest Laravel framework
- **Docker Setup**: Complete containerization with PHP-FPM, Nginx, and PostgreSQL
- **Laravel Pint**: Code formatting with consistent rules
- **PHPUnit**: Testing framework setup
- **VS Code Config**: Development environment settings and recommended extensions
- **Git Hooks**: Pre-commit hooks for automatic code formatting
- **Auto Port Assignment**: Automatically finds available ports for new services

## Quick Start

### Create a New Service

```bash
cd service-template
./setup-service.sh my-new-service
```

This will:
1. Create a new directory `../my-new-service-service`
2. Copy all template files
3. Replace placeholders with service-specific values
4. Set up git repository with pre-commit hooks
5. Assign available ports automatically
6. Create basic Laravel structure

### Custom Ports

```bash
./setup-service.sh payment --nginx-port 8085 --db-port 5436
```

### Complete Setup

After running the setup script:

```bash
cd ../my-new-service-service
composer install
cp .env.example .env
php artisan key:generate
docker compose up -d
docker compose exec my-new-service php artisan migrate
```

## Template Structure

```
service-template/
├── .vscode/                    # VS Code configuration
│   ├── settings.json          # Editor settings with Pint integration
│   └── extensions.json        # Recommended extensions
├── .git-hooks/                # Git hooks templates
│   └── pre-commit.template    # Pre-commit hook for Laravel Pint
├── docker/                    # Docker configuration
│   ├── nginx/                 # Nginx container setup
│   └── php/                   # PHP-FPM container setup
├── app/                       # Laravel app structure
├── config/                    # Configuration directories
├── database/                  # Database structure
├── routes/                    # Route directories
├── tests/                     # Test directories
├── composer.json              # Dependencies with Pint & formatting scripts
├── pint.json                  # Laravel Pint configuration
├── phpunit.xml               # PHPUnit configuration
├── docker-compose.yml.template # Docker Compose with placeholders
├── .env.example.template      # Environment template
├── README.md.template         # Service README template
└── setup-service.sh          # Setup script
```

## What Gets Generated

When you create a new service, the following files are generated with service-specific values:

### Replaced Placeholders:
- `{{SERVICE_NAME}}`: The service name (e.g., "payment")
- `{{SERVICE_NAME_TITLE}}`: Title case (e.g., "Payment Service")
- `{{SERVICE_NAME_UPPER}}`: Upper case (e.g., "PAYMENT_SERVICE")
- `{{NGINX_PORT}}`: Assigned nginx port
- `{{POSTGRES_PORT}}`: Assigned PostgreSQL port

### Generated Files:
- `docker-compose.yml`: With correct service names and ports
- `.env.example`: With service-specific database configuration
- `README.md`: Service-specific documentation
- `docker/nginx/default.conf`: Nginx config with correct upstream
- `.git/hooks/pre-commit`: Git hook with correct Docker service name

## Consistency Features

All generated services will have:

✅ **Identical Laravel Pint configuration**  
✅ **Same VS Code settings and extensions**  
✅ **Consistent Docker setup patterns**  
✅ **Pre-commit hooks for code formatting**  
✅ **Standard composer scripts** (`format`, `format-check`, `format-diff`)  
✅ **Common directory structure**  
✅ **Unified testing setup**  

## Port Management

The setup script automatically assigns ports:
- **Nginx**: Starting from 8080, increments until available port found
- **PostgreSQL**: Starting from 5430, increments until available port found

Current service ports:
- auth-service: 8080, 5430
- rbac-service: 8081, 5431  
- security-service: 8082, 5432
- smr-service: 8083, 5433
- vehicle-service: 8084, 5434

## Development Workflow

After creating a service:

1. **Development**: Code with automatic formatting on save
2. **Commit**: Pre-commit hook runs Pint automatically
3. **Testing**: `composer test` or `docker compose exec <service> php artisan test`
4. **Manual Formatting**: `composer format` when needed

## Extending the Template

To add new features to all future services:

1. Modify files in `service-template/`
2. Add placeholder processing to `setup-service.sh` if needed
3. Update this README with new features

## Migration from Existing Services

To bring existing services up to this template standard:

1. Compare with template structure
2. Copy missing configuration files
3. Update composer.json scripts
4. Add git hooks
5. Standardize VS Code settings
