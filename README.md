# Setup

## Installation

```
sudo su
cd /etc/wireguard
git clone git@github.com:jsovernigo/wireguard-server-config-helpers && mv wireguard-server-config-helpers/* ./
```

## Generate Server Config

```
sudo su
cd /etc/wireguard
./mkserver.sh <interface> <server ip> <port>
```

## Start/enable server

```
sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0
```

## Create client configs
Note that the server should be running when you run ./mkconfig.sh

```
sudo su
cd /etc/wireguard
./mkconfig.sh <wginterface> <server host> <name> <ip> <port>
```

Note that "server host" just refers to any reachable IP or resolvable url name where the server is hosted, e.g., vpn.mysite.com

# View status

`sudo wg`
