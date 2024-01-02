#!/bin/sh

latest=$(wget -q -O - "https://api.github.com/repos/fatedier/frp/releases" | jq -r '.[0].tag_name')
FRP_VERSION=${latest#v}

PLATFORM=$1
if [ -z "$PLATFORM" ]; then
    pkg_name="amd64"
else
    case "$PLATFORM" in
        linux/386)
            pkg_name="386"
            ;;
        linux/amd64)
            pkg_name="amd64"
            ;;
        linux/arm/v6|linux/arm/v7)
            pkg_name="arm"
            ;;
        linux/arm64|linux/arm64/v8)
            pkg_name="arm64"
            ;;
        *)
            pkg_name=""
            ;;
    esac
fi
[ -z "${pkg_name}" ] && echo "Error: Not supported OS Architecture" && exit 1

# https://git.xfj0.cn/

wget https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${pkg_name}.tar.gz &&
    tar -xf frp_${FRP_VERSION}_linux_${pkg_name}.tar.gz &&
    mkdir /frpc &&
    cp frp_${FRP_VERSION}_linux_${pkg_name}/frpc* /frpc/ &&
    rm -rf frp_${FRP_VERSION}_linux_${pkg_name}*
