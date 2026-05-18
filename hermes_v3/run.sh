#!/bin/bash
set -e

echo "[Info] Hermes v3 Startup - Surgical Link Mode (v1.4.2)"

# 1. PATH setup
export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
if ! command -v hermes &> /dev/null; then
    HERMES_BIN=$(find / -name hermes -type f -executable 2>/dev/null | grep bin/hermes | head -n 1)
    [ -n "$HERMES_BIN" ] && ln -s "$HERMES_BIN" /usr/local/bin/hermes
fi

# 2. LINK LOGIC
SHARE_DATA="/share/hermes_windows/data"

if [ -d "$SHARE_DATA" ]; then
    echo "[Info] Windows Share gevonden. Linken van vitale mappen..."
    
    ITEMS=("skills" "memories" "sessions" "auth.json" "config.yaml" "state.db")
    
    for item in "${ITEMS[@]}"; do
        if [ -e "$SHARE_DATA/$item" ]; then
            echo "  Linking $item..."
            rm -rf "/data/$item"
            ln -s "$SHARE_DATA/$item" "/data/$item"
        fi
    done
fi

# 3. GLOBAL ENV
export HERMES_ALLOW_DANGEROUS_ROOT=1
export HERMES_ALLOW_ROOT_GATEWAY=1
export HERMES_GATEWAY_ENABLED=true
export PYTHONUNBUFFERED=1
export HOME="/data"
export HERMES_HOME="/data"

mkdir -p /data/.hermes
chown -R root:root /data/.hermes 2>/dev/null || true

# 4. START
echo "[Info] Starten van Hermes Gateway..."
hermes gateway run &

echo "[Info] Klaar. Hermes is selectief gekoppeld aan de Windows Share."
exec ttyd -p 8099 -W bash
