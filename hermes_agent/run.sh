#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
echo "[Info] Hermes v3 Startup - Deep Debug Mode"

# Debug: check if /share is actually visible to the container
ls -ld /share || echo "[Error] /share is NOT visible"
ls -ld /share/hermes_windows/data 2>/dev/null || echo "[Error] Windows share data dir NOT found"

BIND_SOURCE=$(jq --raw-output '.bind_source // empty' $CONFIG_PATH)
BIND_TARGET=$(jq --raw-output '.bind_target // empty' $CONFIG_PATH)
EXTRA_ENV=$(jq --raw-output '.extra_env // empty' $CONFIG_PATH)

echo "[Info] Configured Bind: $BIND_SOURCE -> $BIND_TARGET"

if [ -n "$BIND_SOURCE" ] && [ -n "$BIND_TARGET" ]; then
    if [ -d "$BIND_SOURCE" ]; then
        echo "[Info] Path $BIND_SOURCE exists. Attempting mount..."
        # Gebruik mount met expliciete types om zeker te zijn
        mount --bind "$BIND_SOURCE" "$BIND_TARGET" || echo "[Error] Mount failed."
    else
        echo "[Error] Source directory $BIND_SOURCE does not exist."
    fi
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

hermes gateway run &
exec ttyd -p 8099 -W bash
