#!/bin/bash

# Configuration
LINKS_FILE="Text File.txt"
DOWNLOAD_DIR="docker_images"

# -------------------------------------------------------------
# Check and Install Docker
# -------------------------------------------------------------
echo "Checking if Docker is installed..."
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."

    # Identify conflicting packages that are actually installed to remove them safely
    CONFLICTS="docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc"
    INSTALLED_CONFLICTS=""
    for pkg in $CONFLICTS; do
        if dpkg -l "$pkg" &>/dev/null; then
            INSTALLED_CONFLICTS="$INSTALLED_CONFLICTS $pkg"
        fi
    done

    if [ -n "$INSTALLED_CONFLICTS" ]; then
        echo "Removing conflicting packages: $INSTALLED_CONFLICTS..."
        sudo apt-get remove -y $INSTALLED_CONFLICTS
    fi

    # Add Docker's official GPG key:
    echo "Adding Docker official repository..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update

    echo "Installing Docker CE..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable and start docker service
    sudo systemctl enable docker
    sudo systemctl start docker

    # Verify installation
    if command -v docker &> /dev/null; then
        echo "Docker installed successfully!"
        sudo docker run --rm hello-world
    else
        echo "Error: Docker installation failed."
        exit 1
    fi
else
    echo "Docker is already installed."
fi

# Add current user to docker group if not already present
REAL_USER=${SUDO_USER:-$USER}
if [ "$REAL_USER" != "root" ]; then
    if groups "$REAL_USER" | grep -q "\bdocker\b"; then
        echo "User '$REAL_USER' is already in the 'docker' group."
    else
        echo "Adding user '$REAL_USER' to the 'docker' group..."
        sudo usermod -aG docker "$REAL_USER"
        echo "User '$REAL_USER' added to 'docker' group."
        echo "Note: You may need to log out and log back in (or run 'newgrp docker') for the group membership to take effect."
    fi
fi
# -------------------------------------------------------------

# Ensure the download directory exists
mkdir -p "$DOWNLOAD_DIR"

echo "Select download source for Docker images:"
echo "1) AWS S3 (via links file)"
echo "2) Google Drive (via Folder URL)"
read -p "Enter choice [1 or 2]: " dl_choice

if [ "$dl_choice" == "1" ]; then
    if [ ! -f "$LINKS_FILE" ]; then
        echo "Error: Cannot find $LINKS_FILE"
        exit 1
    fi

    echo "Starting download from AWS..."

    # Read lines from the file that start with https
    grep '^https' "$LINKS_FILE" | while read -r url; do
        # Extract the base URL without query parameters to get the filename
        base_url=$(echo "$url" | awk -F'?' '{print $1}')
        filename=$(basename "$base_url")

        filepath="${DOWNLOAD_DIR}/${filename}"

        echo "========================================"
        echo "Downloading: $filename"
        echo "========================================"
        
        # Download the file using curl (silent mode with progress bar)
        curl -# -o "$filepath" "$url"

        if [ $? -eq 0 ]; then
            echo "Successfully downloaded $filename."
        else
            echo "Error downloading $filename."
        fi
        echo ""
    done

elif [ "$dl_choice" == "2" ]; then
    read -p "Enter Google Drive Folder URL: " GDRIVE_URL
    if [ -z "$GDRIVE_URL" ]; then
        echo "Error: Google Drive URL cannot be empty."
        exit 1
    fi

    echo "========================================"
    echo "Downloading images from Google Drive..."
    echo "========================================"

    # Check for pip3 and gdown
    if ! command -v gdown &> /dev/null && [ ! -f "$HOME/.local/bin/gdown" ]; then
        echo "gdown not found. Attempting to install..."
        if ! command -v pip3 &> /dev/null; then
            echo "pip3 not found. Installing python3-pip..."
            sudo apt-get update && sudo apt-get install -y python3-pip
        fi
        
        # Install gdown for the user
        pip3 install --user gdown || { echo "Failed to install gdown. Please install manually."; exit 1; }
        export PATH="$PATH:$HOME/.local/bin"
    fi

    # Set gdown command
    GDOWN_CMD="gdown"
    if ! command -v gdown &> /dev/null; then
        if [ -f "$HOME/.local/bin/gdown" ]; then
            GDOWN_CMD="$HOME/.local/bin/gdown"
        fi
    fi

    $GDOWN_CMD --folder "$GDRIVE_URL" -O "$DOWNLOAD_DIR"
    
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded Google Drive folder."
    else
        echo "Error downloading from Google Drive."
        exit 1
    fi
else
    echo "Invalid choice. Exiting."
    exit 1
fi

echo "========================================"
echo "Loading Docker images..."
echo "========================================"

# Find all tar and tar.gz files in the download directory
find "$DOWNLOAD_DIR" -type f \( -name "*.tar.gz" -o -name "*.tar" \) | while read -r filepath; do
    filename=$(basename "$filepath")
    
    echo "Loading Docker image: $filename"
    
    # Load the image
    # We first try docker load, and if it fails (often due to permissions), we try with sudo.
    docker load -i "$filepath" || sudo docker load -i "$filepath"
    
    if [ $? -eq 0 ]; then
        echo "Successfully loaded $filename."
    else
        echo "Error loading Docker image $filename."
    fi
    echo ""
done

echo "All images have been processed!"
