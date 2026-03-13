#!/bin/bash

# install_node.sh
# Installs Node.js v22.14.0 via NVM

source ./utils.sh

init_log
print_header "Node.js & Next.js Installation"

# NVM should NOT be installed as root generally, so we check if we are root and warn/exit?
# User instructions say: "Part 1: Install Node.js (v22.14.0) via NVM"
# Usually run as normal user.

if [ "$EUID" -eq 0 ]; then
    log_warning "You are running this script as root. NVM is typically installed per-user."
    log_warning "If you intend to install for a specific user, run as that user."
    read -p "Continue as root? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

check_internet

# 1. Check if Node.js is already installed with the correct version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Try to load NVM if it exists

if command -v node &> /dev/null; then
    CURRENT_NODE_VERSION=$(node -v)
    if [ "$CURRENT_NODE_VERSION" = "v22.14.0" ]; then
        log_success "Node.js v22.14.0 is already installed and active."
        log_info "Node Version: $CURRENT_NODE_VERSION"
        log_info "NPM Version: $(npm -v)"
        
        # Check if create-next-app is installed
        if command -v create-next-app &> /dev/null || npm list -g create-next-app &> /dev/null; then
            log_success "create-next-app is already installed."
            log_success "Node.js and Next.js environment ready."
            exit 0
        else
            log_info "Installing create-next-app globally..."
            npm install -g create-next-app@latest &
            PID=$!
            show_spinner $PID
            wait $PID
            log_success "Node.js and Next.js environment ready."
            exit 0
        fi
    fi
fi

# 2. Install NVM
log_info "Checking NVM..."
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    log_success "NVM is already installed."
    \. "$NVM_DIR/nvm.sh"
else
    log_info "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash &
    PID=$!
    show_spinner $PID
    wait $PID

    if [ $? -eq 0 ]; then
        log_success "NVM script executed."
    else
        log_error "Failed to install NVM."
        exit 1
    fi
fi

# 3. Activate NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if command -v nvm &> /dev/null; then
    log_success "NVM loaded successfully."
else
    log_error "NVM command not found. Please restart your terminal or check ~/.bashrc"
    exit 1
fi

# 4. Install Node.js v22.14.0
if nvm ls 22.14.0 | grep -q "22.14.0"; then
    log_success "Node.js v22.14.0 is already installed."
    nvm use 22.14.0
else
    log_info "Installing Node.js v22.14.0..."
    nvm install 22.14.0 &
    PID=$!
    show_spinner $PID
    wait $PID
fi

if nvm use 22.14.0; then
    log_success "Node.js v22.14.0 activated."
else
    log_error "Failed to install/activate Node.js v22.14.0"
    exit 1
fi

# 5. Set Default Alias
nvm alias default 22.14.0
log_success "Default alias set to 22.14.0."

# 6. Verify Installation
NODE_VER=$(node -v)
NPM_VER=$(npm -v)
log_info "Node Version: $NODE_VER"
log_info "NPM Version: $NPM_VER"

# Part 2: Install Next.js (Global CLI)
log_info "Installing create-next-app globally..."
npm install -g create-next-app@latest &
PID=$!
show_spinner $PID
wait $PID

# Install bcrypt globally (required for MongoDB password hashing in database setup)
log_info "Installing bcrypt globally (required for database setup)..."
npm install -g bcrypt >> "$LOG_FILE" 2>&1

if npm list -g bcrypt &> /dev/null; then
    log_success "bcrypt installed successfully."
else
    log_warning "bcrypt installation may have failed. Database setup will attempt to install it automatically."
fi

log_success "Node.js and Next.js environment ready."
log_info "To create a new project, run: npx create-next-app@latest my-app"
