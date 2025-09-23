# Service Management Scripts

This directory contains useful scripts for managing all microservices in the project.

## Scripts Available

### 1. `update-common-package.sh`
A simple, focused script that updates the `mvernon/common-package` dependency across all services.

**Usage:**
```bash
# From the services root directory (/Users/mart/Documents/dev/services)
./service-template/update-common-package.sh
```

**What it does:**
- Updates `mvernon/common-package` in all services that use it
- Provides colored output showing success/failure for each service  
- Shows a summary at the end
- Skips services that don't use the common-package

### 2. `manage-services.sh`
A comprehensive script with multiple service management commands.

**Usage:**
```bash
# From the services root directory (/Users/mart/Documents/dev/services)
./service-template/manage-services.sh [command]
```

**Available Commands:**

| Command | Description |
|---------|-------------|
| `update-common` | Update mvernon/common-package in all services |
| `composer-install` | Run composer install in all services |
| `composer-update` | Run composer update in all services |
| `clear-cache` | Clear Laravel cache in all services |
| `status` | Show git status for all services |
| `pull` | Pull latest changes for all services |
| `list-services` | List all available services |
| `check-deps` | Check common-package dependency versions |
| `help` | Show help message |

**Examples:**
```bash
# Update common package across all services
./service-template/manage-services.sh update-common

# Install dependencies in all services
./service-template/manage-services.sh composer-install

# Check which services need updates
./service-template/manage-services.sh check-deps

# Clear cache in all services
./service-template/manage-services.sh clear-cache

# Show git status for all services
./service-template/manage-services.sh status
```

## Services Managed

Both scripts work with these services:
- audit-service
- auth-service  
- rbac-service
- dealers-service
- vehicle-service
- smr-service
- customers-service
- security-service

## Prerequisites

- Run scripts from the services root directory (where all service folders exist)
- Ensure you have composer installed and accessible via `composer` command
- For git commands, ensure you have git installed and configured

## Features

### Colored Output
Both scripts provide colored terminal output:
- 🔵 Blue: Information messages
- 🟢 Green: Success messages  
- 🟡 Yellow: Warning messages
- 🔴 Red: Error messages

### Error Handling
- Scripts will continue processing other services even if one fails
- Clear error reporting for troubleshooting
- Summary reports show which services succeeded/failed

### Smart Detection
- Automatically detects which services use common-package
- Skips services that don't exist or don't use the package
- Checks for required files before attempting operations

## Quick Setup

To copy these scripts to your services root directory:

```bash
# From the services root directory
cp service-template/update-common-package.sh .
cp service-template/manage-services.sh .

# Make them executable
chmod +x update-common-package.sh
chmod +x manage-services.sh

# Run them
./update-common-package.sh
# or
./manage-services.sh update-common
```

## Troubleshooting

### "Please run this script from the services root directory"
Make sure you're in the directory that contains all your service folders and the `common-package` folder.

### "Failed to update [service]"
- Check if the service directory exists
- Verify composer.json is valid
- Ensure you have network connectivity for composer
- Check file permissions

### Services Not Found
If a service is listed as missing, either:
- The service directory doesn't exist
- You're not in the correct root directory
- The service name in the script doesn't match your actual folder name

## Customization

You can easily modify the `SERVICES` array in either script to add/remove services:

```bash
SERVICES=(
    "audit-service"
    "auth-service" 
    "your-new-service"
    # Add more services here
)
```