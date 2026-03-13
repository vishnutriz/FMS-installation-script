# Mosquitto Certificate Directory

Place your Mosquitto SSL/TLS certificates in this directory before running the installation script.

## Required Files

The installation script will look for the following certificate files:

1. **ca.crt** - Certificate Authority certificate
2. **broker.crt** - MQTT broker certificate
3. **broker.key** - Broker private key

## File Placement

```
mosquitto_certs/
├── ca.crt
├── broker.crt
└── broker.key
```

## Installation Process

When you run `install_mosquitto.sh`, the script will:
1. Check if these certificate files exist in this directory
2. Copy them to `/etc/mosquitto/certs/` on the target system
3. Set appropriate permissions (644 for .crt files, 600 for .key file)

## Generating Certificates

If you don't have certificates yet, you can generate self-signed certificates for testing:

```bash
# Generate CA key and certificate
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt

# Generate broker key and certificate signing request
openssl genrsa -out broker.key 2048
openssl req -new -key broker.key -out broker.csr

# Sign the broker certificate with CA
openssl x509 -req -in broker.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out broker.crt -days 3650

# Clean up CSR
rm broker.csr
```

**Note:** For production use, obtain certificates from a trusted Certificate Authority.
