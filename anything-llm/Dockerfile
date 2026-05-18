ARG BUILD_FROM
FROM mintplexlabs/anythingllm:latest

# Use root to setup HA specific requirements
USER root

# Install dependencies needed for HA environment shells
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install bashio (manually since we are not using a Hass.io base image)
RUN curl -J -L -o /tmp/bashio.tar.gz "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" && \
    mkdir /tmp/bashio && \
    tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio && \
    mv /tmp/bashio/lib /usr/lib/bashio && \
    ln -s /usr/lib/bashio/bashio /usr/bin/bashio && \
    rm -rf /tmp/bashio.tar.gz /tmp/bashio

# Copy run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Ensure storage directory exists and has correct permissions
RUN mkdir -p /app/server/storage && \
    chown -R anythingllm:anythingllm /app/server/storage

# HA needs to run as root to setup the environment, run.sh will drop privileges
ENTRYPOINT []
CMD [ "/run.sh" ]
