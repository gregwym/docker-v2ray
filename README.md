# docker-v2ray
A docker-compose deployment for `v2ray + WebSocket + TLS` setup.

Recommended server: [bandwagonhost.com](https://bandwagonhost.com/aff.php?aff=39559&gid=1)

## 1. CentOS Setup

1. Install tools `yum install -y iperf3 vim git`
2. `./setup-centos7.sh` which does the following

### Add EPEL Repo
```
yum install epel-release
```

### Install docker
```
yum install -y yum-utils device-mapper-persistent-data lvm2
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

## 2. Config

Update `./configs/v2ray/congfig.json`

- `client-uuid`
- `client@example.com`

Update `./configs/Caddyfile`

- Replace `localhost:8080` with real domain

## 3. Start

```
docker-compose up
```

Or run as daemon

```
docker-compose up -d
```
