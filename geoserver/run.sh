#!/bin/bash
set -e

# Read configuration from options.json
CONFIG_PATH=/data/options.json
USER=$(jq --raw-output '.username' $CONFIG_PATH)
PASS=$(jq --raw-output '.password' $CONFIG_PATH)

# Export environment variables for Kartoza GeoServer
export GEOSERVER_ADMIN_USER="$USER"
export GEOSERVER_ADMIN_PASSWORD="$PASS"

echo "Starting GeoServer..."

# The Kartoza image uses a startup script as entrypoint.
# We need to execute it.
# Inspecting Kartoza Dockerfile reveals ENTRYPOINT is based on /scripts/entrypoint.sh 
# but usually it runs /usr/local/tomcat/bin/catalina.sh run
# However, Kartoza's image is complex and handles setup in entrypoint.
# We should probably just call the original entrypoint or command.
# The Kartoza image has CMD ["/scripts/entrypoint.sh"] in older versions or CMD ["catalina.sh", "run"]
# Let's try executing the standard tomcat startup which is common for this image if we replaced the CMD.
# Wait, if we replace CMD in Dockerfile, we typically replace the arguments to ENTRYPOINT.
# Add-ons override the ENTRYPOINT of the base image.
# So we are responsible for starting the service.

# Best bet for Kartoza image:
# It puts scripts in /scripts
# We should run /scripts/entrypoint.sh if it exists, or just start tomcat.
# Let's assume standard behavior for this well-known image.
# Actually, Home Assistant Add-on base images (S6 overlay) are not used here, we are using a direct base.
# BUT, Home Assistant Add-on mechanism overrides the entrypoint to S6 if we used a HA base image.
# We are NOT using a HA base image (like ghcr.io/home-assistant/amd64-base), we are FROM kartoza/geoserver.
# The HA Supervisor runs the container. It respects the CMD/ENTRYPOINT unless overridden?
# Actually, for add-ons, we usually define the startup behavior.
# In our Dockerfile we have `CMD [ "/run.sh" ]`.
# This overrides the base image CMD.
# If the base image had an ENTRYPOINT that does setup, it *might* still run IF we didn't override it, OR if we respect it.
# Check Kartoza Dockerfile: ENTRYPOINT ["/bin/bash", "/scripts/entrypoint.sh"] typically.
# If we want that setup (which creates users etc), we should call it.

if [ -f /scripts/entrypoint.sh ]; then
    echo "Delegating to Kartoza entrypoint..."
    exec /scripts/entrypoint.sh
else
    echo "Kartoza entrypoint not found, trying common tomcat start..."
    # Fallback
    exec /usr/local/tomcat/bin/catalina.sh run
fi
