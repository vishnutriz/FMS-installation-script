# PostgreSQL Database Schemas

This directory contains the PostgreSQL database schemas for the FMS system.

## Files

- **all_db.sql** - Complete database dump with all schemas (alerts, applications, dashboard, deployment, devices, missions, traffic_management)

## Usage

The `setup_databases.sh` script will automatically import these schemas into PostgreSQL during database configuration.

## Manual Import

If you need to manually import schemas:

```bash
# Import all schemas
sudo -u postgres psql < db_schemas/all_db.sql
```

## Updating Schemas

To update the schema file with the latest from your development database:

```bash
# Export all databases
pg_dumpall -U postgres > db_schemas/all_db.sql
```
