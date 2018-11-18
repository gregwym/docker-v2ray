# v2ray + WebSocket + TLS

## Setup host
### Add EPEL Repo
```
yum install epel-release
```

### Run speed test with iperf3
```
yum install iperf3
iperf3 -s
```

### Install docker
```
yum install -y yum-utils   device-mapper-persistent-data   lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce
systemctl start docker
systemctl enable docker
```

### Install docker compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## Config

Update `./configs/v2ray/congfig.json`

- `client-uuid`
- `client@example.com`

Update `./configs/Caddyfile`

- Replace `example.com` with real domain

## Start

```
docker-compose up
```