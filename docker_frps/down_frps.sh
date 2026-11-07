#!/bin/sh
set -e

PLATFORM="$1"
FRP_VERSION="$2"
TARGETOS="$3"
TARGETARCH="$4"
TARGETVARIANT="$5"

if [ -z "$FRP_VERSION" ]; then
    latest=$(wget -q -O - "https://api.github.com/repos/fatedier/frp/releases/latest" 2>/dev/null | jq -r '.tag_name // empty')
    if [ -z "$latest" ] || [ "$latest" = "null" ]; then
        latest=$(wget -q -O - "https://api.github.com/repos/fatedier/frp/releases" | jq -r '.[0].tag_name')
    fi
    FRP_VERSION="$latest"
fi
FRP_VERSION=${FRP_VERSION#v}

if [ -z "$PLATFORM" ]; then
    if [ -n "$TARGETARCH" ]; then
        PLATFORM="linux/$TARGETARCH"
        [ -n "$TARGETVARIANT" ] && PLATFORM="$PLATFORM/$TARGETVARIANT"
    else
        PLATFORM="linux/amd64"
    fi
fi

echo "Preparing FRPS for Platform: $PLATFORM, Version: $FRP_VERSION"

case "$PLATFORM" in
    linux/amd64)
        pkg_names="amd64"
        go_arch="amd64"
        ;;
    linux/386)
        pkg_names="386"
        go_arch="386"
        ;;
    linux/arm/v6)
        pkg_names="arm"
        go_arch="arm"
        go_arm="6"
        ;;
    linux/arm/v7)
        pkg_names="arm_hf arm"
        go_arch="arm"
        go_arm="7"
        ;;
    linux/arm64|linux/arm64/v8)
        pkg_names="arm64"
        go_arch="arm64"
        ;;
    linux/riscv64)
        pkg_names="riscv64"
        go_arch="riscv64"
        ;;
    linux/ppc64le)
        pkg_names="ppc64le"
        go_arch="ppc64le"
        ;;
    linux/s390x)
        pkg_names="s390x"
        go_arch="s390x"
        ;;
    *)
        echo "Error: Not supported OS Architecture: $PLATFORM"
        exit 1
        ;;
esac

DOWNLOADED=0
for name in $pkg_names; do
    URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${name}.tar.gz"
    echo "Attempting to download pre-built binary: $URL"
    if wget -q -c "$URL" -O "/tmp/frp.tar.gz" 2>/dev/null && [ -s "/tmp/frp.tar.gz" ]; then
        if tar -tzf "/tmp/frp.tar.gz" >/dev/null 2>&1; then
            echo "Successfully downloaded pre-built binary for $name"
            DOWNLOADED=1
            break
        fi
        rm -f "/tmp/frp.tar.gz"
    fi
done

mkdir -p /frps
if [ "$DOWNLOADED" -eq 1 ]; then
    tar -xzf /tmp/frp.tar.gz -C /tmp/
    cp -f /tmp/frp_${FRP_VERSION}_linux_*/frps* /frps/
    [ -f /tmp/frp_${FRP_VERSION}_linux_*/LICENSE ] && cp -f /tmp/frp_${FRP_VERSION}_linux_*/LICENSE /frps/
    [ -f /tmp/frp_${FRP_VERSION}_linux_*/frps.toml ] && cp -f /tmp/frp_${FRP_VERSION}_linux_*/frps.toml /frps/
    rm -rf /tmp/frp*
else
    echo "Pre-built binary not found. Compiling from source for $PLATFORM (GOARCH=$go_arch)..."
    SRC_DIR="/tmp/frp_source"
    mkdir -p "$SRC_DIR"
    wget -q -O - "https://github.com/fatedier/frp/archive/refs/tags/v${FRP_VERSION}.tar.gz" | tar -xz -C "$SRC_DIR" --strip-components=1
    cd "$SRC_DIR"
    export CGO_ENABLED=0
    export GOOS=linux
    export GOARCH="$go_arch"
    [ -n "$go_arm" ] && export GOARM="$go_arm"

    TAGS="frps"
    if [ ! -d "web/frps/dist" ]; then
        TAGS="frps,noweb"
    fi
    go build -trimpath -ldflags "-s -w" -tags "$TAGS" -o /frps/frps ./cmd/frps
    [ -f "LICENSE" ] && cp LICENSE /frps/
    [ -f "conf/frps.toml" ] && cp conf/frps.toml /frps/
    cd /
    rm -rf "$SRC_DIR"
fi

chmod +x /frps/frps
echo "FRPS build finished successfully for $PLATFORM"
