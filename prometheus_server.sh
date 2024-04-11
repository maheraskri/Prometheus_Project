#!/bin/bash 

wget https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz
wait 
tar xvzf prometheus-2.51.1.linux-amd64.tar.gz
mkdir /etc/prometheus  /var/lib/prometheus 

cd prometheus-2.51.1.linux-amd64/ ; mv prometheus promtool /usr/local/bin ; mv prometheus.yml console_libraries consoles /etc/prometheus/

cd ~ ; rm -rf prometheus*
cat >> /etc/systemd/system/prometheus.service << SIG
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle \
    --log.level=info

[Install]
WantedBy=multi-user.target
SIG
useradd -rs /bin/false prometheus ; chown -R prometheus:prometheus /etc/prometheus/ /var/lib/prometheus/
restorecon -Rv /etc/prometheus/* /etc/systemd/system/prometheus.service /usr/local/bin/* /var/lib/prometheus/* &>/dev/null
systemctl enable --now prometheus.service 
firewall-cmd --add-port=9090/tcp --permanent && firewall-cmd --reload 
echo " open http://localhost:9090 in your browser and see if it works"
echo " next add the epel repo and install the grafana server"
