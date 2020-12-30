#!/usr/bin/bash -e

function usage {
  echo "${0} <name> <ip>"
}

function create_client_config {
  client_config_file="${1}.conf"
  allowed_ips="${2}"
  echo "Creating client config ${client_config_file} with allowed ips: ${allowed_ips}"
  # TODO make server public key configurable as command line arg
  cat > "${client_config_file}" <<EOF
[Interface]
Address = ${ip}/32
PrivateKey = ${private}
DNS = 1.1.1.1

[Peer]
PublicKey = GwWj+BkDxhTmCwXQ0diW2yMpoet2xMzH9RuEegp/QGA=
Endpoint = orion.hugo-klepsch.tech:51820
AllowedIPs = ${allowed_ips}
EOF
}

name="${1}"
ip="${2}"
interface="wg0"  # TODO make configurable

if [[ -z "${name}" ]]; then
  usage
  exit 1
fi
if [[ -z "${ip}" ]]; then
  usage
  exit 1
fi

mkdir "${name}"
pushd "${name}"

echo "Creating keys"
o_umask=$(umask)
echo "old umask is ${o_umask}"
umask 077
wg genkey | tee private | wg pubkey > public

private=$(<private)
public=$(<public)

create_client_config "${name}all" "0.0.0.0/0, ::/0"
create_client_config "${name}" "10.8.0.1/24"

umask "${o_umask}"

server_config_file="server.conf"
echo "Creating server config ${server_config_file}"
cat > "${server_config_file}" <<EOF
[Peer]
PublicKey = ${public}
AllowedIPs = ${ip}/32
EOF

echo "Adding server config to interface ${interface}"
sudo wg addconf "${interface}" "${server_config_file}"

popd
