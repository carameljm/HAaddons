#!/bin/bash
set -e

echo "[Info] Hermes v3 Startup - Hardcoded Mounts (v1.3.8)"

# Hardcoded paden omdat de UI opties de validatie blokkeren
BIND_SOURCE="/share/hermes_windows/data"
BIND_TARGET="/data"

# Probeer te mounten
if [ -d "$BIND_SOURCE" ]; then
    echo "[Info] Koppelen van $BIND_SOURCE naar $BIND_TARGET"
    mount -o bind "$BIND_SOURCE" "$BIND_TARGET" || echo "[Error] Mount mislukt"
fi

# Hardcoded ENV variabelen voor Gateway/Root
export HERMES_ALLOW_DANGEROUS_ROOT=1
export HERMES_ALLOW_ROOT_GATEWAY=1
export HERMES_GATEWAY_ENABLED=true
export PYTHONUNBUFFERED=1

export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
export HOME=/data
export HERMES_HOME=/data
mkdir -p /data/.hermes

# Hermes vinden en starten
if ! command -v hermes &> /dev/null; then
    HERMES_BIN=$(find / -name hermes -type f -executable 2>/dev/null | grep bin/hermes | head -n 1)
    [ -n "$HERMES_BIN" ] && ln -s "$HERMES_BIN" /usr/local/bin/hermes
fi

hermes gateway run &
exec ttyd -p 8099 -W bash
