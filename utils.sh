#!/bin/bash

# utils.sh
# Shared functions for installation scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LOG_FILE="install_env.log"

# Initialize Log
init_log() {
    echo "==========================================" >> "$LOG_FILE"
    echo "Installation started at $(date)" >> "$LOG_FILE"
    echo "==========================================" >> "$LOG_FILE"
}

# Logging Functions
log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${NC} $message"
    echo "[INFO] $message" >> "$LOG_FILE"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS]${NC} $message"
    echo "[SUCCESS] $message" >> "$LOG_FILE"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}[WARNING]${NC} $message"
    echo "[WARNING] $message" >> "$LOG_FILE"
}

log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} $message"
    echo "[ERROR] $message" >> "$LOG_FILE"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Spinner for async tasks
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)."
        exit 1
    fi
}

# Check connectivity
check_internet() {
    log_info "Checking internet connectivity..."
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        log_success "Internet connection active."
    else
        log_error "No internet connection. Please check your network."
        exit 1
    fi
}

# Add a visual separator
print_header() {
    local title="$1"
    echo ""
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}   $title   ${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
}
