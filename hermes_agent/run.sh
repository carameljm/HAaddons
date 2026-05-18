#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
echo "[Info] Hermes v3 Startup - Step-by-Step Mount Logic"

# Wacht heel even tot de Supervisor alle mappen heeft aangeboden
sleep 2

BIND_SOURCE=$(jq --raw-output '.bind_source // "/share/hermes_windows/data"' $CONFIG_PATH)
BIND_TARGET=$(jq --raw-output '.bind_target // "/data"' $CONFIG_PATH)
EXTRA_ENV=$(jq --raw-output '.extra_env // empty' $CONFIG_PATH)

echo "[Info] Configured Bind: $BIND_SOURCE -> $BIND_TARGET"

# Check of source bestaat, anders maken we hem
if [ ! -d "$BIND_SOURCE" ]; then
    echo "[Info] Aanmaken van share map $BIND_SOURCE..."
    mkdir -p "$BIND_SOURCE"
fi

# De cruciale mount stap
echo "[Info] Poging tot mounten van $BIND_SOURCE op $BIND_TARGET..."
if mount --bind "$BIND_SOURCE" "$BIND_TARGET"; then
    echo "[Success] Windows Share succesvol gekoppeld aan $BIND_TARGET"
else
    echo "[Error] Mounten mislukt! Controleer of 'Privileged' aan staat in de Add-on instellingen."
fi

# Omgevingsvariabelen
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
