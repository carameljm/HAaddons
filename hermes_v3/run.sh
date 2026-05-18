#!/bin/bash
set -e

echo "[Info] Hermes v3 Startup - High Compatibility Mode (v1.4.0)"

# 1. PATH setup
export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
if ! command -v hermes &> /dev/null; then
    HERMES_BIN=$(find / -name hermes -type f -executable 2>/dev/null | grep bin/hermes | head -n 1)
    [ -n "$HERMES_BIN" ] && ln -s "$HERMES_BIN" /usr/local/bin/hermes
fi

# 2. MOUNT LOGIC
BIND_SOURCE="/share/hermes_windows/data"
BIND_TARGET="/data"

if [ -d "$BIND_SOURCE" ]; then
    echo "[Info] Poging tot koppelen van Windows Share: $BIND_SOURCE"
    mount -o bind "$BIND_SOURCE" "$BIND_TARGET" || echo "[Error] Mount mislukt. Zet BESCHERMINGSMODUS UIT in de Info tab!"
else
    echo "[Error] Bronmap $BIND_SOURCE niet gevonden."
fi

# 3. GLOBAL ENV
export HERMES_ALLOW_DANGEROUS_ROOT=1
export HERMES_ALLOW_ROOT_GATEWAY=1
export HERMES_GATEWAY_ENABLED=true
export PYTHONUNBUFFERED=1
export HOME=/data
export HERMES_HOME=/data

mkdir -p /data/.hermes
chown -R root:root /data/.hermes 2>/dev/null || true

# 4. START
echo "[Info] Starten van Hermes Gateway..."
hermes gateway run &

echo "[Info] Klaar. Terminal poort 8099."
exec ttyd -p 8099 -W bash
