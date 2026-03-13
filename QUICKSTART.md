# Quick Start Guide

Welcome! This package installs all necessary software for your development environment.

## How to Install

1. **Open your Terminal**

2. **Make scripts executable:**
   ```bash
   chmod +x *.sh
   ```

3. **Run the installer:**
   ```bash
   ./install_all.sh
   ```

The scripts will check if components are already installed and skip them automatically.

## Troubleshooting

- **Logs**: Check `install_env.log` for detailed output
- **Internet**: Ensure you have an active connection
- **Re-run**: Safe to re-run multiple times (idempotent)

---
**Components Installed:**
- Node.js v22.14.0
- MongoDB 7.0
- PostgreSQL
- InfluxDB 2.0
- Kafka 3.6.1 + ZooKeeper
- Mosquitto MQTT
