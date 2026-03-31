#!/bin/bash

# Request server IP from user
read -p "Enter the Server IP address for the deployment: " SERVER_IP

if [ -z "$SERVER_IP" ]; then
    echo "Error: IP address cannot be empty."
    exit 1
fi

# Define paths
FMS_DIR="$HOME/fms"
NGINX_CONF_SRC="./nginx_conf"
COMPOSE_SRC="./nginx_conf/docker-compose.prod.yml"

echo "Creating FMS directory at $FMS_DIR..."
mkdir -p "$FMS_DIR"

echo "Copying nginx_conf to FMS directory..."
cp -r "$NGINX_CONF_SRC" "$FMS_DIR/"

echo "Copying docker-compose.prod.yml to FMS directory..."
cp "$COMPOSE_SRC" "$FMS_DIR/"

COMPOSE_DEST="$FMS_DIR/docker-compose.prod.yml"

echo "Editing docker-compose.prod.yml to use IP: $SERVER_IP..."

# Replace the specific InfluxDB URL for fmscore-frontend
sed -i "s|INFLUX_URL=http://neev3.trizlabz.com:8086|INFLUX_URL=http://${SERVER_IP}:8086|g" "$COMPOSE_DEST"

# Replace the MQTT Broker Host IP for device-core
sed -i "s|MQTT_BROKER_HOST=192.168.0.103|MQTT_BROKER_HOST=${SERVER_IP}|g" "$COMPOSE_DEST"

echo "Navigating to $FMS_DIR to generate certificates..."
cd "$FMS_DIR" || exit 1

mkdir -p certs/nginx certs/internal logs/nginx

echo "Creating local Root CA..."
openssl genrsa -out certs/internal/ca.key 2048
openssl req -x509 -new -nodes -key certs/internal/ca.key -sha256 -days 3650 \
  -subj "/CN=FMS-DEV-LOCAL-CA" -out certs/internal/ca.crt

make_svc_cert() {
  svc="$1"
  echo "Generating certificate for $svc..."
  openssl genrsa -out "certs/internal/${svc}.key" 2048
  openssl req -new -key "certs/internal/${svc}.key" \
    -subj "/CN=${svc}" -out "certs/internal/${svc}.csr"
  cat > "certs/internal/${svc}.ext" <<EOF
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${svc}
DNS.2 = localhost
IP.1  = 127.0.0.1
EOF
  openssl x509 -req -in "certs/internal/${svc}.csr" -CA certs/internal/ca.crt \
    -CAkey certs/internal/ca.key -CAcreateserial -out "certs/internal/${svc}.crt" \
    -days 825 -sha256 -extfile "certs/internal/${svc}.ext"
  rm -f "certs/internal/${svc}.csr" "certs/internal/${svc}.ext"
}

# Issue service certs
SERVICES=(
  "user-service"
  "application-service"
  "mission-service"
  "deployment-service"
  "dashboard-service"
  "alert-service"
  "traffic-management-service"
  "analytics-service"
  "ota-update-service"
  "device-core"
  "log-service"
  "db-manager"
  "manual-service"
  "ota-campaign-backend"
)

for svc in "${SERVICES[@]}"; do
  make_svc_cert "$svc"
done

echo "Generating browser-facing gateway cert for localhost..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/nginx/localhost.key \
  -out certs/nginx/localhost.crt \
  -subj "/CN=localhost"

# Return to initial directory
cd - > /dev/null

echo "Setup, file edits, and certificate generation complete! Check $FMS_DIR."
