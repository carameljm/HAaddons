#!/bin/bash
set -e

echo "[Info] Hermes v3 Startup - Final Production Logic (v1.3.9)"

# 1. PATH instellen
export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
if ! command -v hermes &> /dev/null; then
    HERMES_BIN=$(find / -name hermes -type f -executable 2>/dev/null | grep bin/hermes | head -n 1)
    [ -n "$HERMES_BIN" ] && ln -s "$HERMES_BIN" /usr/local/bin/hermes
fi

# 2. MOUNT LOGIC
BIND_SOURCE="/share/hermes_windows/data"
BIND_TARGET="/data"

if [ -d "$BIND_SOURCE" ]; then
    echo "[Info] Koppelen van Windows Share: $BIND_SOURCE -> $BIND_TARGET"
    mount -o bind "$BIND_SOURCE" "$BIND_TARGET" || echo "[Error] Mount mislukt. Controleer Protection Mode!"
else
    echo "[Error] Bronmap $BIND_SOURCE niet gevonden op de share!"
fi

# 3. ENV & PERMISSIONS
export HERMES_ALLOW_DANGEROUS_ROOT=1
export HERMES_ALLOW_ROOT_GATEWAY=1
export HERMES_GATEWAY_ENABLED=true
export PYTHONUNBUFFERED=1
export HOME=/data
export HERMES_HOME=/data

mkdir -p /data/.hermes
chown -R root:root /data/.hermes 2>/dev/null || true

# 4. START SERVICES
echo "[Info] Starten van Hermes Gateway..."
hermes gateway run &

echo "[Info] Starten van Web Terminal..."
exec ttyd -p 8099 -W bash
