#!/bin/bash

# install_influx.sh
# Installs InfluxDB 2.0 OSS based on specific user guide

source ./utils.sh

init_log
print_header "InfluxDB 2.0 Installation"

check_root
check_internet

# Check if InfluxDB is already installed (multiple methods)
INFLUX_INSTALLED=false

# Method 1: Check if influx command exists
if command_exists influx; then
    INFLUX_INSTALLED=true
fi

# Method 2: Check if influxdb2 package is installed
if dpkg -s influxdb2 &> /dev/null; then
    INFLUX_INSTALLED=true
fi

# Method 3: Check if influxdb service exists and is active
if systemctl is-active --quiet influxdb 2>/dev/null; then
    INFLUX_INSTALLED=true
fi

if [ "$INFLUX_INSTALLED" = true ]; then
    log_success "InfluxDB is already installed."
    if command_exists influx; then
        influx version
    fi
    systemctl start influxdb 2>/dev/null || true
    systemctl enable influxdb 2>/dev/null || true
    exit 0
fi

# 1. Add InfluxData GPG Key
if [ -f /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg ]; then
    log_info "InfluxData GPG key already exists, skipping download..."
else
    log_info "Downloading and verifying InfluxData GPG key..."
    wget -q https://repos.influxdata.com/influxdata-archive_compat.key -O influxdata-archive_compat.key

    # Verify checksum as per guide
    echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c  influxdata-archive_compat.key' | sha256sum -c &> /dev/null

    if [ $? -eq 0 ]; then
        log_success "GPG Key checksum verified."
        cat influxdata-archive_compat.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
    else
        log_error "GPG Key checksum FAILED. Aborting."
        rm influxdata-archive_compat.key
        exit 1
    fi
    rm influxdata-archive_compat.key
fi

# 2. Add InfluxDB Repository
log_info "Adding InfluxDB repository..."
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | tee /etc/apt/sources.list.d/influxdata.list

# 3. Update and Install InfluxDB
log_info "Updating package lists..."
apt-get update > /dev/null 2>&1

log_info "Installing influxdb2..."
apt-get install -y influxdb2 &
PID=$!
show_spinner $PID
wait $PID

if [ $? -eq 0 ]; then
    log_success "InfluxDB 2 installed."
else
    log_error "Failed to install InfluxDB 2."
    exit 1
fi

# 4. Start the InfluxDB Service
log_info "Starting InfluxDB service..."
systemctl start influxdb
systemctl enable influxdb

if systemctl is-active --quiet influxdb; then
    log_success "InfluxDB service is running."
else
    log_error "InfluxDB service failed to start."
    exit 1
fi

# 5. Run the Initial Setup (Instruction)
print_header "Next Steps: Initial Setup"
log_warning "You MUST run the initial setup manually."
echo -e "${YELLOW}Run the following command in your terminal:${NC}"
echo -e "${GREEN}influx setup${NC}"
echo "Follow the prompts to create your primary user, organization, and bucket."
echo "UI Access: http://localhost:8086"
