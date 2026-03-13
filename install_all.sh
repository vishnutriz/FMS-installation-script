#!/bin/bash

# install_all.sh
# Master script to run all installations

source ./utils.sh

# Initialize log file with permissive permissions
# This allows both user-level and root-level scripts to write to it
LOG_FILE="install_env.log"
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"
echo "--- Installation started at $(date) ---" > "$LOG_FILE"

print_header "Full Environment Installation"

# Warn about execution context
if [ "$EUID" -eq 0 ]; then
    log_warning "You are running this master script as root."
    log_warning "The Node.js script (install_node.sh) is designed to run as a normal user for NVM."
    log_warning "It is recommended to run this script as a NORMAL USER, and it will ask for sudo password when needed."
    read -p "Are you sure you want to continue as root? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    # Verify sudo access upfront
    log_info "Checking sudo access..."
    sudo -v
    if [ $? -ne 0 ]; then
        log_error "Sudo access is required for database installations."
        exit 1
    fi
fi

# 1. Install Node.js (Run as current user)
echo ""
log_info ">>> Step 1/6: Node.js & Next.js"
./install_node.sh
if [ $? -ne 0 ]; then log_error "Node.js installation failed. Aborting."; exit 1; fi

# Track failed scripts
FAILED_SCRIPTS=()

# Helper to run root scripts with error handling
run_sudo_script() {
    local script="$1"
    echo ""
    log_info ">>> Running $script (requires sudo)..."
    
    while true; do
        if [ "$EUID" -eq 0 ]; then
            ./$script
        else
            sudo ./$script
        fi
        
        EXIT_CODE=$?
        
        if [ $EXIT_CODE -eq 0 ]; then
            log_success "$script completed successfully."
            break
        else
            log_error "$script failed with exit code $EXIT_CODE."
            echo ""
            echo "------------------------------------------------"
            echo "What would you like to do?"
            echo "  [r] Retry the script"
            echo "  [c] Continue to next step (ignore error)"
            echo "  [a] Abort installation"
            echo "------------------------------------------------"
            read -p "Select option (r/c/a): " -n 1 -r CHOICE
            echo ""
            
            case "$CHOICE" in
                r|R)
                    log_info "Retrying $script..."
                    continue
                    ;;
                c|C)
                    log_warning "Skipping error in $script and continuing..."
                    FAILED_SCRIPTS+=("$script")
                    break
                    ;;
                a|A|*)
                    log_error "Installation aborted by user."
                    exit 1
                    ;;
                *)
                    log_info "Invalid option. Retrying..."
                    continue
                    ;;
            esac
        fi
    done
}

# 2. Mongo
run_sudo_script "install_mongo.sh"

# 3. Postgres
run_sudo_script "install_postgres.sh"

# 4. InfluxDB
run_sudo_script "install_influx.sh"

# 5. Kafka
run_sudo_script "install_kafka.sh"

# 6. Mosquitto
run_sudo_script "install_mosquitto.sh"

# 7. Configure Databases (Mongo, Postgres, Influx)
echo ""
log_info ">>> Step 7/7: Database Configuration"
log_info "Starts interactive setup for MongoDB, PostgreSQL, and InfluxDB..."
run_sudo_script "setup_databases.sh"

echo ""
if [ ${#FAILED_SCRIPTS[@]} -eq 0 ]; then
    print_header "Installation Complete!"
    log_success "All services installed successfully."
else
    print_header "Installation Complete (With Warnings)"
    log_warning "The following components failed or were skipped:"
    for script in "${FAILED_SCRIPTS[@]}"; do
        echo "  - $script"
    done
    echo ""
    log_info "To retry these specific components later, run:"
    for script in "${FAILED_SCRIPTS[@]}"; do
        if [ "$script" == "setup_databases.sh" ]; then
            echo "  sudo ./setup_databases.sh --mongo     # To retry MongoDB configuration"
            echo "  sudo ./setup_databases.sh --postgres  # To retry PostgreSQL configuration"
            echo "  sudo ./setup_databases.sh --influx    # To retry InfluxDB configuration"
        else
            echo "  sudo ./$script"
        fi
    done
fi
log_info "Please check install_env.log for details."
