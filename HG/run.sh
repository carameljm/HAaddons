#!/bin/sh
set -e

# Load config from the standard Home Assistant options file
CONFIG_PATH=/data/options.json

echo "Starting Honeygain..."
echo "Reading configuration from $CONFIG_PATH..."

# Parse the JSON options provided by Home Assistant UI
EMAIL=$(jq --raw-output '.email' $CONFIG_PATH)
PASS=$(jq --raw-output '.password' $CONFIG_PATH)
DEVICE=$(jq --raw-output '.device_name' $CONFIG_PATH)
TOUCAN=$(jq --raw-output '.toucan' $CONFIG_PATH)

# Construct command arguments
ARGS="-tou-accept -email $EMAIL -pass $PASS -device $DEVICE"

if [ "$TOUCAN" = "true" ]; then
    echo "JumpTask mode enabled."
    ARGS="$ARGS -toucan"
fi

# Run the application
echo "Executing: /app/honeygain -tou-accept -email *** -pass *** -device $DEVICE"
exec /app/honeygain $ARGS
