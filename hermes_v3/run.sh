#!/bin/bash
set -e

echo "[Info] Hermes v3 Startup - Home Redirection Mode (v1.4.1)"

# 1. PATH setup
export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
if ! command -v hermes &> /dev/null; then
    HERMES_BIN=$(find / -name hermes -type f -executable 2>/dev/null | grep bin/hermes | head -n 1)
    if [ -n "$HERMES_BIN" ]; then
        ln -s "$HERMES_BIN" /usr/local/bin/hermes
    fi
fi

# 2. HOME REDIRECTION
# We omzeilen 'mount' volledig door de applicatie te vertellen waar zijn data staat.
SHARE_PATH="/share/hermes_windows/data"

if [ -d "$SHARE_PATH" ]; then
    echo "[Info] Windows Share gevonden op $SHARE_PATH. Gebruik dit als data map."
    export HOME="$SHARE_PATH"
    export HERMES_HOME="$SHARE_PATH"
else
    echo "[Waarschuwing] Share map $SHARE_PATH niet gevonden. We vallen terug op /data."
    export HOME="/data"
    export HERMES_HOME="/data"
fi

# 3. GLOBAL ENV
export HERMES_ALLOW_DANGEROUS_ROOT=1
export HERMES_ALLOW_ROOT_GATEWAY=1
export HERMES_GATEWAY_ENABLED=true
export PYTHONUNBUFFERED=1

mkdir -p "$HOME/.hermes"
chown -R root:root "$HOME/.hermes" 2>/dev/null || true

# 4. START
echo "[Info] Starten van Hermes Gateway..."
hermes gateway run &

echo "[Info] Terminal gestart. Hermes werkt nu op de share via HOME redirection."
exec ttyd -p 8099 -W bash
