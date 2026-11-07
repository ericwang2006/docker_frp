#!/bin/bash
set -e

# Get the latest FRP release version
latest=$(wget -q -O - "https://api.github.com/repos/fatedier/frp/releases" | jq -r '.[0].tag_name')

# Build and push multi-architecture images supporting all Alpine architectures
docker buildx build \
  -t ericwang2006/frps:latest \
  -t ericwang2006/frps:$latest \
  --build-arg FRP_VERSION=$latest \
  --no-cache \
  --platform=linux/amd64,linux/386,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/riscv64,linux/s390x \
  --push \
  .
