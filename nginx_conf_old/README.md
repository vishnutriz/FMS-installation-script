FMS API Gateway (NGINX + Docker) — README (current setup)

This repo runs the API Gateway (nginx) and the FMS microservices with Docker.
Back-end datastores/brokers (Postgres, MongoDB, Kafka, Mosquitto) are already running on the server, and the containers connect to them over the network.

Gateway origin
https://localhost:8443 (development)
https://<SERVER_IP>:8443 (production)

 **For production deployment with server IP, see [DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md)**

1) Folder layout
FMS/
├── certs/
│   ├── nginx/
│   │   ├── localhost.crt
│   │   └── localhost.key
│   └── internal/
│       ├── ca.crt
│       ├── ca.key
│       ├── user-service.crt
│       ├── user-service.key
│       ├── application-service.crt
│       └── application-service.key
├── logs/
│   └── nginx/
├── FMS-application-service/
├── FMS-device-core/
├── FMS-usermanagement/
└── nginx_conf/
    ├── docker-compose.yml
    ├── default.conf
    └── 00-log-format.conf


2) Certificates (one-time)

Create folders:
mkdir -p certs/nginx certs/internal logs/nginx

Create a local Root CA (used by the gateway for upstream verification):

openssl genrsa -out certs/internal/ca.key 2048
openssl req -x509 -new -nodes -key certs/internal/ca.key -sha256 -days 3650 \
  -subj "/CN=FMS-DEV-LOCAL-CA" -out certs/internal/ca.crt



Helper to issue a service certificate:

make_svc_cert() {
  svc="$1"
  mkdir -p certs/internal
  if [ -d "certs/internal/${svc}" ]; then
    echo "Error: certs/internal/${svc} is a directory, please remove it first."
    return 1
  fi
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
  echo "Created certs/internal/${svc}.crt and ${svc}.key"
}

ssue service certs as needed (examples):

make_svc_cert user-service
make_svc_cert application-service

Browser-facing gateway cert for localhost:
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/nginx/localhost.key \
  -out   certs/nginx/localhost.crt \
  -subj "/CN=localhost"

3) Point containers to the host databases/brokers

Edit nginx_conf/docker-compose.yml and replace <SERVER_IP> with the server’s IP that Docker containers can reach.


4) Start / Stop / Logs

Run from FMS/nginx_conf/:
# build and start all services
docker compose up -d --build

# follow gateway logs
docker compose logs -f nginx

# stop everything
docker compose down

What starts here:

nginx (API Gateway)
user-service
application-service
device-core
mission-service
eployment-service
kafka-ui 

5) Quick verification

Gateway probe:
curl -k https://localhost:8443/whoami


Login (adjust credentials to your seed data):
curl -k -i -c cookies.txt \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data "username=admin@example.com&password=secret" \
  https://localhost:8443/api/users/auth/login

Call a protected API using the cookie:
curl -k -b cookies.txt https://localhost:8443/api/devices


6) Routes (summary)

Auth & Users

/api/users/auth/* (login/logout/refresh/register)

/api/users/* (protected)

Devices

/api/devices/* (rewritten to backend /api/v1/...)

/api/devices/ws (WebSocket)

Applications

/api/applications/* → /api/v1/applications/*

/api/versions* → /api/v1/versions*

Missions

/api/mission*

/api/scheduler*

Compatibility: /mission → /api/mission

Deployment

/api/deployments*, /api/zones*, /api/plants*, /api/path-layers*

Compatibility: /api/path-layers/zone/:id → /api/zones/:id/path-layers

Debug

/whoami

CORS defaults to http://localhost:5173, http://localhost:3000, and https://localhost:8443. Adjust in default.conf if your FE origin differs.


7) Troubleshooting

502 / upstream errors

Service not ready: docker compose logs -f <service-name>

Wrong <SERVER_IP> or blocked host ports

Auth / cookies

Always call the gateway via https://localhost:8443

Keep FE origin listed in CORS allow-list

Kafka UI can’t connect

Ensure host Kafka advertised.listeners=PLAINTEXT://<SERVER_IP>:9092