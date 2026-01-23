ARG BUILD_FROM
FROM docker.osgeo.org/geoserver/geoserver

# Install jq for parsing options.json
USER root
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Copy run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
