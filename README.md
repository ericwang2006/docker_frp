<img src="https://img.shields.io/docker/stars/ericwang2006/frpc.svg"/>
<img src="https://img.shields.io/docker/pulls/ericwang2006/frpc.svg"/>
<img src="https://img.shields.io/docker/image-size/ericwang2006/frpc/latest"/>

### What is frp?

frp is a fast reverse proxy that allows you to expose a local server located behind a NAT or firewall to the Internet. It currently supports **TCP** and **UDP**, as well as **HTTP** and **HTTPS** protocols, enabling requests to be forwarded to internal services via domain name.

frp also offers a P2P connect mode.

### Source Code

[Dockerfile](https://github.com/ericwang2006/docker_frp)

### Reference

- Supported architectures ([*more info*](https://github.com/docker-library/official-images#architectures-other-than-amd64)): `amd64`, `arm32v6`, `arm32v7`, `arm64v8`

- If you need to install docker by yourself, follow the [official installation guide](https://docs.docker.com/install/).

### Instruction

#### Client(frpc)

Create a new configuration file named `frpc.ini`. Please note that the INI file format is considered outdated; the official recommendation is to use the TOML format for configuration files. Additionally, future versions may no longer support the INI format.

Below is an example TOML file. The configuration file's name is specified by the environment variable `FRPC_CONFIG`. If the value for `FRPC_CONFIG` is not specified, it defaults to `frpc.ini`.

```shell
$ mkdir -p /etc/frpc
$ cat > /etc/frpc/frpc.toml <<EOF
serverAddr = "127.0.0.1"
serverPort = 7000

[[proxies]]
name = "test-tcp"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
EOF
```

Start a container

```shell
$ docker pull ericwang2006/frpc

$ docker run -d --name frp-client \
--network host \
-v /etc/localtime:/etc/localtime:ro \
-v /etc/frpc:/conf \
-e FRPC_CONFIG=frpc.toml \
--restart=always \
ericwang2006/frpc
```

docker-compose

```yaml
version: '2'

services:     
  frp-client:
    image: ericwang2006/frpc
    container_name: frp-client
    restart: always
    network_mode: "host"
    volumes:
      - /etc/localtime:/etc/localtime:ro        
      - /etc/frpc:/conf
    environment:
      - FRPC_CONFIG=frpc.toml
```

#### Server(frps)

Create a new configuration file named frps.ini. Please note that the INI file format is considered outdated; the official recommendation is to use the TOML format for configuration files. Additionally, future versions may no longer support the INI format.

Here's an example TOML file where the configuration file name is determined by the environment variable `FRPS_CONFIG`. If `FRPS_CONFIG` is not specified, it defaults to` frps.ini`.

```shell
$ mkdir -p /etc/frps
$ cat > /etc/frps/frps.toml <<EOF
bindAddr = "0.0.0.0"
bindPort = 7000
kcpBindPort = 7000

vhostHTTPPort = 80
vhostHTTPSPort = 443

webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "password"

auth.method = "token"
auth.token = "token"

transport.maxPoolCount = 5

allowPorts = [
  { start = 10001, end = 50000 }
]
EOF
```

Start a container

```shell
$ docker pull ericwang2006/frps

$ docker run -d --name frp-server \
--network host \
-v /etc/localtime:/etc/localtime:ro \
-v /etc/frps:/conf \
-e FRPS_CONFIG=frps.toml \
--restart=always \
ericwang2006/frps
```

docker-compose

```yaml
version: '2'

services:     
  frp-client:
    image: ericwang2006/frps
    container_name: frp-server
    restart: always
    network_mode: "host"
    volumes:
      - /etc/localtime:/etc/localtime:ro        
      - /etc/frps:/conf
    environment:
      - FRPS_CONFIG=frps.toml
```

**Warning**: The port number must be same as configuration and opened in firewall.

For more examples, please refer to the [official documentation](https://github.com/fatedier/frp)
