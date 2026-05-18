#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
echo "[Info] Hermes v3 Startup - Final Mount Attempt Logic"

# Wait for supervisor to stabilize
sleep 3

BIND_SOURCE=$(jq --raw-output '.bind_source // "/share/hermes_windows/data"' $CONFIG_PATH)
BIND_TARGET=$(jq --raw-output '.bind_target // "/data"' $CONFIG_PATH)
EXTRA_ENV=$(jq --raw-output '.extra_env // empty' $CONFIG_PATH)

echo "[Info] Configured Bind: $BIND_SOURCE -> $BIND_TARGET"

if [ -d "$BIND_SOURCE" ]; then
    echo "[Info] Path $BIND_SOURCE exists. Attempting mount -o bind..."
    # Gebruik expliciet -o bind, dit werkt soms beter in HAOS containers
    if mount -o bind "$BIND_SOURCE" "$BIND_TARGET"; then
        echo "[Success] Windows Share succesvol gekoppeld aan $BIND_TARGET"
    else
        echo "[Error] Mounten mislukt! Zorg dat Beschermingsmodus (Protection Mode) UIT staat."
        # Debugging: toon mount foutmelding direct
        mount -o bind "$BIND_SOURCE" "$BIND_TARGET" 2>&1 || true
    fi
else
    echo "[Error] Bronmap $BIND_SOURCE niet gevonden!"
fi

if [ -n "$EXTRA_ENV" ]; then
    IFS=',' read -ra ADDR <<< "$EXTRA_ENV"
    for i in "${ADDR[@]}"; do
        export "$i"
    done
fi

export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
export HOME=/data
export HERMES_HOME=/data
mkdir -p /data/.hermes

hermes gateway run &
exec ttyd -p 8099 -W bash
