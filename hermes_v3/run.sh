#!/bin/bash
set -e

echo "[Info] Starten van Hermes Agent (Stabiele Modus)..."

# SYNC VAN SHARE (Indien aanwezig)
if [ -d "/share/hermes_windows/data" ]; then
    echo "[Info] Importeren van data vanaf Windows Share..."
    # We kopiëren bestanden die er nog niet zijn ('n') om niks te breken
    cp -rn /share/hermes_windows/data/. /data/ 2>/dev/null || true
fi

CONFIG_PATH=/data/options.json
API_SERVER_ENABLED=$(jq --raw-output '.api_server_enabled' $CONFIG_PATH)
API_SERVER_KEY=$(jq --raw-output '.api_server_key' $CONFIG_PATH)

export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
export HOME=/data
export HERMES_HOME=/data
mkdir -p /data/.hermes

echo "[Info] Configuring Gateway..."
cat <<EON > /data/.hermes/.env
API_SERVER_ENABLED=${API_SERVER_ENABLED}
API_SERVER_KEY=${API_SERVER_KEY}
HERMES_ALLOW_ROOT_GATEWAY=1
HERMES_GATEWAY_ENABLED=true
GATEWAY_ALLOW_ALL_USERS=true
EON

if ! command -v hermes &> /dev/null; then
    HERMES_BIN=$(find / -name hermes -type f -executable 2>/dev/null | grep bin/hermes | head -n 1)
    if [ -n "$HERMES_BIN" ]; then
        ln -s "$HERMES_BIN" /usr/local/bin/hermes
    fi
fi

echo "[Info] Starting Gateway..."
hermes gateway run &

echo "[Info] Starting Terminal..."
exec ttyd -p 8099 -W bash
