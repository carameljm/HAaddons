#!/usr/bin/env bash
set -e

echo "============================================================"
echo " Starting TREK - Travel Planner"
echo " Home Assistant Add-on Runner"
echo "============================================================"

CONFIG_PATH="/data/options.json"

# Read Home Assistant configured options if present
if [ -f "$CONFIG_PATH" ]; then
  echo "[INFO] Loading configuration from $CONFIG_PATH..."

  TZ_OPT=$(jq -r '.tz // empty' "$CONFIG_PATH")
  if [ -n "$TZ_OPT" ] && [ "$TZ_OPT" != "null" ]; then
    export TZ="$TZ_OPT"
  fi

  LOG_OPT=$(jq -r '.log_level // empty' "$CONFIG_PATH")
  if [ -n "$LOG_OPT" ] && [ "$LOG_OPT" != "null" ]; then
    export LOG_LEVEL="$LOG_OPT"
  fi

  EMAIL_OPT=$(jq -r '.admin_email // empty' "$CONFIG_PATH")
  if [ -n "$EMAIL_OPT" ] && [ "$EMAIL_OPT" != "null" ]; then
    export ADMIN_EMAIL="$EMAIL_OPT"
  fi

  PWD_OPT=$(jq -r '.admin_password // empty' "$CONFIG_PATH")
  if [ -n "$PWD_OPT" ] && [ "$PWD_OPT" != "null" ]; then
    export ADMIN_PASSWORD="$PWD_OPT"
  fi

  KEY_OPT=$(jq -r '.encryption_key // empty' "$CONFIG_PATH")
  if [ -n "$KEY_OPT" ] && [ "$KEY_OPT" != "null" ]; then
    export ENCRYPTION_KEY="$KEY_OPT"
  fi
fi

# Ensure persistent encryption key
KEY_FILE="/data/.trek_encryption_key"
if [ -z "$ENCRYPTION_KEY" ]; then
  if [ -f "$KEY_FILE" ]; then
    export ENCRYPTION_KEY=$(cat "$KEY_FILE")
    echo "[INFO] Using existing persistent encryption key from $KEY_FILE"
  else
    echo "[INFO] Generating new random 32-byte encryption key..."
    NEW_KEY=$(od -vN "32" -An -tx1 /dev/urandom | tr -d " \n" || head -c 32 /dev/urandom | xxd -p -c 32)
    echo "$NEW_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    export ENCRYPTION_KEY="$NEW_KEY"
    echo "[INFO] Encryption key saved to $KEY_FILE"
  fi
fi

# Setup persistent directory structure
PERSIST_DATA="/share/trek/data"
PERSIST_UPLOADS="/share/trek/uploads"

mkdir -p "$PERSIST_DATA" "$PERSIST_UPLOADS"

# Target app paths in container
APP_DATA="/app/data"
APP_UPLOADS="/app/uploads"

# Symlink persistent data so nothing is lost upon add-on update/reboot
if [ -d "$APP_DATA" ] && [ ! -L "$APP_DATA" ]; then
  cp -rn "$APP_DATA"/* "$PERSIST_DATA"/ 2>/dev/null || true
  rm -rf "$APP_DATA"
fi
ln -sfn "$PERSIST_DATA" "$APP_DATA"

if [ -d "$APP_UPLOADS" ] && [ ! -L "$APP_UPLOADS" ]; then
  cp -rn "$APP_UPLOADS"/* "$PERSIST_UPLOADS"/ 2>/dev/null || true
  rm -rf "$APP_UPLOADS"
fi
ln -sfn "$PERSIST_UPLOADS" "$APP_UPLOADS"

# Rechten instellen zodat de 'node' gebruiker (UID 1000) mag schrijven naar /share/trek
chmod -R 777 "$PERSIST_DATA" "$PERSIST_UPLOADS" 2>/dev/null || true
chown -R 1000:1000 "$PERSIST_DATA" "$PERSIST_UPLOADS" "$APP_DATA" "$APP_UPLOADS" 2>/dev/null || true

export NODE_ENV=production
export PORT=3099

echo "[INFO] Data directories mapped:"
echo "       -> App Data: $PERSIST_DATA"
echo "       -> Uploads:  $PERSIST_UPLOADS"
echo "[INFO] Timezone set to: ${TZ:-Europe/Brussels}"
echo "[INFO] Starting TREK on port ${PORT}..."
echo "============================================================"

# Overdragen aan het officiële TREK container entrypoint
if [ -x "/usr/local/bin/trek-entrypoint" ]; then
  echo "[INFO] Executing official /usr/local/bin/trek-entrypoint..."
  exec /usr/local/bin/trek-entrypoint "$@"
elif [ -f "/app/server/dist/index.js" ]; then
  exec node /app/server/dist/index.js
elif [ -f "/app/dist/server/index.js" ]; then
  exec node /app/dist/server/index.js
elif [ -f "/app/dist/index.js" ]; then
  exec node /app/dist/index.js
elif [ -f "/app/server.js" ]; then
  exec node /app/server.js
else
  FOUND_ENTRY=$(find /app -name "index.js" -not -path "*/node_modules/*" 2>/dev/null | head -n 1)
  if [ -n "$FOUND_ENTRY" ]; then
    exec node "$FOUND_ENTRY"
  else
    echo "[ERROR] Kon startbestand van de container niet vinden."
    exit 1
  fi
fi
