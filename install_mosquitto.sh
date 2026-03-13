#!/bin/bash

# install_mosquitto.sh
# Installs Mosquitto MQTT Broker via Official PPA

source ./utils.sh

init_log
print_header "Mosquitto MQTT Installation (Official PPA)"

check_root
check_internet

# Ensure add-apt-repository is available
if ! command -v add-apt-repository &> /dev/null; then
    log_info "Installing software-properties-common..."
    apt-get update > /dev/null 2>&1
    apt-get install -y software-properties-common
fi

# Check if Mosquitto is already installed (multiple methods)
MOSQUITTO_INSTALLED=false

# Method 1: Check if mosquitto command exists
if command_exists mosquitto; then
    MOSQUITTO_INSTALLED=true
fi

# Method 2: Check if mosquitto package is installed
if dpkg -s mosquitto &> /dev/null; then
    MOSQUITTO_INSTALLED=true
fi

# Method 3: Check if mosquitto service exists and is active
if systemctl is-active --quiet mosquitto 2>/dev/null; then
    MOSQUITTO_INSTALLED=true
fi

if [ "$MOSQUITTO_INSTALLED" = true ]; then
    log_success "Mosquitto is already installed."
    if command_exists mosquitto; then
        mosquitto -h | head -n 1
    fi
    systemctl start mosquitto 2>/dev/null || true
    systemctl enable mosquitto 2>/dev/null || true
    exit 0
fi

# 1. Add Mosquitto PPA
log_info "Adding Mosquitto PPA (ppa:mosquitto-dev/mosquitto-ppa)..."
# -y flag automatically confirms prompts
add-apt-repository -y ppa:mosquitto-dev/mosquitto-ppa
if [ $? -eq 0 ]; then
    log_success "Mosquitto PPA added."
else
    log_error "Failed to add Mosquitto PPA."
    exit 1
fi

# 2. Update Package Lists
log_info "Updating package lists..."
apt-get update > /dev/null 2>&1

# 3. Install Mosquitto
log_info "Installing Mosquitto and clients..."
apt-get install -y mosquitto mosquitto-clients &
PID=$!
show_spinner $PID
wait $PID

if [ $? -eq 0 ]; then
    log_success "Mosquitto installed."
else
    log_error "Failed to install Mosquitto."
    exit 1
fi

# 4. Configure mosquitto.conf with TLS settings
log_info "Configuring Mosquitto for TLS/SSL..."

# Detect current IP address
CURRENT_IP=$(hostname -I | awk '{print $1}')
if [ -z "$CURRENT_IP" ]; then
    CURRENT_IP="0.0.0.0"
fi

# Prompt user for listener bind address
echo ""
log_info "Mosquitto needs to be configured with a listener bind address."
log_info "This IP will be used to bind the MQTT listener."
log_info "Detected IP address: $CURRENT_IP"
echo -n "Enter listener bind address (press Enter for $CURRENT_IP): "
read USER_IP

# Use detected IP if user didn't provide one
if [ -z "$USER_IP" ]; then
    BIND_IP="$CURRENT_IP"
else
    BIND_IP="$USER_IP"
fi

log_info "Configuring Mosquitto with listener on $BIND_IP:8883"

# Backup original mosquitto.conf
MOSQUITTO_CONF="/etc/mosquitto/mosquitto.conf"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp "$MOSQUITTO_CONF" "${MOSQUITTO_CONF}.backup.${TIMESTAMP}"
log_success "Backup created: ${MOSQUITTO_CONF}.backup.${TIMESTAMP}"

# Create new mosquitto.conf with TLS configuration
cat > "$MOSQUITTO_CONF" <<EOF
# Place your local configuration in /etc/mosquitto/conf.d/
#
# A full description of the configuration file is at
# /usr/share/doc/mosquitto/examples/mosquitto.conf.example

################################################################
# MOSQUITTO CONFIGURATION WITH TLS/SSL
################################################################

pid_file /run/mosquitto/mosquitto.pid

persistence true
persistence_location /var/lib/mosquitto/

log_dest file /var/log/mosquitto/mosquitto.log

include_dir /etc/mosquitto/conf.d

# TLS listener on port 8883 bound to specific IP
listener 8883 $BIND_IP

# TLS certificate configuration
cafile /etc/mosquitto/certs/ca.crt
certfile /etc/mosquitto/certs/broker.crt
keyfile /etc/mosquitto/certs/broker.key
require_certificate true

# Authentication settings
allow_anonymous false
use_identity_as_username true
EOF

log_success "Mosquitto configuration updated successfully."

# 5. Copy certificates from local folder
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CERT_SOURCE_DIR="${SCRIPT_DIR}/mosquitto_certs"

log_info "Setting up SSL/TLS certificates..."

# Create certificate directory
mkdir -p /etc/mosquitto/certs
chmod 755 /etc/mosquitto/certs

# Check if certificate source directory exists
if [ ! -d "$CERT_SOURCE_DIR" ]; then
    log_error "Certificate source directory not found: $CERT_SOURCE_DIR"
    log_info "Please create the directory and place your certificates there."
    exit 1
fi

# Check for required certificate files
MISSING_CERTS=false
if [ ! -f "$CERT_SOURCE_DIR/ca.crt" ]; then
    log_error "Missing certificate: ca.crt"
    MISSING_CERTS=true
fi

if [ ! -f "$CERT_SOURCE_DIR/broker.crt" ]; then
    log_error "Missing certificate: broker.crt"
    MISSING_CERTS=true
fi

if [ ! -f "$CERT_SOURCE_DIR/broker.key" ]; then
    log_error "Missing certificate: broker.key"
    MISSING_CERTS=true
fi

if [ "$MISSING_CERTS" = true ]; then
    log_error "Please place all required certificates in: $CERT_SOURCE_DIR"
    log_info "Required files: ca.crt, broker.crt, broker.key"
    exit 1
fi

# Copy certificates
log_info "Copying certificates from $CERT_SOURCE_DIR..."
cp "$CERT_SOURCE_DIR/ca.crt" /etc/mosquitto/certs/
cp "$CERT_SOURCE_DIR/broker.crt" /etc/mosquitto/certs/
cp "$CERT_SOURCE_DIR/broker.key" /etc/mosquitto/certs/

# Set appropriate permissions
chmod 644 /etc/mosquitto/certs/ca.crt
chmod 644 /etc/mosquitto/certs/broker.crt
chmod 600 /etc/mosquitto/certs/broker.key  # Private key should be read-only by owner
chown mosquitto:mosquitto /etc/mosquitto/certs/*

log_success "Certificates copied and permissions set successfully."

# 6. Restart Mosquitto service
log_info "Restarting Mosquitto service..."
systemctl restart mosquitto 2>/dev/null

# Wait a moment for service to start
sleep 2

# Check Service Status
log_info "Checking Mosquitto service..."
if systemctl is-active --quiet mosquitto; then
    log_success "Mosquitto service is active (running)."
else
    log_warning "Mosquitto service is NOT running."
    log_warning "This is expected if certificates are not yet installed."
    log_info "The service will start once you add the required certificates."
fi


# 7. Installation Summary
print_header "Installation Complete"
log_success "Mosquitto has been configured with TLS/SSL."
echo ""
print_header "Configuration Summary"
log_info "Listener: $BIND_IP:8883"
log_info "TLS/SSL: Enabled with client certificate authentication"
log_info "Anonymous access: Disabled"
log_info "Certificates: Copied from $CERT_SOURCE_DIR"
log_info "Certificate location: /etc/mosquitto/certs"
echo ""
log_info "Mosquitto service is running and ready to accept secure connections."


