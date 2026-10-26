#!/usr/bin/env bashio
set -e

bashio::log.info "Starting AnythingLLM..."

# AnythingLLM uses /app/server/storage for everything
# HA options are in /data/options.json
STORAGE_DIR=$(bashio::config 'STORAGE_DIR')

# Default if not set
if [ -z "$STORAGE_DIR" ]; then
    STORAGE_DIR="/config/anything-llm/storage"
fi

bashio::log.info "Storage directory: $STORAGE_DIR"

# Ensure storage directory exists
mkdir -p "$STORAGE_DIR"
chown -R anythingllm:anythingllm "$STORAGE_DIR"

# AnythingLLM container already has /app/server/storage as a directory
# We need to symlink it to our persistent location
if [ ! -L /app/server/storage ]; then
    bashio::log.info "Setting up persistent storage link..."
    
    # If there's already data in the container's storage, move it to the persistent volume
    if [ -d /app/server/storage ] && [ "$(ls -A /app/server/storage)" ]; then
        cp -rn /app/server/storage/* "$STORAGE_DIR/" || true
    fi
    
    rm -rf /app/server/storage
    ln -s "$STORAGE_DIR" /app/server/storage
    chown -h anythingllm:anythingllm /app/server/storage
fi

# Set the UID/GID if provided (AnythingLLM defaults to 1000:1000)
# Run original entrypoint as anythingllm user
# The original image uses tini as entrypoint, but we can call the script directly
exec s6-setuidgid anythingllm /bin/bash /usr/local/bin/docker-entrypoint.sh
