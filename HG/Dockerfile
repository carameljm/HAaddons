ARG BUILD_FROM
FROM honeygain/honeygain:latest

# Switch to root to install dependencies (jq is needed to parse HA config)
USER root

# Install jq to parse JSON options from Home Assistant
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Copy the run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Set entrypoint to our script
ENTRYPOINT [ "/run.sh" ]
