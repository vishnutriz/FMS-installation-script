#!/bin/bash

# setup_databases.sh
# Configures MongoDB and PostgreSQL databases for FMS system

source ./utils.sh

print_header "Database Setup for FMS System"

# Check if running as root
check_root

# Check if MongoDB and PostgreSQL are installed and running
log_info "Checking database services..."

if ! systemctl is-active --quiet mongod; then
    log_error "MongoDB is not running. Please install and start MongoDB first."
    log_info "Run: sudo ./install_mongo.sh"
    exit 1
fi

if ! systemctl is-active --quiet postgresql; then
    log_error "PostgreSQL is not running. Please install and start PostgreSQL first."
    log_info "Run: sudo ./install_postgres.sh"
    exit 1
fi

log_success "MongoDB and PostgreSQL services are running."

# Parse arguments
RUN_MONGO=true
RUN_POSTGRES=true
RUN_INFLUX=true

# If arguments are provided, set all to false and enable only requested
if [ $# -gt 0 ]; then
    RUN_MONGO=false
    RUN_POSTGRES=false
    RUN_INFLUX=false
    
    for arg in "$@"; do
        case $arg in
            --mongo) RUN_MONGO=true ;;
            --postgres) RUN_POSTGRES=true ;;
            --influx) RUN_INFLUX=true ;;
            --help) 
                echo "Usage: $0 [--mongo] [--postgres] [--influx]"
                echo "  --mongo     Configure MongoDB only"
                echo "  --postgres  Configure PostgreSQL only"
                echo "  --influx    Configure InfluxDB only"
                echo "  (no args)   Configure ALL"
                exit 0 
                ;;
        esac
    done
fi


#################################################################
# MONGODB CONFIGURATION
#################################################################

if [ "$RUN_MONGO" = true ]; then
    print_header "MongoDB Configuration"
    
    # Check if MongoDB authentication is already enabled
    log_info "Checking if MongoDB authentication is already configured..."
    AUTH_CHECK=$(mongosh --quiet --eval "db.adminCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers.length" 2>/dev/null || echo "0")

    if [ "$AUTH_CHECK" != "0" ] || grep -q "authorization: enabled" /etc/mongod.conf 2>/dev/null; then
        log_success "MongoDB authentication is already configured."
        echo ""
        echo -n "Do you want to reconfigure MongoDB? (y/n): "
        read -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping MongoDB configuration."
            SKIP_MONGO=true
        else
            SKIP_MONGO=false
        fi
    else
        SKIP_MONGO=false
    fi

    if [ "$SKIP_MONGO" = false ]; then
        # Prompt for MongoDB admin credentials
        echo ""
        log_info "Setting up MongoDB admin user (database-level authentication)"
        echo -n "Enter MongoDB admin username (default: admin): "
        read MONGO_ADMIN_USER
        MONGO_ADMIN_USER=${MONGO_ADMIN_USER:-admin}

        echo -n "Enter MongoDB admin password (default: password): "
        read -s MONGO_ADMIN_PASS
        echo ""
        MONGO_ADMIN_PASS=${MONGO_ADMIN_PASS:-password}

        # Create MongoDB admin user
        log_info "Creating MongoDB admin user..."
        mongosh --quiet --eval "
    try {
        db = db.getSiblingDB('admin');
        db.createUser({
            user: '${MONGO_ADMIN_USER}',
            pwd: '${MONGO_ADMIN_PASS}',
            roles: [
                { role: 'userAdminAnyDatabase', db: 'admin' },
                { role: 'readWriteAnyDatabase', db: 'admin' },
                { role: 'dbAdminAnyDatabase', db: 'admin' }
            ]
        });
        print('MongoDB admin user created successfully');
    } catch(e) {
        if (e.code === 51003) {
            print('MongoDB admin user already exists');
        } else {
            print('Error: ' + e.message);
            quit(1);
        }
    }
    " 2>&1 | grep -v "Current Mongosh Log ID"

        if [ $? -eq 0 ]; then
            log_success "MongoDB admin user configured."
        else
            log_error "Failed to create MongoDB admin user."
            exit 1
        fi

        # Setup superadmin user with predefined credentials
        echo ""
        log_info "Creating superadmin user with predefined credentials..."
        
        # Predefined superadmin credentials
        SUPERADMIN_EMAIL="admin@iotcore.com"
        SUPERADMIN_HASH='$2b$12$Nj5PfiWH5JSnG22v7fb4wObrhP2HcElnvZ/YNFV6hBab6IEKTr2pq'
        
        log_info "Superadmin email: ${SUPERADMIN_EMAIL}"
        log_info "Using predefined password hash"

        # Create MongoDB collections and initialize
        log_info "Initializing MongoDB collections..."
        mongosh --quiet "mongodb://${MONGO_ADMIN_USER}:${MONGO_ADMIN_PASS}@localhost:27017/?authSource=admin" --eval "
    try {
        db = db.getSiblingDB('iotcore_usermanagement');
        
        // Create collections if they don't exist
        const collections = ['users', 'customers', 'roles', 'sessions'];
        const existingCollections = db.getCollectionNames();
        
        collections.forEach(collName => {
            if (!existingCollections.includes(collName)) {
                db.createCollection(collName);
                print('Created collection: ' + collName);
            } else {
                print('Collection already exists: ' + collName);
            }
        });
        
        // Create SUPER_ADMIN role if it doesn't exist
        const superAdminRole = db.roles.findOne({ name: 'SUPER_ADMIN', is_deleted: false });
        if (!superAdminRole) {
            db.roles.insertOne({
                name: 'SUPER_ADMIN',
                description: 'Super Administrator with full system access',
                permissions: ['all'],
                is_deleted: false,
                created_at: new Date(),
                updated_at: new Date()
            });
            print('Created SUPER_ADMIN role');
        } else {
            print('SUPER_ADMIN role already exists');
        }
        
        print('MongoDB collections initialized successfully');
    } catch(e) {
        print('Error: ' + e.message);
        quit(1);
    }
    " 2>&1 | grep -v "Current Mongosh Log ID"

        if [ $? -ne 0 ]; then
            log_error "Failed to initialize MongoDB collections."
            exit 1
        fi

        log_success "Collections initialized."

        # Create superadmin user in MongoDB
        log_info "Creating superadmin user in iotcore_usermanagement database..."
        mongosh --quiet "mongodb://${MONGO_ADMIN_USER}:${MONGO_ADMIN_PASS}@localhost:27017/?authSource=admin" --eval "
    try {
        db = db.getSiblingDB('iotcore_usermanagement');
        
        // Check if user already exists
        const existingUser = db.users.findOne({ email: '${SUPERADMIN_EMAIL}' });
        if (existingUser) {
            print('Superadmin user already exists with email: ${SUPERADMIN_EMAIL}');
        } else {
            db.users.insertOne({
                email: '${SUPERADMIN_EMAIL}',
                password_hash: '${SUPERADMIN_HASH}',
                role: 'SUPER_ADMIN',
                customer_name: null,
                customer_id: null,
                deploymentIds: [],
                dashboardIds: [],
                zoneIds: [],
                status: 'active',
                created_at: new Date(),
                updated_at: new Date(),
                is_deleted: false
            });
            print('Superadmin user created successfully');
        }
    } catch(e) {
        print('Error: ' + e.message);
        quit(1);
    }
    " 2>&1 | grep -v "Current Mongosh Log ID"

        if [ $? -eq 0 ]; then
            log_success "Superadmin user configured."
        else
            log_error "Failed to create superadmin user."
            exit 1
        fi

        # Create ADMIN role if it doesn't exist
        log_info "Creating ADMIN role if it doesn't exist..."
        mongosh --quiet "mongodb://${MONGO_ADMIN_USER}:${MONGO_ADMIN_PASS}@localhost:27017/?authSource=admin" --eval "
    try {
        db = db.getSiblingDB('iotcore_usermanagement');
        
        // Create ADMIN role if it doesn't exist
        const adminRole = db.roles.findOne({ name: 'ADMIN', is_deleted: false });
        if (!adminRole) {
            db.roles.insertOne({
                name: 'ADMIN',
                description: 'Customer Administrator with customer-level access',
                permissions: [],
                customer_id: null,
                is_deleted: false,
                created_at: new Date(),
                updated_at: new Date()
            });
            print('Created ADMIN role');
        } else {
            print('ADMIN role already exists');
        }
    } catch(e) {
        print('Error: ' + e.message);
        quit(1);
    }
    " 2>&1 | grep -v "Current Mongosh Log ID"

        if [ $? -eq 0 ]; then
            log_success "ADMIN role configured."
        else
            log_error "Failed to create ADMIN role."
            exit 1
        fi

        # Prompt for customer details
        echo ""
        log_info "Setting up default customer and customer admin"
        echo "Please provide customer details:"
        echo ""

        echo -n "Enter company name: "
        read COMPANY_NAME
        if [ -z "$COMPANY_NAME" ]; then
            log_error "Company name cannot be empty."
            exit 1
        fi

        echo -n "Enter customer name (contact person): "
        read CUSTOMER_NAME
        if [ -z "$CUSTOMER_NAME" ]; then
            log_error "Customer name cannot be empty."
            exit 1
        fi

        echo -n "Enter contact email: "
        read CUSTOMER_EMAIL
        if [ -z "$CUSTOMER_EMAIL" ]; then
            log_error "Contact email cannot be empty."
            exit 1
        fi

        echo -n "Enter phone number (optional): "
        read CUSTOMER_PHONE

        echo -n "Enter address (optional): "
        read CUSTOMER_ADDRESS

        echo -n "Enter customer admin password: "
        read -s CUSTOMER_ADMIN_PASS
        echo ""
        if [ -z "$CUSTOMER_ADMIN_PASS" ]; then
            log_error "Customer admin password cannot be empty."
            exit 1
        fi

        # Generate customer_id using Node.js UUID
        log_info "Generating customer ID..."
        REAL_USER=${SUDO_USER:-$USER}
        REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
        
        CUSTOMER_ID=$(sudo -u "$REAL_USER" bash -c "source $REAL_HOME/.nvm/nvm.sh && node -e \"
        const crypto = require('crypto');
        console.log(crypto.randomUUID());
        \"" 2>&1)

        if [ -z "$CUSTOMER_ID" ] || [[ "$CUSTOMER_ID" == *"Error"* ]]; then
            log_error "Failed to generate customer ID."
            exit 1
        fi

        log_info "Generated customer ID: ${CUSTOMER_ID}"

        # Hash customer admin password
        log_info "Hashing customer admin password..."
        
        # Check if bcrypt is available
        if ! sudo -u "$REAL_USER" bash -c "source $REAL_HOME/.nvm/nvm.sh && node -e \"require('bcrypt')\"" 2>/dev/null; then
            log_warning "bcrypt not found. Installing bcrypt..."
            
            if sudo -u "$REAL_USER" bash -c "source $REAL_HOME/.nvm/nvm.sh && npm install -g bcrypt" >> "$LOG_FILE" 2>&1; then
                log_success "bcrypt installed successfully."
            else
                log_error "Failed to install bcrypt."
                exit 1
            fi
        fi
        
        CUSTOMER_ADMIN_HASH=$(sudo -u "$REAL_USER" bash -c "source $REAL_HOME/.nvm/nvm.sh && node -e \"
        const bcrypt = require('bcrypt');
        const hash = bcrypt.hashSync('${CUSTOMER_ADMIN_PASS}', 12);
        console.log(hash);
        \"" 2>&1)

        if [ -z "$CUSTOMER_ADMIN_HASH" ] || [[ "$CUSTOMER_ADMIN_HASH" == *"Error"* ]]; then
            log_error "Failed to hash customer admin password."
            exit 1
        fi
        
        log_success "Password hashed successfully."

        # Create customer record in MongoDB
        log_info "Creating customer record..."
        mongosh --quiet "mongodb://${MONGO_ADMIN_USER}:${MONGO_ADMIN_PASS}@localhost:27017/?authSource=admin" --eval "
    try {
        db = db.getSiblingDB('iotcore_usermanagement');
        
        // Check if customer already exists
        const existingCustomer = db.customers.findOne({ email: '${CUSTOMER_EMAIL}' });
        if (existingCustomer) {
            print('Customer with this email already exists');
        } else {
            db.customers.insertOne({
                customer_id: '${CUSTOMER_ID}',
                company_name: '${COMPANY_NAME}',
                customer_name: '${CUSTOMER_NAME}',
                email: '${CUSTOMER_EMAIL}',
                phone_number: '${CUSTOMER_PHONE}',
                address: '${CUSTOMER_ADDRESS}',
                theme_color: null,
                logo: null,
                status: 'active',
                is_deleted: false,
                created_at: new Date(),
                updated_at: new Date()
            });
            print('Customer created successfully');
        }
    } catch(e) {
        print('Error: ' + e.message);
        quit(1);
    }
    " 2>&1 | grep -v "Current Mongosh Log ID"

        if [ $? -eq 0 ]; then
            log_success "Customer record created."
        else
            log_error "Failed to create customer record."
            exit 1
        fi

        # Create customer admin user in MongoDB
        log_info "Creating customer admin user..."
        mongosh --quiet "mongodb://${MONGO_ADMIN_USER}:${MONGO_ADMIN_PASS}@localhost:27017/?authSource=admin" --eval "
    try {
        db = db.getSiblingDB('iotcore_usermanagement');
        
        // Check if user already exists
        const existingUser = db.users.findOne({ email: '${CUSTOMER_EMAIL}' });
        if (existingUser) {
            print('User with this email already exists');
        } else {
            db.users.insertOne({
                email: '${CUSTOMER_EMAIL}',
                password_hash: '${CUSTOMER_ADMIN_HASH}',
                role: 'ADMIN',
                customer_name: '${CUSTOMER_NAME}',
                customer_id: '${CUSTOMER_ID}',
                status: 'active',
                created_at: new Date(),
                updated_at: new Date(),
                is_deleted: false
            });
            print('Customer admin user created successfully');
        }
    } catch(e) {
        print('Error: ' + e.message);
        quit(1);
    }
    " 2>&1 | grep -v "Current Mongosh Log ID"

        if [ $? -eq 0 ]; then
            log_success "Customer admin user configured."
        else
            log_error "Failed to create customer admin user."
            exit 1
        fi


        # Enable MongoDB authentication
        log_info "Enabling MongoDB authentication..."
        MONGOD_CONF="/etc/mongod.conf"

        # Backup original config
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        cp "$MONGOD_CONF" "${MONGOD_CONF}.backup.${TIMESTAMP}"

        # Check if security section exists
        if grep -q "^security:" "$MONGOD_CONF"; then
            # Security section exists, update it
            sed -i '/^security:/,/^[a-z]/ s/^#*\s*authorization:.*/  authorization: enabled/' "$MONGOD_CONF"
            # If authorization line doesn't exist, add it
            if ! grep -q "authorization:" "$MONGOD_CONF"; then
                sed -i '/^security:/a\  authorization: enabled' "$MONGOD_CONF"
            fi
        else
            # Add security section
            echo "" >> "$MONGOD_CONF"
            echo "security:" >> "$MONGOD_CONF"
            echo "  authorization: enabled" >> "$MONGOD_CONF"
        fi

        log_success "MongoDB authentication enabled in config."

        # Restart MongoDB
        log_info "Restarting MongoDB service..."
        systemctl restart mongod
        sleep 3

        if systemctl is-active --quiet mongod; then
            log_success "MongoDB restarted successfully with authentication enabled."
        else
            log_error "MongoDB failed to restart. Check configuration."
            exit 1
        fi
    else
        log_info "MongoDB configuration skipped."
    fi
else
    log_info "Skipping MongoDB configuration (--mongo not specified)."
    SKIP_MONGO=true
fi

#################################################################
# POSTGRESQL SCHEMA IMPORT
#################################################################

if [ "$RUN_POSTGRES" = true ]; then
    print_header "PostgreSQL Schema Import"

    # Check for schema file
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    SCHEMA_FILE="${SCRIPT_DIR}/db_schemas/all_schemas.sql"

    if [ ! -f "$SCHEMA_FILE" ]; then
        log_error "Schema file not found: $SCHEMA_FILE"
        log_info "Please place your PostgreSQL dump in db_schemas/all_schemas.sql"
        exit 1
    fi

    # Check if databases already exist
    log_info "Checking for existing PostgreSQL databases..."
    EXISTING_DBS=$(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datname IN ('alerts', 'applications', 'dashboard', 'deployment', 'devices', 'missions', 'traffic_management');" | xargs)

    if [ -n "$EXISTING_DBS" ]; then
        log_warning "The following databases already exist: $EXISTING_DBS"
        echo ""
        echo -n "Do you want to drop and recreate these databases? (y/n): "
        read -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            IMPORT_PG=true
        else
            log_info "Skipping PostgreSQL schema import."
            IMPORT_PG=false
        fi
    else
        log_info "Found schema file: $SCHEMA_FILE"
        echo ""
        echo -n "Do you want to import PostgreSQL schemas now? (y/n): "
        read -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            IMPORT_PG=true
        else
            IMPORT_PG=false
        fi
    fi

    if [ "$IMPORT_PG" = true ]; then
        log_info "Importing PostgreSQL schemas..."
        log_warning "This may take a few minutes..."
        
        # Import as postgres superuser
        sudo -u postgres psql < "$SCHEMA_FILE" > /tmp/pg_import.log 2>&1
        
        if [ $? -eq 0 ]; then
            log_success "PostgreSQL schemas imported successfully."
        else
            log_warning "PostgreSQL import completed with warnings. Check /tmp/pg_import.log for details."
        fi
        
        # List created databases
        log_info "Databases created:"
        sudo -u postgres psql -c "\l" | grep -E "(alerts|applications|dashboard|deployment|devices|missions|traffic)" || true
    else
        log_info "PostgreSQL schema import skipped."
    fi
else
    log_info "Skipping PostgreSQL configuration (--postgres not specified)."
    IMPORT_PG=false
fi

#################################################################
# INFLUXDB CONFIGURATION
#################################################################

if [ "$RUN_INFLUX" = true ]; then
    print_header "InfluxDB Configuration"

    # Check if InfluxDB is installed and running
    if ! systemctl is-active --quiet influxdb; then
        log_warning "InfluxDB is not running. Skipping InfluxDB configuration."
        log_info "Run: sudo ./install_influx.sh"
        SKIP_INFLUX=true
    else
        SKIP_INFLUX=false
    fi

    if [ "$SKIP_INFLUX" = false ]; then
        # Check if InfluxDB is already configured
        log_info "Checking if InfluxDB is already configured..."
        INFLUX_CHECK=$(influx ping 2>/dev/null && influx bucket list 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            log_success "InfluxDB is already configured."
            echo ""
            echo -n "Do you want to reconfigure InfluxDB? (y/n): "
            read -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Skipping InfluxDB configuration."
                SKIP_INFLUX=true
            else
                SKIP_INFLUX=false
            fi
        fi
    fi

    if [ "$SKIP_INFLUX" = false ]; then
        # Check for existing metadata backup
        METADATA_FILE="${SCRIPT_DIR}/influxdb_backup/all_metadata.yml"
        
        if [ -f "$METADATA_FILE" ]; then
            echo ""
            log_info "Found InfluxDB metadata backup: ${METADATA_FILE}"
            echo -n "Do you want to restore from this backup? (y/n): "
            read -n 1 -r
            echo ""
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Restoring InfluxDB configuration from metadata..."
                
                # Prompt for admin credentials for restore
                echo -n "Enter InfluxDB admin username (default: admin): "
                read INFLUX_USER
                INFLUX_USER=${INFLUX_USER:-admin}

                echo -n "Enter InfluxDB admin password: "
                read -s INFLUX_PASS
                echo ""
                
                if [ -z "$INFLUX_PASS" ]; then
                    log_error "InfluxDB password cannot be empty."
                    exit 1
                fi

                echo -n "Enter organization name (default: trizlabz): "
                read INFLUX_ORG
                INFLUX_ORG=${INFLUX_ORG:-trizlabz}

                # Run initial setup first (required before applying template)
                log_info "Running initial InfluxDB setup..."
                influx setup \
                    --username "${INFLUX_USER}" \
                    --password "${INFLUX_PASS}" \
                    --org "${INFLUX_ORG}" \
                    --bucket "temp_initial_bucket" \
                    --retention 0d \
                    --force \
                    2>&1 | grep -v "Error: instance"

                # Apply metadata template
                log_info "Applying metadata template..."
                influx apply --file "$METADATA_FILE" --force 2>&1

                if [ $? -eq 0 ]; then
                    log_success "Metadata restored successfully."
                    INFLUX_BUCKET="device_core"  # From backup
                else
                    log_warning "Metadata restore had warnings. Check configuration."
                    INFLUX_BUCKET="device_core"
                fi

                # Generate new token
                log_info "Generating authentication token..."
                INFLUX_TOKEN=$(influx auth create \
                    --org "${INFLUX_ORG}" \
                    --all-access \
                    --description "Operator Token - Restored from backup" \
                    --json 2>/dev/null | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

                if [ -z "$INFLUX_TOKEN" ]; then
                    log_warning "Failed to create new token. Retrieving existing token..."
                    INFLUX_TOKEN=$(influx auth list --json 2>/dev/null | grep -o '"token":"[^"]*"' | head -1 | cut -d'"' -f4)
                fi

                # Save credentials
                CREDS_FILE="${SCRIPT_DIR}/.influx_credentials"
                cat > "$CREDS_FILE" <<EOF
# InfluxDB Credentials (Restored from backup)
# Generated: $(date)

INFLUX_URL=http://localhost:8086
INFLUX_ORG=${INFLUX_ORG}
INFLUX_BUCKET=${INFLUX_BUCKET}
INFLUX_USER=${INFLUX_USER}
INFLUX_TOKEN=${INFLUX_TOKEN}
EOF
                chmod 600 "$CREDS_FILE"
                log_success "Credentials saved to: ${CREDS_FILE}"
                
                SKIP_INFLUX_SETUP=true
            else
                SKIP_INFLUX_SETUP=false
            fi
        else
            SKIP_INFLUX_SETUP=false
        fi

        # If not restoring, do fresh setup
        if [ "$SKIP_INFLUX_SETUP" = false ]; then
            # Prompt for InfluxDB configuration
            echo ""
            log_info "Setting up InfluxDB organization, bucket, and admin user"
            echo -n "Enter InfluxDB admin username (default: admin): "
            read INFLUX_USER
            INFLUX_USER=${INFLUX_USER:-admin}

            echo -n "Enter InfluxDB admin password: "
            read -s INFLUX_PASS
            echo ""
            
            if [ -z "$INFLUX_PASS" ]; then
                log_error "InfluxDB password cannot be empty."
                exit 1
            fi

            echo -n "Enter organization name (default: trizlabz): "
            read INFLUX_ORG
            INFLUX_ORG=${INFLUX_ORG:-trizlabz}

            echo -n "Enter bucket name (default: device_core): "
            read INFLUX_BUCKET
            INFLUX_BUCKET=${INFLUX_BUCKET:-device_core}

            echo -n "Enter retention period in days (0 for infinite, default: 0): "
            read INFLUX_RETENTION
            INFLUX_RETENTION=${INFLUX_RETENTION:-0}

            # Run InfluxDB setup
            log_info "Running InfluxDB initial setup..."
            influx setup \
                --username "${INFLUX_USER}" \
                --password "${INFLUX_PASS}" \
                --org "${INFLUX_ORG}" \
                --bucket "${INFLUX_BUCKET}" \
                --retention ${INFLUX_RETENTION}d \
                --force \
                2>&1 | grep -v "Error: instance"

            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                log_success "InfluxDB setup completed."
            else
                log_warning "InfluxDB setup may have already been run. Continuing..."
            fi

            # Generate operator token with full permissions
            log_info "Generating authentication token..."
            INFLUX_TOKEN=$(influx auth create \
                --org "${INFLUX_ORG}"  \
                --all-access \
                --description "Operator Token - Generated by setup script" \
                --json 2>/dev/null | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

            if [ -z "$INFLUX_TOKEN" ]; then
                log_warning "Failed to create new token. Attempting to retrieve existing token..."
                INFLUX_TOKEN=$(influx auth list --json 2>/dev/null | grep -o '"token":"[^"]*"' | head -1 | cut -d'"' -f4)
            fi

            if [ -z "$INFLUX_TOKEN" ]; then
                log_error "Failed to generate or retrieve InfluxDB token."
                exit 1
            fi

            log_success "Authentication token generated."

            # Save credentials to file
            CREDS_FILE="${SCRIPT_DIR}/.influx_credentials"
            log_info "Saving credentials to file..."
            
            cat > "$CREDS_FILE" <<EOF
# InfluxDB Credentials
# Generated: $(date)

INFLUX_URL=http://localhost:8086
INFLUX_ORG=${INFLUX_ORG}
INFLUX_BUCKET=${INFLUX_BUCKET}
INFLUX_USER=${INFLUX_USER}
INFLUX_TOKEN=${INFLUX_TOKEN}
EOF

            chmod 600 "$CREDS_FILE"
            log_success "Credentials saved to: ${CREDS_FILE}"
        fi

        # Verify setup by listing buckets
        log_info "Verifying InfluxDB configuration..."
        if influx bucket list --org "${INFLUX_ORG}" &>/dev/null; then
            log_success "InfluxDB is configured and accessible."
        else
            log_warning "Could not verify InfluxDB configuration. Check manually."
        fi
    else
        log_info "InfluxDB configuration skipped."
    fi
else
    log_info "Skipping InfluxDB configuration (--influx not specified)."
    SKIP_INFLUX=true
fi

#################################################################
# SUMMARY
#################################################################

print_header "Database Setup Complete"
echo ""
log_success "MongoDB Configuration:"
echo "  Admin User: ${MONGO_ADMIN_USER}"
echo "  Connection String: mongodb://${MONGO_ADMIN_USER}:****@localhost:27017/?authSource=admin"
echo "  Database: iotcore_usermanagement"
echo "  Collections: users, customers, roles, sessions"
echo ""
echo "  Superadmin Email: ${SUPERADMIN_EMAIL}"
if [ -n "$CUSTOMER_ID" ]; then
    echo ""
    echo "  Customer ID: ${CUSTOMER_ID}"
    echo "  Company Name: ${COMPANY_NAME}"
    echo "  Customer Admin Email: ${CUSTOMER_EMAIL}"
fi
echo ""

log_success "PostgreSQL Configuration:"
echo "  Admin User: admin"
echo "  Schemas: See database list above"
echo ""

if [ "$SKIP_INFLUX" = false ] && [ -n "$INFLUX_TOKEN" ]; then
    log_success "InfluxDB Configuration:"
    echo "  URL: http://localhost:8086"
    echo "  Organization: ${INFLUX_ORG}"
    echo "  Bucket: ${INFLUX_BUCKET}"
    echo "  Admin User: ${INFLUX_USER}"
    echo "  Auth Token: ${INFLUX_TOKEN}"
    echo ""
    echo "  Credentials saved to: ${CREDS_FILE}"
    echo ""
fi

log_info "Update your application .env files with:"
echo ""
echo "MongoDB:"
echo "  MONGODB_URL=mongodb://${MONGO_ADMIN_USER}:${MONGO_ADMIN_PASS}@localhost:27017/iotcore_usermanagement?authSource=admin"
echo ""
if [ "$SKIP_INFLUX" = false ] && [ -n "$INFLUX_TOKEN" ]; then
    echo "InfluxDB:"
    echo "  INFLUX_URL=http://localhost:8086"
    echo "  INFLUX_ORG=${INFLUX_ORG}"
    echo "  INFLUX_BUCKET=${INFLUX_BUCKET}"
    echo "  INFLUX_TOKEN=${INFLUX_TOKEN}"
    echo ""
    echo "To view InfluxDB credentials later:"
    echo "  cat ${CREDS_FILE}"
fi
