#!/bin/bash
set -e

echo "[Info] Hermes v3 Startup - Gateway Activation Mode (v1.4.3)"

# 1. PATH setup
export PATH=$PATH:/root/.local/bin:/usr/local/bin:/opt/hermes/bin
if ! command -v hermes &> /dev/null; then
    HERMES_BIN=$(find / -name hermes -type f -executable 2>/dev/null | grep bin/hermes | head -n 1)
    [ -n "$HERMES_BIN" ] && ln -s "$HERMES_BIN" /usr/local/bin/hermes
fi

# 2. SURGICAL LINKS
SHARE_DATA="/share/hermes_windows/data"
if [ -d "$SHARE_DATA" ]; then
    echo "[Info] Windows Share gevonden. Koppelen van data..."
    ITEMS=("skills" "memories" "sessions" "auth.json" "config.yaml" "state.db")
    for item in "${ITEMS[@]}"; do
        if [ -e "$SHARE_DATA/$item" ]; then
            rm -rf "/data/$item"
            ln -s "$SHARE_DATA/$item" "/data/$item"
        fi
    done
fi

# 3. FORCE GATEWAY TRIGGERS
export HERMES_ALLOW_DANGEROUS_ROOT=1
export HERMES_ALLOW_ROOT_GATEWAY=1
export HERMES_GATEWAY_ENABLED=true
export GATEWAY_ALLOW_ALL_USERS=true
export PYTHONUNBUFFERED=1
export HOME="/data"
export HERMES_HOME="/data"

# Zorg dat de .hermes map wordt gerespecteerd
mkdir -p /data/.hermes
if [ -d "$SHARE_DATA/.hermes" ]; then
    cp -rn "$SHARE_DATA/.hermes/." /data/.hermes/ 2>/dev/null || true
fi

# 4. START
echo "[Info] Starten van Hermes Gateway..."
hermes gateway run &

echo "[Info] Gateway geactiveerd op poort 8642. Terminal poort 8099."
exec ttyd -p 8099 -W bash
