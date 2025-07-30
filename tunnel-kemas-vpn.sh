#!/usr/bin/sh

sudo systemctl start redsocks2

# Nur das erstellen, was wir brauchen
sudo iptables -t nat -N REDSOCKS

# NUR localhost ausschließen (damit redsocks sich nicht selbst anspricht)
sudo iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN

# Spezifisch nur das VPN-Netzwerk routen (Adressbereiche können variieren)
sudo iptables -t nat -A REDSOCKS -p tcp -d 192.168.139.0/24 -j DNAT --to-destination 127.0.0.1:12345
sudo iptables -t nat -A REDSOCKS -p tcp -d 192.168.2.0/24 -j DNAT --to-destination 127.0.0.1:12345
sudo iptables -t nat -A REDSOCKS -p tcp -d 192.168.248.0/24 -j DNAT --to-destination 127.0.0.1:12345

# Aktivieren
sudo iptables -t nat -A OUTPUT -p tcp -j REDSOCKS

ssh -D 7777 'kemas\bschnitzler-adm'@192.168.8.109
