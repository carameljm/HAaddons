#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
echo "[Info] Inlezen van configuratie uit $CONFIG_PATH..."

BIND_SOURCE=$(jq --raw-output '.bind_source // empty' $CONFIG_PATH)
BIND_TARGET=$(jq --raw-output '.bind_target // empty' $CONFIG_PATH)
EXTRA_ENV=$(jq --raw-output '.extra_env // empty' $CONFIG_PATH)

if [ -n "$BIND_SOURCE" ] && [ -n "$BIND_TARGET" ]; then
    if [ -d "$BIND_SOURCE" ]; then
        echo "[Info] Koppelen van $BIND_SOURCE aan $BIND_TARGET..."
        mount --rbind "$BIND_SOURCE" "$BIND_TARGET"
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
chown -R root:root /data/.hermes 2>/dev/null || true
mkdir -p /data/.hermes

hermes gateway run &
exec ttyd -p 8099 -W bash
