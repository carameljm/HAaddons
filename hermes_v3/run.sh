#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
echo "[Info] Inlezen van configuratie uit $CONFIG_PATH..."

BIND_SOURCE=$(jq --raw-output '.bind_source // empty' $CONFIG_PATH)
BIND_TARGET=$(jq --raw-output '.bind_target // empty' $CONFIG_PATH)
EXTRA_ENV=$(jq --raw-output '.extra_env // empty' $CONFIG_PATH)

# SYMLINK STRATEGY: Maak links van de share naar /data
if [ -n "$BIND_SOURCE" ] && [ -d "$BIND_SOURCE" ]; then
    echo "[Info] Maaken van symlinks van $BIND_SOURCE naar $BIND_TARGET..."
    for item in "$BIND_SOURCE"/*; do
        [ -e "$item" ] || continue
        target_name=$(basename "$item")
        # Overschrijf lokale data met link naar de share
        rm -rf "$BIND_TARGET/$target_name"
        ln -s "$item" "$BIND_TARGET/$target_name"
        echo "[Info] Gelinkt: $target_name"
    done
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

# Start de services
hermes gateway run &
exec ttyd -p 8099 -W bash
