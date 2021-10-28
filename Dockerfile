ARG BUILD_FROM=hassioaddons/base:8.0.3
FROM $BUILD_FROM

ENV LANG C.UTF-8

#Include all necessary libraries and tools to be install and included with the image
RUN apk add --no-cache \
        curl \
        py3-pip \
        python3 \
        pwgen \
        openssl \
        gawk \
    \
    && pip3 install --upgrade pip && \
    pip3 install paho-mqtt 
    

COPY data/run.sh /
COPY data/mqttclient.py /

WORKDIR /
CMD ["/run.sh"]

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

#Docker Labeling 
LABEL \
    io.hass.name="mpo" \
    io.hass.description="MQTT-Based Privacy Orchestrator. An add-on that works on privacy" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Ahmed Alhazmi" \
    org.opencontainers.image.title="MPO" \
    org.opencontainers.image.description="MQTT-Based Privacy Orchestrator. An add-on that works on privacy" \
    org.opencontainers.image.vendor="" \
    org.opencontainers.image.authors="Ahmed Alhazmi <aalhazmi2017@my.fit.edu>, Khulud Alawaji <kalawaji2017@my.fit.edu>, TJ OConnor <toconnor@fit.edu>" \
    org.opencontainers.image.licenses="Apache" \
    org.opencontainers.image.url="" \
    org.opencontainers.image.source="" \
    org.opencontainers.image.documentation="" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}