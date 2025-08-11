FROM alpine:latest

ARG TARGETPLATFORM

ENV FRPC_CONFIG=frpc.ini

RUN apk --no-cache add jq ca-certificates

COPY . /tmp/

RUN /tmp/down_frpc.sh "${TARGETPLATFORM}" && rm /tmp/* && rm -rf /var/cache/apk/*

RUN mkdir /conf
VOLUME /conf

WORKDIR /frpc

ENTRYPOINT ["/bin/sh", "-c", "./frpc -c /conf/$FRPC_CONFIG"]
