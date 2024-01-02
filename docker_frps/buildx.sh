#!/bin/bash
docker buildx build -t ericwang2006/frps --no-cache --platform=linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 . --push
