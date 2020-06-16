#!/bin/bash

set -e

#############################################################################################################################
#   Setup Environment
#############################################################################################################################
HOME="/tmp"
BIN="/usr/local/bin"
CONFIG="/etc/consul.d"
PACKAGE="/opt/consul"

#   Install unzip
sudo apt-get install unzip -y

#   Move to Home Directory
cd $${HOME}

#############################################################################################################################
#   Consul
#############################################################################################################################
echo "installing consul version ${CONSUL_VERSION}"

#   Download
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

#   Install
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul $${BIN}/
sudo consul -autocomplete-install
complete -C $${BIN}/consul consul
sudo setcap cap_ipc_lock=+ep $${BIN}/consul
sudo rm consul_${CONSUL_VERSION}_linux_amd64.zip
sudo useradd --system --home $${CONFIG} --shell /bin/false consul
sudo mkdir --parents $${PACKAGE}
sudo chown --recursive consul:consul $${PACKAGE}

cat <<-EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=$${CONFIG}/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=$${BIN}/consul agent -config-dir=$${CONFIG}/
ExecReload=$${BIN}/consul reload
ExecStop=$${BIN}/consul leave
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir --parents $${CONFIG}

cat <<-EOF > $${CONFIG}/consul.hcl
datacenter = "${DATA_CENTER}"
data_dir = "$${PACKAGE}"
client_addr = "0.0.0.0"
ui = true
server = true
bootstrap_expect = 1
EOF

sudo chown --recursive consul:consul $${CONFIG}
sudo chmod 640 $${CONFIG}/consul.hcl

#   Enable the Service
echo "starting consul server"
sudo systemctl enable consul
sudo service consul start

#############################################################################################################################
#   Setup Port Forwarding
#############################################################################################################################
echo "configuring resolved port forwarding and iptables"
sudo mkdir --parents /etc/systemd/resolved.conf.d
cat <<-EOF > /etc/systemd/resolved.conf.d/consul.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF
iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
systemctl restart systemd-resolved

exit 0