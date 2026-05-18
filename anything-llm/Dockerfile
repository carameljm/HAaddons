ARG BUILD_FROM
FROM mintplexlabs/anythingllm:latest

# Use root to setup HA specific requirements
USER root

# Install jq for parsing options.json
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    rm -rf /var/lib/apt/lists/*

# Copy rootfs
COPY rootfs /

# Ensure execution rights
RUN chmod a+x /etc/services.d/anythingllm/run

# AnythingLLM storage is at /app/server/storage
# We want to link it to /config/anything-llm/storage for HA persistence
RUN mkdir -p /app/server/storage && \
    chown -R anythingllm:anythingllm /app/server/storage

ENTRYPOINT ["/init"]
