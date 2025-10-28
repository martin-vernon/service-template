#!/bin/bash

# Service Management Script
# Collection of useful commands for managing all services
# Run this from the root services directory (/Users/mart/Documents/dev/services)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# List of services
SERVICES=(
    "audit-service"
    "auth-service"
    "customers-service"
    "dashboard-service"
    "dealers-service"
    "quote-service"
    "rbac-service"
    "security-service"
    "smr-service"
    "vehicle-service"
)

# Function to show help
show_help() {
    print_header "=== Service Management Script ==="
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  update-common        Update mvernon/common-package in all services"
    echo "  composer-install     Run composer install in all services"
    echo "  composer-update      Run composer update in all services"
    echo "  clear-cache         Clear Laravel cache in all services"
    echo "  update-github-token <token>  Update GITHUB_OAUTH_TOKEN in all services' .env files and clear config cache in running containers"
    echo "  status              Show git status for all services"
    echo "  pull               Pull latest changes for all services"
    echo "  list-services       List all available services"
    echo "  check-deps          Check common-package dependency versions"
    echo "  help                Show this help message"
    echo ""
    echo "Example:"
    echo "  ./manage-services.sh update-common"
    echo "  ./manage-services.sh composer-install"
    echo ""
}

# Function to check if we're in the right directory
check_directory() {
    if [ ! -d "common-package" ]; then
        print_error "Please run this script from the services root directory (where common-package folder exists)"
        exit 1
    fi
}

# Function to update common package
update_common_package() {
    print_header "=== Updating Common Package Across All Services ==="
    echo ""

    declare -a successful_updates=()
    declare -a failed_updates=()

    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ]; then
            print_status "Updating $service..."

            if cd "$service"; then
                if [ -f "composer.json" ] && grep -q "mvernon/common-package" composer.json; then
                    if composer update mvernon/common-package --no-interaction; then
                        print_success "✓ $service updated successfully"
                        successful_updates+=("$service")
                    else
                        print_error "✗ Failed to update $service"
                        failed_updates+=("$service")
                    fi
                else
                    print_warning "⚠ $service does not use common-package, skipping..."
                fi
                cd ..
            else
                print_error "✗ Could not enter $service directory"
                failed_updates+=("$service")
            fi
            echo ""
        else
            print_warning "⚠ Service directory $service not found, skipping..."
        fi
    done

    # Print summary
    echo "============================================"
    print_status "UPDATE SUMMARY"
    echo "============================================"

    if [ ${#successful_updates[@]} -gt 0 ]; then
        print_success "Successfully updated ${#successful_updates[@]} services:"
        for service in "${successful_updates[@]}"; do
            echo "  ✓ $service"
        done
    fi

    if [ ${#failed_updates[@]} -gt 0 ]; then
        print_error "Failed to update ${#failed_updates[@]} services:"
        for service in "${failed_updates[@]}"; do
            echo "  ✗ $service"
        done
    else
        print_success "All services updated successfully! 🎉"
    fi
}

# Function to run composer install
composer_install() {
    print_header "=== Running Composer Install Across All Services ==="
    echo ""

    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ]; then
            print_status "Installing dependencies for $service..."
            if cd "$service" && composer install --no-interaction; then
                print_success "✓ $service dependencies installed"
            else
                print_error "✗ Failed to install dependencies for $service"
            fi
            cd ..
            echo ""
        fi
    done
}

# Function to run composer update
composer_update() {
    print_header "=== Running Composer Update Across All Services ==="
    echo ""

    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ]; then
            print_status "Updating dependencies for $service..."
            if cd "$service" && composer update --no-interaction; then
                print_success "✓ $service dependencies updated"
            else
                print_error "✗ Failed to update dependencies for $service"
            fi
            cd ..
            echo ""
        fi
    done
}

# Function to clear Laravel cache
clear_cache() {
    print_header "=== Clearing Laravel Cache Across All Services ==="
    echo ""

    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ]; then
            print_status "Clearing cache for $service..."
            if cd "$service"; then
                php artisan config:clear >/dev/null 2>&1 || true
                php artisan cache:clear >/dev/null 2>&1 || true
                php artisan route:clear >/dev/null 2>&1 || true
                php artisan view:clear >/dev/null 2>&1 || true
                print_success "✓ $service cache cleared"
            fi
            cd ..
        fi
    done
}

# Function to show git status
git_status() {
    print_header "=== Git Status Across All Services ==="
    echo ""

    for service in "${SERVICES[@]}" "common-package"; do
        if [ -d "$service" ]; then
            print_status "Git status for $service:"
            if cd "$service"; then
                git status --porcelain
                if [ $? -eq 0 ]; then
                    echo "  (clean)"
                fi
            fi
            cd ..
            echo ""
        fi
    done
}

# Function to pull latest changes
git_pull() {
    print_header "=== Pulling Latest Changes Across All Services ==="
    echo ""

    for service in "${SERVICES[@]}" "common-package"; do
        if [ -d "$service" ]; then
            print_status "Pulling changes for $service..."
            if cd "$service" && git pull; then
                print_success "✓ $service updated"
            else
                print_error "✗ Failed to pull changes for $service"
            fi
            cd ..
            echo ""
        fi
    done
}

# Function to list services
list_services() {
    print_header "=== Available Services ==="
    echo ""

    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ]; then
            print_success "✓ $service (exists)"
        else
            print_warning "✗ $service (missing)"
        fi
    done

    echo ""
    print_status "Common package:"
    if [ -d "common-package" ]; then
        print_success "✓ common-package (exists)"
    else
        print_error "✗ common-package (missing)"
    fi
}

# Function to check dependency versions
check_deps() {
    print_header "=== Checking Common Package Dependency Versions ==="
    echo ""

    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ] && [ -f "$service/composer.json" ]; then
            print_status "Checking $service..."
            cd "$service"
            if grep -q "mvernon/common-package" composer.json; then
                version=$(grep "mvernon/common-package" composer.json | sed 's/.*: *"\([^"]*\)".*/\1/')
                echo "  Current version: $version"

                # Check if vendor directory exists and show installed version
                if [ -d "vendor/mvernon/common-package" ]; then
                    if [ -f "composer.lock" ]; then
                        installed_version=$(grep -A 5 '"name": "mvernon/common-package"' composer.lock | grep '"version"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "unknown")
                        echo "  Installed version: $installed_version"
                    fi
                else
                    print_warning "  Package not installed"
                fi
            else
                echo "  Does not use common-package"
            fi
            cd ..
            echo ""
        fi
    done
}

# Function to update GitHub OAuth token across all services and clear config cache in running containers
update_github_token() {
    local NEW_TOKEN="$1"

    if [ -z "$NEW_TOKEN" ]; then
        print_error "Usage: $0 update-github-token <new_token>"
        exit 1
    fi

    print_header "=== Updating GITHUB_OAUTH_TOKEN Across All Services ==="
    echo ""

    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ]; then
            print_status "Updating token in $service/.env..."
            if [ -f "$service/.env" ]; then
                # Update or insert the token line
                if grep -q '^GITHUB_OAUTH_TOKEN=' "$service/.env"; then
                    sed -i '' "s/^GITHUB_OAUTH_TOKEN=.*/GITHUB_OAUTH_TOKEN=$NEW_TOKEN/" "$service/.env"
                else
                    echo "GITHUB_OAUTH_TOKEN=$NEW_TOKEN" >> "$service/.env"
                fi
                print_success "✓ Updated $service/.env"
            else
                print_warning "⚠ $service/.env not found; skipping file update"
            fi

            # Also update docker-compose build arg if present in Dockerfile build args via .env (handled by env)

            # If a container for this service is running, exec into it and clear config cache
            # Determine main PHP container name from docker-compose service names
            local container_name=""
            case "$service" in
                auth-service) container_name="auth" ;;
                rbac-service) container_name="rbac" ;;
                security-service) container_name="security" ;;
                dealers-service) container_name="dealers" ;;
                vehicle-service) container_name="vehicles" ;;
                smr-service) container_name="smr" ;;
                customers-service) container_name="customers" ;;
                audit-service) container_name="audit" ;;
                *) container_name="" ;;
            esac

            if [ -n "$container_name" ]; then
                # Use Docker Compose labels to find running containers for this service
                # 1) Try with project label (most precise)
                local project_label="$service"
                local containers
                containers=$(docker ps -q \
                    --filter "label=com.docker.compose.service=${container_name}" \
                    --filter "label=com.docker.compose.project=${project_label}")

                # 2) Fallback: any project, match by service label only
                if [ -z "$containers" ]; then
                    containers=$(docker ps -q --filter "label=com.docker.compose.service=${container_name}")
                fi

                # Also look for corresponding worker containers (service-name with -worker suffix)
                local worker_service="${container_name}-worker"
                local worker_containers
                worker_containers=$(docker ps -q \
                    --filter "label=com.docker.compose.service=${worker_service}" \
                    --filter "label=com.docker.compose.project=${project_label}")
                if [ -z "$worker_containers" ]; then
                    worker_containers=$(docker ps -q --filter "label=com.docker.compose.service=${worker_service}")
                fi

                if [ -n "$containers$worker_containers" ]; then
                    for cid in $containers $worker_containers; do
                        [ -z "$cid" ] && continue
                        print_status "Clearing config cache in container ${cid}..."
                        docker exec -i "$cid" php artisan config:clear >/dev/null 2>&1 || true
                        docker exec -i "$cid" php artisan config:cache >/dev/null 2>&1 || true
                    done
                    print_success "✓ Cleared and rebuilt config cache in running containers for '${container_name}' (and worker if present)"
                else
                    print_warning "⚠ No running containers found for '${container_name}' (or worker) — skipping cache clear"
                fi
            else
                print_warning "⚠ No known container mapping for $service; skipping cache clear"
            fi

            echo ""
        else
            print_warning "⚠ Service directory $service not found, skipping..."
        fi
    done

    print_success "All done. If some services run with build args, you may need to rebuild images to propagate the token into build-time context."
}

# Main script logic
check_directory

case "${1:-help}" in
    "update-common")
        update_common_package
        ;;
    "composer-install")
        composer_install
        ;;
    "composer-update")
        composer_update
        ;;
    "clear-cache")
        clear_cache
        ;;
    "status")
        git_status
        ;;
    "pull")
        git_pull
        ;;
    "list-services")
        list_services
        ;;
    "check-deps")
        check_deps
        ;;
    "update-github-token")
        shift || true
        update_github_token "$1"
        ;;
    "help"|*)
        show_help
        ;;
esac
