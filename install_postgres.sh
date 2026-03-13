#!/bin/bash

# install_postgres.sh
# Installs PostgreSQL

source ./utils.sh

init_log
print_header "PostgreSQL Installation"

check_root
check_internet

# Check if PostgreSQL is already installed (multiple methods)
POSTGRES_INSTALLED=false

# Method 1: Check if psql command exists
if command_exists psql; then
    POSTGRES_INSTALLED=true
fi

# Method 2: Check if postgresql package is installed
if dpkg -s postgresql &> /dev/null; then
    POSTGRES_INSTALLED=true
fi

# Method 3: Check if postgresql service exists and is active
if systemctl is-active --quiet postgresql 2>/dev/null; then
    POSTGRES_INSTALLED=true
fi

if [ "$POSTGRES_INSTALLED" = true ]; then
    log_success "PostgreSQL is already installed."
    if command_exists psql; then
        psql --version
    fi
    systemctl start postgresql 2>/dev/null || true
    systemctl enable postgresql 2>/dev/null || true
    exit 0
fi

# 1. Update & Install
log_info "Updating package lists..."
apt-get update > /dev/null 2>&1

log_info "Installing PostgreSQL and contrib packages..."
apt-get install -y postgresql postgresql-contrib &
PID=$!
show_spinner $PID
wait $PID

if [ $? -eq 0 ]; then
    log_success "PostgreSQL installed."
else
    log_error "Failed to install PostgreSQL."
    exit 1
fi

# 2. Start & Enable
log_info "Ensuring PostgreSQL service is running..."
systemctl start postgresql
systemctl enable postgresql

if systemctl is-active --quiet postgresql; then
    log_success "PostgreSQL service is active."
else
    log_error "PostgreSQL service failed to start."
    exit 1
fi

# 3. Configure Remote Access
log_info "Configuring PostgreSQL for remote access..."

# Detect PostgreSQL version and config path
PG_VERSION=$(psql --version | awk '{print $3}' | cut -d. -f1)
PG_CONF_DIR="/etc/postgresql/${PG_VERSION}/main"
PG_CONF="${PG_CONF_DIR}/postgresql.conf"
PG_HBA="${PG_CONF_DIR}/pg_hba.conf"

if [ ! -f "$PG_CONF" ]; then
    log_error "PostgreSQL config not found at $PG_CONF"
    exit 1
fi

# Backup configs with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp "$PG_CONF" "${PG_CONF}.backup.${TIMESTAMP}"
cp "$PG_HBA" "${PG_HBA}.backup.${TIMESTAMP}"
log_success "Configuration files backed up with timestamp ${TIMESTAMP}."

# Modify postgresql.conf to listen on all addresses
if grep -q "^listen_addresses" "$PG_CONF"; then
    sed -i "s/^listen_addresses.*/listen_addresses = '*'/" "$PG_CONF"
else
    echo "listen_addresses = '*'" >> "$PG_CONF"
fi
log_success "Set listen_addresses = '*' in postgresql.conf"

# Add admin user entry to pg_hba.conf
if ! grep -q "host.*all.*admin.*0.0.0.0/0.*md5" "$PG_HBA"; then
    echo "" >> "$PG_HBA"
    echo "# Allow connections from any IP address for the 'admin' user" >> "$PG_HBA"
    echo "host    all             admin           0.0.0.0/0               md5" >> "$PG_HBA"
    log_success "Added admin user entry to pg_hba.conf"
else
    log_info "Admin user entry already exists in pg_hba.conf"
fi

# Restart PostgreSQL to apply changes
log_info "Restarting PostgreSQL service..."
systemctl restart postgresql

if systemctl is-active --quiet postgresql; then
    log_success "PostgreSQL restarted successfully."
else
    log_error "PostgreSQL failed to restart."
    exit 1
fi

# 4. Create Admin User
log_info "Creating 'admin' user..."
sudo -u postgres psql -c "SELECT 1 FROM pg_roles WHERE rolname='admin'" | grep -q 1
if [ $? -eq 0 ]; then
    log_info "User 'admin' already exists."
else
    sudo -u postgres psql -c "CREATE USER admin WITH PASSWORD 'password';" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log_success "User 'admin' created with password 'password'."
        # Grant superuser privileges
        sudo -u postgres psql -c "ALTER USER admin WITH SUPERUSER;" > /dev/null 2>&1
        log_success "Granted SUPERUSER privileges to admin."
    else
        log_error "Failed to create admin user."
        exit 1
    fi
fi

# 5. Info
log_info "Default user 'postgres' created."
log_info "Access prompt via: sudo -u postgres psql"
log_success "Admin user: admin / password: password"


