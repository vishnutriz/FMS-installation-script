#!/bin/bash

# install_influx.sh
# Installs InfluxDB 2.0 OSS based on official InfluxData guidelines

source ./utils.sh

init_log
print_header "InfluxDB 2.0 Installation"

check_root
check_internet

# Check if InfluxDB is already installed
INFLUX_INSTALLED=false
if command_exists influx || dpkg -s influxdb2 &> /dev/null; then
    INFLUX_INSTALLED=true
fi

if [ "$INFLUX_INSTALLED" = true ]; then
    log_success "InfluxDB is already installed."
    systemctl start influxdb 2>/dev/null || true
    systemctl enable influxdb 2>/dev/null || true
    exit 0
fi

# Ensure curl is installed (needed for the doc pipeline)
if ! command_exists curl; then
    log_info "curl not found. Installing curl..."
    apt-get update > /dev/null
    apt-get install -y curl
fi

# Ensure gpg is installed
if ! command_exists gpg; then
    log_info "gnupg not found. Installing gnupg..."
    apt-get update > /dev/null
    apt-get install -y gnupg
fi

# 1. Official InfluxData Installation Pipeline
log_info "Running official InfluxData installation pipeline..."
mkdir -p /etc/apt/keyrings

# Remove old keys/repo to ensure a clean run
rm -f /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg
rm -f /etc/apt/keyrings/influxdata-archive.gpg
rm -f /etc/apt/sources.list.d/influxdata.list

# Exact command sequence from documentation
curl --silent --location -O https://repos.influxdata.com/influxdata-archive.key \
&& gpg --show-keys --with-fingerprint --with-colons ./influxdata-archive.key 2>&1 \
| grep -q '^fpr:\+24C975CBA61A024EE1B631787C3D57159FC2F927:$' \
&& cat influxdata-archive.key \
| gpg --dearmor \
| tee /etc/apt/keyrings/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| tee /etc/apt/sources.list.d/influxdata.list

if [ $? -eq 0 ]; then
    log_success "Repository and GPG key configured."
    rm -f influxdata-archive.key
else
    log_error "Failed to configure repository. Fingerprint might not match or network error."
    rm -f influxdata-archive.key
    exit 1
fi

# 2. Update and Install InfluxDB
log_info "Updating package lists and installing influxdb2..."
if apt-get update && apt-get install -y influxdb2; then
    log_success "InfluxDB 2 installed successfully."
else
    log_error "Failed to install influxdb2 package."
    exit 1
fi

# 3. Start the InfluxDB Service
log_info "Starting InfluxDB service..."
systemctl daemon-reload
systemctl start influxdb
systemctl enable influxdb

if systemctl is-active --quiet influxdb; then
    log_success "InfluxDB service is running."
else
    log_error "InfluxDB service failed to start. Check 'journalctl -u influxdb' for details."
    exit 1
fi

# 4. Run the Initial Setup
print_header "Next Steps: Initial Setup"
log_warning "You MUST run the initial setup manually."
echo -e "${YELLOW}Run the following command:${NC}"
echo -e "${GREEN}influx setup${NC}"
echo "UI Access: http://localhost:8086"