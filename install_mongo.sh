#!/bin/bash

# install_mongo.sh
# Installs MongoDB 7.0 Community Edition

source ./utils.sh

init_log
print_header "MongoDB 7.0 Installation"

check_root
check_internet

# Check if MongoDB is already installed (multiple methods)
MONGO_INSTALLED=false

# Method 1: Check if mongod command exists
if command_exists mongod; then
    MONGO_INSTALLED=true
fi

# Method 2: Check if mongod binary exists in standard locations
if [ -f "/usr/bin/mongod" ] || [ -f "/usr/local/bin/mongod" ]; then
    MONGO_INSTALLED=true
fi

# Method 3: Check if mongodb-org package is installed
if dpkg -s mongodb-org &> /dev/null; then
    MONGO_INSTALLED=true
fi

# Method 4: Check if mongod service exists and is active
if systemctl is-active --quiet mongod 2>/dev/null; then
    MONGO_INSTALLED=true
fi

if [ "$MONGO_INSTALLED" = true ]; then
    log_success "MongoDB is already installed."
    if command_exists mongod; then
        mongod --version | head -n 1
    else
        /usr/bin/mongod --version 2>/dev/null | head -n 1 || echo "MongoDB binary found but version check failed"
    fi
    # Ensure service is running
    systemctl start mongod 2>/dev/null || true
    systemctl enable mongod 2>/dev/null || true
    exit 0
fi

# 1. Import Public Key
log_info "Importing MongoDB public GPG key..."
apt-get install -y gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg --yes &
PID=$!
show_spinner $PID
wait $PID

if [ $? -eq 0 ]; then
    log_success "GPG key imported."
else
    log_error "Failed to import GPG key."
    exit 1
fi

# 2. Create Sources List
log_info "Adding MongoDB repository..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# 3. Update & Install
log_info "Updating package lists..."
apt-get update > /dev/null 2>&1

log_info "Installing MongoDB packages..."
apt-get install -y mongodb-org &
PID=$!
show_spinner $PID
wait $PID

if [ $? -eq 0 ]; then
    log_success "MongoDB installed."
else
    log_error "Failed to install MongoDB."
    exit 1
fi

# 4. Start & Enable
log_info "Starting MongoDB service..."
systemctl start mongod
systemctl enable mongod

if systemctl is-active --quiet mongod; then
    log_success "MongoDB service is running."
else
    log_error "MongoDB service failed to start."
    exit 1
fi

log_info "You can connect using 'mongosh'."
