ARG BUILD_FROM=mauriceboe/trek:latest
FROM ${BUILD_FROM}

LABEL maintainer="Home Assistant Community <info@homeassistant.local>"
LABEL org.opencontainers.image.title="TREK - Travel Planner"
LABEL org.opencontainers.image.description="Self-hosted collaborative travel & trip planning platform for Home Assistant"
LABEL org.opencontainers.image.source="https://github.com/liketrek/TREK"

USER root

# Install bash, jq, coreutils, curl for Home Assistant options parsing & data handling
RUN if command -v apk >/dev/null 2>&1; then \
      apk add --no-cache bash jq curl coreutils; \
    elif command -v apt-get >/dev/null 2>&1; then \
      apt-get update && apt-get install -y --no-install-recommends bash jq curl coreutils ca-certificates && rm -rf /var/lib/apt/lists/*; \
    fi

# Copy custom entrypoint runner
COPY run.sh /run.sh
RUN chmod a+x /run.sh

WORKDIR /app

ENTRYPOINT ["/run.sh"]
