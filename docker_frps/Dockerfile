FROM --platform=$BUILDPLATFORM golang:alpine AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG FRP_VERSION

RUN apk --no-cache add wget jq tar

COPY down_frps.sh /build/down_frps.sh
RUN chmod +x /build/down_frps.sh && \
    /build/down_frps.sh "${TARGETPLATFORM}" "${FRP_VERSION}" "${TARGETOS}" "${TARGETARCH}" "${TARGETVARIANT}"

FROM alpine:latest

ENV FRPS_CONFIG=frps.ini

RUN apk --no-cache add ca-certificates tzdata

COPY --from=builder /frps /frps

RUN mkdir /conf
VOLUME /conf

WORKDIR /frps

ENTRYPOINT ["/bin/sh", "-c", "./frps -c /conf/$FRPS_CONFIG"]
