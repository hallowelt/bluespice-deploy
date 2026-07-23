#!/bin/bash
# Generates a self-signed CA and server/client certificates for MariaDB SSL.
# Run this script once before starting the stack with DB_SSL=true.
#
# Usage: ./generate-db-ssl-certs.sh [DATADIR]
#   DATADIR defaults to the value from .env or /data/bluespice

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve DATADIR
if [ -n "${1:-}" ]; then
  DATADIR="$1"
elif [ -f "${SCRIPT_DIR}/.env" ]; then
  DATADIR=$(grep -E '^DATADIR=' "${SCRIPT_DIR}/.env" | cut -d'=' -f2)
fi
DATADIR="${DATADIR:-/data/bluespice}"

SSL_DIR="${DATADIR}/database/ssl"
CONF_DIR="${DATADIR}/database/mysql-conf.d"

echo "Generating MariaDB SSL certificates in: ${SSL_DIR}"

mkdir -p "${SSL_DIR}" "${CONF_DIR}"

# Ensure the mysql user inside the container (UID 999) can read the files
sudo chown -R 999:999 "${SSL_DIR}" 2>/dev/null || true

# --- CA ---
openssl genrsa -out "${SSL_DIR}/ca-key.pem" 4096
openssl req -new -x509 -nodes -days 3650 \
  -key "${SSL_DIR}/ca-key.pem" \
  -out "${SSL_DIR}/ca.pem" \
  -subj "/CN=MariaDB-CA"

# --- Server certificate ---
openssl genrsa -out "${SSL_DIR}/server-key.pem" 2048
openssl req -new -nodes \
  -key "${SSL_DIR}/server-key.pem" \
  -out "${SSL_DIR}/server-req.pem" \
  -subj "/CN=database"
openssl x509 -req -days 3650 \
  -CA "${SSL_DIR}/ca.pem" \
  -CAkey "${SSL_DIR}/ca-key.pem" \
  -CAcreateserial \
  -in  "${SSL_DIR}/server-req.pem" \
  -out "${SSL_DIR}/server-cert.pem"
rm -f "${SSL_DIR}/server-req.pem"

# --- Client certificate (for wiki containers) ---
openssl genrsa -out "${SSL_DIR}/client-key.pem" 2048
openssl req -new -nodes \
  -key "${SSL_DIR}/client-key.pem" \
  -out "${SSL_DIR}/client-req.pem" \
  -subj "/CN=bluespice-client"
openssl x509 -req -days 3650 \
  -CA "${SSL_DIR}/ca.pem" \
  -CAkey "${SSL_DIR}/ca-key.pem" \
  -CAcreateserial \
  -in  "${SSL_DIR}/client-req.pem" \
  -out "${SSL_DIR}/client-cert.pem"
rm -f "${SSL_DIR}/client-req.pem"

# Restrict permissions on private keys
chmod 640 "${SSL_DIR}/ca-key.pem" "${SSL_DIR}/server-key.pem" "${SSL_DIR}/client-key.pem"
chmod 644 "${SSL_DIR}/ca.pem" "${SSL_DIR}/server-cert.pem" "${SSL_DIR}/client-cert.pem"
sudo chown -R 999:999 "${SSL_DIR}" 2>/dev/null || true
sudo chmod 750 "${SSL_DIR}" 2>/dev/null || true

# --- MariaDB SSL config ---
cat > "${CONF_DIR}/ssl.cnf" <<EOF
[mysqld]
ssl-ca   = /etc/mysql/ssl/ca.pem
ssl-cert = /etc/mysql/ssl/server-cert.pem
ssl-key  = /etc/mysql/ssl/server-key.pem

require_secure_transport = ON
EOF

echo ""
echo "Done. Certificate files:"
ls -lh "${SSL_DIR}"
echo ""
echo "MariaDB config written to: ${CONF_DIR}/ssl.cnf"
echo ""
echo "Next steps:"
echo "  1. Set DB_SSL=true in your .env file"
echo "  2. (Re-)start the stack: ./bluespice-deploy up -d"
