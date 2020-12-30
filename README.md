# Setup

## Make server keys

```
sudo su
cd /etc/wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

## Make base server config

- Check to make sure the interface (eg eth0) is correct in the iptables rules in the template.

```
sudo su
cp wg0.conf.template /etc/wireguard/wg0.conf
# Add the private key to /etc/wireguard/wg0.conf
vim /etc/wireguard/wg0.conf
```

## Start/enable server

```
sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0
```

## Create client configs

- Use mkconfig tool on server to make client configs. It will add them to the running server.
- Distribute the `<name>.conf` and `<name>all.conf` configs to clients.
- Keep keys secret.

# View status

`sudo wg`
