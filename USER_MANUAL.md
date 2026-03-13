% FMS Installation Suite - Comprehensive User Manual
% Trizlabz
% February 2026

# 1. Introduction

This document serves as a complete, step-by-step guide for installing and configuring the Fleet Management System (FMS). It details every prompt you will encounter during the automated installation process.

# 2. System Requirements

*   **OS**: Ubuntu 22.04 LTS
*   **Permissions**: User with `sudo` access (do not run the script as root directly).
*   **Internet**: Required.

# 3. Pre-Installation Setup

1.  **Download Steps**: Copy the installation folder to your server.
2.  **Terminal Access**: Open a terminal in the installation directory.
3.  **Grant Permissions**: Run the following command to make scripts executable:
    ```bash
    chmod +x *.sh
    ```

# 4. Installation Process (Step-by-Step)

## Step 1: Start the Installer

Run the master script:
```bash
./install_all.sh
```

**Note**: If prompted for a password, enter your user's `sudo` password.

## Step 2: Component Installation

The script will automatically install the following software components. You do not need to interact with these steps unless an error occurs.

1.  **Node.js**: Installs Node Version Manager (NVM) and Node.js v22.14.0.
2.  **MongoDB**: Installs MongoDB Database Server v7.0.
3.  **PostgreSQL**: Installs PostgreSQL Database Server.
4.  **InfluxDB**: Installs InfluxDB v2.x.
5.  **Kafka & ZooKeeper**: Downloads and installs Apache Kafka v3.6.1.
6.  **Mosquitto**: Installs Eclipse Mosquitto MQTT Broker.

**Error Handling**:
If any component fails to install, you will see a menu:
*   `[r] Retry`: Try to install that component again.
*   `[c] Continue`: Skip it and move to the next.
*   `[a] Abort`: Exit the installer.
*   *Recommendation*: Choose `[r]` to retry first. If it persists, check your internet connection.

## Step 3: Database Configuration

Once software installation is complete, the script automatically starts the configuration phase (`setup_databases.sh`). This is where you need to provide input.

### 3.1 MongoDB Setup

1.  **Authentication Check**: The script checks if MongoDB is already secured.
    *   *Prompt*: "Do you want to reconfigure MongoDB? (y/n)"
    *   *Action*: Type `y` and press Enter to configure a fresh install.

2.  **Admin User Creation**:
    *   *Prompt*: "Enter MongoDB admin username (default: admin):"
    *   *Action*: Press Enter to accept `admin` or type a custom name.
    *   *Prompt*: "Enter MongoDB admin password (default: password):"
    *   *Action*: Type a strong password and press Enter.

3.  **Customer/Tenant Creation**:
    You are now creating the first customer account for the FMS.
    *   *Prompt*: "Enter company name:"
    *   *Action*: Type your organization's name (e.g., `Logistics Co`).
    *   *Prompt*: "Enter customer name (contact person):"
    *   *Action*: Type the primary contact's name.
    *   *Prompt*: "Enter contact email:"
    *   *Action*: Type the email address (this will be the login username).
    *   *Prompt*: "Enter phone number (optional):"
    *   *Action*: Type phone number or press Enter to skip.
    *   *Prompt*: "Enter address (optional):"
    *   *Action*: Type address or press Enter to skip.
    *   *Prompt*: "Enter customer admin password:"
    *   *Action*: Type the password for this customer account.

    *Outcomes*:
    *   Creates a `SUPER_ADMIN` user (`admin@iotcore.com`).
    *   Creates the Customer and Customer Admin user in the database.
    *   Enables security in MongoDB and restarts the service.

### 3.2 PostgreSQL Setup

1.  **Existing Database Check**:
    *   *Prompt*: "The following databases already exist... Do you want to drop and recreate these databases? (y/n)"
    *   *Action*: Type `n` to keep existing data, or `y` to wipe and reset.

2.  **Schema Import**:
    *   *Prompt*: "Do you want to import PostgreSQL schemas now? (y/n)"
    *   *Action*: Type `y` to install the standard FMS database structure.

### 3.3 InfluxDB Setup

1.  **Existing Configuration**:
    *   *Prompt*: "Do you want to reconfigure InfluxDB? (y/n)"
    *   *Action*: Type `y` if this is a new install.

2.  **Backup Restore**:
    *   *Prompt*: "Found InfluxDB metadata backup... Do you want to restore from this backup? (y/n)"
    *   *Action*:
        *   Type `y` if you have a backup file you want to use.
        *   Type `n` to start a fresh setup (Standard).

3.  **Fresh Setup Configuration** (If you chose `n` above):
    *   *Prompt*: "Enter InfluxDB admin username (default: admin):"
    *   *Action*: Press Enter or type a username.
    *   *Prompt*: "Enter InfluxDB admin password:"
    *   *Action*: Type a strong password.
    *   *Prompt*: "Enter organization name (default: trizlabz):"
    *   *Action*: Press Enter to use default or type your own.
    *   *Prompt*: "Enter bucket name (default: device_core):"
    *   *Action*: Press Enter to use default.
    *   *Prompt*: "Enter retention period in days (0 for infinite, default: 0):"
    *   *Action*: Press Enter for infinite retention.

4.  **Finalization**:
    *   The script generates an **Admin Token**.
    *   It saves credentials to a hidden file: `.influx_credentials`.

# 5. Post-Installation Summary

After the script finishes, it displays a summary of your configuration.

**Key Credentials Locations:**
*   **InfluxDB**: Saved in `.influx_credentials` in the installation folder.
*   **MongoDB**: Use the Admin credentials you created in Step 3.1.
*   **PostgreSQL**: Uses default `postgres` user or configured app users.

# 6. How to Verify Installation

Run the following commands to ensure everything is running:

1.  **Check Services**:
    ```bash
    sudo systemctl status mongod postgresql influxdb mosquitto
    ```
    *Expected Output*: All services should show `active (running)`.

2.  **Check Kafka**:
    Kafka runs in the background. Check if it's listening on port 9092:
    ```bash
    ss -tuln | grep 9092
    ```

# 7. Troubleshooting Common Errors

*   **Error**: "Sudo access is required..."
    *   *Fix*: Ensure you have sudo rights. Do NOT run with `sudo ./install_all.sh`. Run `./install_all.sh` and let it ask for the password.
*   **Error**: "MongoDB is not running" during configuration.
    *   *Fix*: Start it manually: `sudo systemctl start mongod`.
*   **Error**: "Schema file not found".
    *   *Fix*: Ensure the `db_schemas` folder is present in the installation directory.
