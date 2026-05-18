#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
echo "[Info] Hermes v3 Startup - Final Fix Attempt (v1.3.5)"

# 1. Vind het hermes-pad
export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
if ! command -v hermes &> /dev/null; then
    echo "[Info] Zoeken naar hermes executable..."
    HERMES_BIN=$(find / -name hermes -type f -executable 2>/dev/null | grep bin/hermes | head -n 1)
    if [ -n "$HERMES_BIN" ]; then
        echo "[Info] Hermes gevonden in: $HERMES_BIN"
        ln -s "$HERMES_BIN" /usr/local/bin/hermes
    fi
fi

# 2. Binds (indien mogelijk)
BIND_SOURCE=$(jq --raw-output '.bind_source // "/share/hermes_windows/data"' $CONFIG_PATH)
BIND_TARGET=$(jq --raw-output '.bind_target // "/data"' $CONFIG_PATH)
EXTRA_ENV=$(jq --raw-output '.extra_env // empty' $CONFIG_PATH)

if [ -d "$BIND_SOURCE" ]; then
    echo "[Info] Koppelen van share..."
    mount -o bind "$BIND_SOURCE" "$BIND_TARGET" || echo "[Error] Mount mislukt (rechten?)"
fi

# 3. ENV variabelen (belangrijk voor gateway/root)
if [ -n "$EXTRA_ENV" ]; then
    IFS=',' read -ra ADDR <<< "$EXTRA_ENV"
    for i in "${ADDR[@]}"; do
        export "$i"
    done
fi

export HOME=/data
export HERMES_HOME=/data
mkdir -p /data/.hermes

# 4. Starten
echo "[Info] Starten van Hermes Gateway..."
hermes gateway run &

echo "[Info] Klaar voor gebruik. Starten van Terminal..."
exec ttyd -p 8099 -W bash
