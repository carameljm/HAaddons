ARG BUILD_FROM
FROM mintplexlabs/anythingllm:latest

# Use root to setup HA specific requirements
USER root

# Install jq for parsing options.json
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    rm -rf /var/lib/apt/lists/*

# Copy run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Ensure storage directory exists and has correct permissions
RUN mkdir -p /app/server/storage && \
    chown -R anythingllm:anythingllm /app/server/storage

# We exit to the run.sh script which handles the HA environment
ENTRYPOINT []
CMD [ "/run.sh" ]
