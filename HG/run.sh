#!/bin/sh
set -e

echo "Starting Honeygain Add-on..."

# Read configuration from Home Assistant's options.json
CONFIG_PATH=/data/options.json

echo "Reading configuration..."
EMAIL=$(jq --raw-output '.email' $CONFIG_PATH)
PASS=$(jq --raw-output '.password' $CONFIG_PATH)
DEVICE=$(jq --raw-output '.device_name' $CONFIG_PATH)
TOUCAN=$(jq --raw-output '.toucan' $CONFIG_PATH)

ARGS="-tou-accept -email $EMAIL -pass $PASS -device $DEVICE"

if [ "$TOUCAN" = "true" ]; then
    echo "JumpTask mode enabled."
    ARGS="$ARGS -toucan"
fi

echo "Launching Honeygain with device name: $DEVICE"
# Execute the binary (binary name depends on the base image, usually just 'honeygain' or entrypoint logic)
# We execute the native binary found in the official image
exec /app/honeygain $ARGS
