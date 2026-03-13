# InfluxDB Backup

This directory contains InfluxDB metadata backup files for restoring organization, bucket, and dashboard configurations.

## Files

- **all_metadata.yml** - Complete InfluxDB metadata export including:
  - Organization configuration
  - Buckets (device_core)
  - Dashboards
  - Variables
  - Other configurations

- **my_buckets.txt** - List of bucket names

## Usage

The `setup_databases.sh` script will automatically detect this backup and offer to restore it during InfluxDB configuration.

## Manual Restore

If you need to manually restore the metadata:

```bash
# Make sure InfluxDB is running and you're logged in
influx setup  # Run initial setup first

# Apply the metadata template
influx apply --file influxdb_backup/all_metadata.yml --force
```

## Creating New Backups

To export your current InfluxDB configuration:

```bash
# Export all metadata
influx export all --file influxdb_backup/all_metadata_new.yml

# List buckets
influx bucket list | awk '{print $2}' > influxdb_backup/my_buckets.txt
```
