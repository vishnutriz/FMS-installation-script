#!/bin/bash

# install_docker.sh
# Installs Docker Engine (CE) and Docker Compose plugin

source ./utils.sh

init_log
print_header "Docker Engine Installation"

check_root
check_internet

log_info "Removing old/conflicting Docker packages..."
# dpkg --get-selections might fail if none of these are installed, so we handle it gracefully
apt-get remove -y $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc 2>/dev/null | cut -f1) 2>/dev/null || true

log_info "Installing prerequisites..."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg >/dev/null 2>&1

log_info "Adding Docker's official GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

log_info "Adding Docker repository to APT sources..."
tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "\${UBUNTU_CODENAME:-\$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

log_info "Updating package lists..."
apt-get update >/dev/null 2>&1

log_info "Installing Docker packages (this might take a while)..."
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &
PID=$!
show_spinner $PID
wait $PID

if [ $? -eq 0 ]; then
    log_success "Docker Engine installed successfully."
else
    log_error "Failed to install Docker Engine."
    exit 1
fi

log_info "Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker

if systemctl is-active --quiet docker; then
    log_success "Docker service is running."
else
    log_warning "Docker service failed to start or verify."
    systemctl status docker --no-pager || true
fi

log_info "Adding current user to the docker group..."
if [ -n "$SUDO_USER" ]; then
    usermod -aG docker "$SUDO_USER"
    log_success "Added $SUDO_USER to the docker group."
else
    usermod -aG docker "$USER"
    log_success "Added $USER to the docker group."
fi
log_info "Note: Group changes may require a re-login or running 'newgrp docker' to take effect."
