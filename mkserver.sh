#!/bin/bash

function usage () {
  echo "${0} <interface> <ip> <port>"
}

interface=$1
serveraddr=$2
port=$3

if test -z "${interface}" || test -z "${serveraddr}" || test -z "${port}" ; then
  usage
  exit 1
fi

omask=$(umask)
umask 077
wg genkey > private 

cat private | wg pubkey > public

export serverprivatekey=$(cat private)
export serveraddr=$serveraddr
export port=$port

envsubst < "templates/server.conf.template" > "${interface}.conf"
umask $omask