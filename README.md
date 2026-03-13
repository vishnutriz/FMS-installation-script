# Environment Installation Guide

This folder contains scripts to set up your development environment on Ubuntu 22.04.

## Scripts

| Script | Description |
| :--- | :--- |
| `install_all.sh` | **Recommended**. Runs all scripts in sequence. |
| `install_node.sh` | Installs Node.js 22.14.0 (via NVM) and Next.js. |
| `install_mongo.sh` | Installs MongoDB 7.0 Community Edition. |
| `install_postgres.sh` | Installs PostgreSQL and contrib packages. |
| `install_influx.sh` | Installs InfluxDB 2.0 OSS. |
| `install_kafka.sh` | Installs Apache Kafka (to your home dir) & ZooKeeper. |
| `install_mosquitto.sh` | Installs Mosquitto MQTT Broker. |
| `utils.sh` | Helper functions for logs and colors (do not run directly). |

## Usage

### 1. Make Scripts Executable
```bash
chmod +x *.sh
```

### 2. Run All Installations
```bash
./install_all.sh
```

### 3. Running Individually

If you prefer to install only specific components:

**Node.js**: Run as normal user.
   ```bash
   ./install_node.sh
   ```

**Databases/Services**: Run with sudo.
   ```bash
   sudo ./install_mongo.sh
   sudo ./install_postgres.sh
   sudo ./install_influx.sh
   sudo ./install_mosquitto.sh
   ```

**Kafka**: Run with sudo (to set up systemd), but it detects your user to install files to `~/kafka`.
   ```bash
   sudo ./install_kafka.sh
   ```

## Verification

After installation, verify the components:

- **Node**: `node -v` (should be v22.14.0)
- **Mongo**: `mongosh`
- **InfluxDB**: Run `influx setup` to create your initial user/bucket.
- **Kafka**: Check status with `sudo systemctl status kafka`
- **Mosquitto**: Test with `mosquitto_sub -t "test"` and `mosquitto_pub -t "test" -m "hello"`
