FROM --platform=$BUILDPLATFORM golang:alpine AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG FRP_VERSION

RUN apk --no-cache add wget jq tar

COPY down_frpc.sh /build/down_frpc.sh
RUN chmod +x /build/down_frpc.sh && \
    /build/down_frpc.sh "${TARGETPLATFORM}" "${FRP_VERSION}" "${TARGETOS}" "${TARGETARCH}" "${TARGETVARIANT}"

FROM alpine:latest

ENV FRPC_CONFIG=frpc.ini

RUN apk --no-cache add ca-certificates tzdata

COPY --from=builder /frpc /frpc

RUN mkdir /conf
VOLUME /conf

WORKDIR /frpc

ENTRYPOINT ["/bin/sh", "-c", "./frpc -c /conf/$FRPC_CONFIG"]
