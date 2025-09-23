#!/bin/bash

# Update Common Package Script
# This script updates the mvernon/common-package dependency across all services
# Run this from the root services directory (/Users/mart/Documents/dev/services)

set -e  # Exit on any error

# Colors for output
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

# Check if we're in the right directory
if [ ! -d "common-package" ]; then
    print_error "Please run this script from the services root directory (where common-package folder exists)"
    exit 1
fi

# List of services to update
SERVICES=(
    "audit-service"
    "auth-service" 
    "rbac-service"
    "dealers-service"
    "vehicle-service"
    "smr-service"
    "customers-service"
    "security-service"
)

print_status "Starting common-package update across all services..."
echo ""

# Track success/failure
declare -a successful_updates=()
declare -a failed_updates=()

# Update each service
for service in "${SERVICES[@]}"; do
    if [ -d "$service" ]; then
        print_status "Updating $service..."
        
        if cd "$service"; then
            # Check if composer.json exists and contains common-package
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
    echo ""
fi

if [ ${#failed_updates[@]} -gt 0 ]; then
    print_error "Failed to update ${#failed_updates[@]} services:"
    for service in "${failed_updates[@]}"; do
        echo "  ✗ $service"
    done
    echo ""
    print_warning "You may need to manually check and update the failed services."
else
    print_success "All services updated successfully! 🎉"
fi

echo "============================================"
print_status "Update process completed."