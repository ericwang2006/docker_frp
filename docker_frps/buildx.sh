#!/bin/bash
latest=$(wget -q -O - "https://api.github.com/repos/fatedier/frp/releases" | jq -r '.[0].tag_name')
docker buildx build -t ericwang2006/frps -t ericwang2006/frps:$latest --no-cache --platform=linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 . --push
