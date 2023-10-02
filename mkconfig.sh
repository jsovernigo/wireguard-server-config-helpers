#!/usr/bin/bash -e

set -x

function usage () {
  echo "${0} <wginterface> <name> <ip>"
}

function create_client_config () {
  allowed_ips="${2}"
  echo "Creating client config ${client_config_file} with allowed ips: ${allowed_ips}"
  envsubst < 'templates/client.conf.template' > "${client_config_file}"
}

# set variables for the script
wginterface="${1}"
name="${2}"
ip="${3}"

client_config_file="${name}.conf"
server_config_file="server.conf"
server_public=$(cat publickey)

# ensure cli arguments exist
if [[ -z "${name}" ]] || [[ -z "${ip}" ]] || [[-z "${wginterface}"]]; then
  usage
  exit 1
fi

# move to client directory.
mkdir "${name}"
pushd "${name}"

echo "Creating keys"

# set mask, save old mask
o_umask=$(umask)
echo "old umask is ${o_umask}"
umask 077

# create client keys and generate config
wg genkey | tee private | wg pubkey > public
private=$(<private)
public=$(<public)

create_client_config "${name}" "${serveraddr}"

# reset old mask
umask "${o_umask}"

echo "Creating server config ${server_config_file}"
cat > "${server_config_file}" <<EOF
[Peer]
PublicKey = ${public}
AllowedIPs = ${ip}/32
EOF

# add new confg file
echo "Adding server config to interface ${wginterface}"
sudo wg addconf "${wginterface}" "${server_config_file}"

popd
