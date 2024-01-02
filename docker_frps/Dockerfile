FROM --platform=${TARGETPLATFORM} alpine:latest

ARG TARGETPLATFORM

ENV FRPS_CONFIG=frps.ini

RUN apk --no-cache add jq

COPY . /tmp/

RUN /tmp/down_frps.sh "${TARGETPLATFORM}" && rm /tmp/* && rm -rf /var/cache/apk/*

RUN mkdir /conf
VOLUME /conf

WORKDIR /frps

ENTRYPOINT ["/bin/sh", "-c", "./frps -c /conf/$FRPS_CONFIG"]
