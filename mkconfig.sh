#!/bin/bash

function usage () {
  echo "${0} <wginterface> <host> <name> <ip> <port>"
}

function create_client_config () {
  allowed_ips="${2}"
  config="${3}"
  echo "Creating client config ${client_config_file} with allowed ips: ${allowed_ips}"
  export clientip=${clientip}
  export private=${private}
  export serverpubkey=${server_public}
  export host=${host}
  export allowed_ips=${allowed_ips}
  envsubst < 'templates/client.conf.template' > "${name}/${config}"
}

# set variables for the script
wginterface="${1}"
host="${2}"
name="${3}"
clientip="${4}"
port="${5}"

client_config_file="${name}.conf"
client_config_file_all="${name}all.conf"
server_config_file="server.conf"
server_public=$(cat public)

# ensure cli arguments exist
if test -z "${name}" || test -z "${host}" || test -z "${clientip}" || test -z "${wginterface}" || test -z "${port}" ; then
  usage
  exit 1
fi

mkdir "${name}"

echo "Creating keys"

# set mask, save old mask
o_umask=$(umask)
echo "old umask is ${o_umask}"
umask 077

# create client keys and generate config
wg genkey | tee ${name}/private | wg pubkey > ${name}/public
private=$(<${name}/private)
public=$(<${name}/public)

server_addr=$(cat wg0.conf | grep "Address=" | sed s/Address=//g | sed 's![0-9]*/[0-9]*!0/24!g')

create_client_config "${name}" "${server_addr}" "${serveraddr}" "${client_config_file}"
create_client_config "${name}" "${server_addr}" "${serveraddr}" "${client_config_file_all}"

# reset old mask
umask "${o_umask}"

echo "Creating server config ${server_config_file}"
cat > "${server_config_file}" <<EOF
[Peer]
PublicKey = ${public}
AllowedIPs = ${clientip}/32
EOF

# add new confg file
echo "Adding server config to interface ${wginterface}"
wg addconf "${wginterface}" "${server_config_file}"
