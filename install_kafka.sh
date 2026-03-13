#!/bin/bash

# install_kafka.sh
# Installs Apache Kafka & ZooKeeper to User Home Directory

source ./utils.sh

init_log
print_header "Apache Kafka & ZooKeeper Installation"

check_root
check_internet

# Determine Real User (since we run as sudo)
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
KAFKA_VERSION="3.2.1"
SCALA_VERSION="2.12"
KAFKA_BASENAME="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"
INSTALL_DIR="${REAL_HOME}/${KAFKA_BASENAME}"

# Check if Kafka is already configured as a service AND installation exists
if systemctl list-units --full -all | grep -Fq "kafka.service" && [ -d "$INSTALL_DIR" ]; then
    log_success "Kafka service is already installed."
    systemctl status kafka --no-pager
    exit 0
fi
if [ "$REAL_USER" == "root" ]; then
    log_warning "Running as root user directly? usage: sudo ./install_kafka.sh (from a normal user)"
    # Fallback or risk installing to /root
fi

REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
log_info "Target User: $REAL_USER"
log_info "Target Home: $REAL_HOME"

KAFKA_VERSION="3.2.1"
SCALA_VERSION="2.12"
KAFKA_BASENAME="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"
# Use archive.apache.org which is more reliable than the main mirror
DOWNLOAD_URL="https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_BASENAME}.tgz"
INSTALL_DIR="${REAL_HOME}/${KAFKA_BASENAME}"
SYMLINK_DIR="${REAL_HOME}/kafka"

# 1. Install Java
log_info "Installing default-jdk..."
apt-get update > /dev/null 2>&1
apt-get install -y default-jdk &
PID=$!
show_spinner $PID
wait $PID

java -version &> /dev/null
if [ $? -eq 0 ]; then
    log_success "Java installed."
else
    log_error "Java installation failed."
    exit 1
fi

# 2. Download Kafka
log_info "Downloading Kafka ${KAFKA_VERSION}..."
log_info "Using archive mirror: ${DOWNLOAD_URL}"
sudo -u "$REAL_USER" wget "$DOWNLOAD_URL" -O "/tmp/kafka.tgz" 2>&1 | grep -v "^--" | grep -v "^$" || true

if [ ! -s "/tmp/kafka.tgz" ]; then
    log_error "Failed to download Kafka from archive mirror."
    log_info "Trying alternate download URL..."
    
    # Try alternate URL
    ALT_URL="https://downloads.apache.org/kafka/${KAFKA_VERSION}/${KAFKA_BASENAME}.tgz"
    sudo -u "$REAL_USER" wget "$ALT_URL" -O "/tmp/kafka.tgz" 2>&1 | grep -v "^--" | grep -v "^$" || true
    
    if [ ! -s "/tmp/kafka.tgz" ]; then
        log_error "Failed to download Kafka from both mirrors."
        log_error "Please check your internet connection and try again."
        exit 1
    fi
fi
log_success "Kafka downloaded."

# 3. Extract and Move
log_info "Extracting to ${REAL_HOME}..."
# Extract as the real user to preserve permissions
sudo -u "$REAL_USER" tar -xzf "/tmp/kafka.tgz" -C "$REAL_HOME"
rm "/tmp/kafka.tgz"

# 4. Create Symbolic Link
log_info "Creating symlink ${SYMLINK_DIR}..."
if [ -L "$SYMLINK_DIR" ]; then
    rm "$SYMLINK_DIR"
fi
sudo -u "$REAL_USER" ln -s "$INSTALL_DIR" "$SYMLINK_DIR"

# 5. Configure server.properties
log_info "Configuring Kafka server.properties..."

# Detect current IP address as default suggestion
CURRENT_IP=$(hostname -I | awk '{print $1}')
if [ -z "$CURRENT_IP" ]; then
    CURRENT_IP="localhost"
fi

# Prompt user for advertised listener IP
echo ""
log_info "Kafka needs to be configured with an advertised listener IP address."
log_info "This IP will be used by clients to connect to Kafka."
log_info "Detected IP address: $CURRENT_IP"
echo -n "Enter advertised listener IP address (press Enter for $CURRENT_IP): "
read USER_IP

# Use detected IP if user didn't provide one
if [ -z "$USER_IP" ]; then
    ADVERTISED_IP="$CURRENT_IP"
else
    ADVERTISED_IP="$USER_IP"
fi

log_info "Configuring Kafka with advertised listener: $ADVERTISED_IP:9092"

# Backup original server.properties
KAFKA_SERVER_PROPS="${SYMLINK_DIR}/config/server.properties"
cp "$KAFKA_SERVER_PROPS" "${KAFKA_SERVER_PROPS}.backup.$(date +%Y%m%d_%H%M%S)"

# Update listeners configuration
if grep -q "^listeners=" "$KAFKA_SERVER_PROPS"; then
    sed -i "s|^listeners=.*|listeners=PLAINTEXT://0.0.0.0:9092|" "$KAFKA_SERVER_PROPS"
else
    # If commented out, uncomment and set
    if grep -q "^#listeners=" "$KAFKA_SERVER_PROPS"; then
        sed -i "s|^#listeners=.*|listeners=PLAINTEXT://0.0.0.0:9092|" "$KAFKA_SERVER_PROPS"
    else
        # Add after the listeners comment section
        sed -i "/^#listeners=PLAINTEXT:\/\/:9092/a listeners=PLAINTEXT://0.0.0.0:9092" "$KAFKA_SERVER_PROPS"
    fi
fi

# Update advertised.listeners configuration
if grep -q "^advertised.listeners=" "$KAFKA_SERVER_PROPS"; then
    sed -i "s|^advertised.listeners=.*|advertised.listeners=PLAINTEXT://${ADVERTISED_IP}:9092|" "$KAFKA_SERVER_PROPS"
else
    # If commented out, uncomment and set
    if grep -q "^#advertised.listeners=" "$KAFKA_SERVER_PROPS"; then
        sed -i "s|^#advertised.listeners=.*|advertised.listeners=PLAINTEXT://${ADVERTISED_IP}:9092|" "$KAFKA_SERVER_PROPS"
    else
        # Add after listeners configuration
        sed -i "/^listeners=PLAINTEXT:\/\/0.0.0.0:9092/a advertised.listeners=PLAINTEXT://${ADVERTISED_IP}:9092" "$KAFKA_SERVER_PROPS"
    fi
fi

log_success "Kafka server.properties configured successfully."

# 6. Set Path for Kafka (Update .profile)
PROFILE_FILE="${REAL_HOME}/.profile"
EXPORT_CMD="export PATH=${SYMLINK_DIR}/bin:\$PATH"

if grep -Fxq "$EXPORT_CMD" "$PROFILE_FILE"; then
    log_info "Path already present in .profile"
else
    log_info "Adding Kafka bin to .profile..."
    echo "" >> "$PROFILE_FILE"
    echo "# Kafka Binaries" >> "$PROFILE_FILE"
    echo "$EXPORT_CMD" >> "$PROFILE_FILE"
    log_success "Updated .profile."
fi

# 7. Create Systemd for ZooKeeper
log_info "Configuring ZooKeeper service..."
cat <<EOF > /etc/systemd/system/zookeeper.service
[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=${SYMLINK_DIR}/bin/zookeeper-server-start.sh ${SYMLINK_DIR}/config/zookeeper.properties
ExecStop=${SYMLINK_DIR}/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

# 8. Create Systemd for Kafka
log_info "Configuring Kafka service..."
# Detect Java Home dynamically - use readlink for more reliability
if command -v java &> /dev/null; then
    JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
else
    # Fallback to default JDK location
    JAVA_HOME_PATH="/usr/lib/jvm/default-java"
fi

cat <<EOF > /etc/systemd/system/kafka.service
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=zookeeper.service

[Service]
Type=simple
Environment="JAVA_HOME=${JAVA_HOME_PATH}"
ExecStart=${SYMLINK_DIR}/bin/kafka-server-start.sh ${SYMLINK_DIR}/config/server.properties
ExecStop=${SYMLINK_DIR}/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
EOF

log_info "Reloading systemd..."
systemctl daemon-reload

# 9. Start Services
log_info "Starting ZooKeeper..."
systemctl start zookeeper
systemctl enable zookeeper
sleep 5

if systemctl is-active --quiet zookeeper; then
    log_success "ZooKeeper is running."
else
    log_error "ZooKeeper failed to start."
fi

log_info "Starting Kafka..."
systemctl start kafka
systemctl enable kafka
sleep 6

if systemctl is-active --quiet kafka; then
    log_success "Kafka is running."
else
    log_error "Kafka failed to start."
fi

log_info "Kafka installation complete."
log_info "You may need to run 'source ~/.profile' to update your PATH."
