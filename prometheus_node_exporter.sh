#!/bin/bash 
echo " this script on the remote server to be monitored"
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
wait 
tar xvzf node_exporter-*.tar.gz
mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/bin/local
rm -rf node_exporter-1.7.0.linux-amd64*
useradd -rs /bin/false node_exporter
touch /etc/systemd/system/node_exporter.service 

cat >> /etc/systemd/system/node_exporter.service << EOF 
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
restorecon -Rv /usr/local/bin/* /etc/systemd/system/* &> /dev/null 
systemctl enable --now node_exporter.service 
firewall-cmd --add-port=9100/tcp --permanent && firewall-cmd --reload 
