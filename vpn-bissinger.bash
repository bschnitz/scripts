#!/usr/bin/bash

AUTH_LABEL='julian.horstmann@bissinger.de'
AUTH_APP_PASS_PATH=security/two-factor/cotp
VPN_USER_PASS_PATH=work/bissinger/vpn/user
VPN_PASSWORD_PREFIX_PASS_PATH=work/bissinger/vpn/pass-prefix
VPN_USER='julian.horstmann@bissinger.de'
VPN_PASS_PREFIX=$(pass $VPN_PASSWORD_PREFIX_PASS_PATH)
CONFIG_FILE=/home/ben/data/notes/work/bissinger-client-config2.ovpn

#echo -n "Aegis Authenticator Code: "
#read AUTH_CODE

AUTH_CODE=$(pass $AUTH_APP_PASS_PATH | cotp --password-stdin extract -l "$AUTH_LABEL")
VPN_PASS="$VPN_PASS_PREFIX$AUTH_CODE"

mkfifo fifo
#echo "$VPN_USER\n$VPN_PASS"
echo -e "$VPN_USER\n$VPN_PASS" > fifo &
sudo openvpn --config "$CONFIG_FILE" --auth-user-pass fifo
rm fifo
