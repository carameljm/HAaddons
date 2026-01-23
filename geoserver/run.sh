#!/bin/bash
set -e

# Read configuration from options.json
CONFIG_PATH=/data/options.json
USER=$(jq --raw-output '.username' $CONFIG_PATH)
PASS=$(jq --raw-output '.password' $CONFIG_PATH)

# Export standard GeoServer environment variables
# Note: These variables depend on the specific GeoServer docker image support.
# If the image does not support them, these will be ignored.
export GEOSERVER_ADMIN_USER="$USER"
export GEOSERVER_ADMIN_PASSWORD="$PASS"

echo "Starting GeoServer..."
# Execute the default command provided by the base image
# Since we are overriding ENTRYPOINT, we need to know how to start it.
# Usually it is /usr/local/tomcat/bin/catalina.sh run or similar if based on Tomcat.
# The osgeo image often ends with startup.sh.
# We'll try to exec the default CMD if possible, but in shell script we might just run the startup script.
# Checking osgeo/geoserver dockerfile online (common knowledge): default CMD is ["/usr/local/bin/startup.sh"]

exec /usr/local/bin/startup.sh
