#!/bin/sh
sudo mkdir -p /etc/etcd/
sudo mv ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
curl -L https://github.com/coreos/etcd/releases/download/v3.0.1/etcd-v3.0.1-linux-amd64.tar.gz --output etcd.tar.gz
tar -xvf etcd.tar.gz
sudo cp etcd-v3.0.1-linux-amd64/etcd* /usr/bin/
sudo mkdir -p /var/lib/etcd

#GET IP'S OF OTHER ETC NODES - THIS IS CRUFT
ETCD0=`gcloud compute instances list etcd0 --format=yaml | grep "  networkIP:" | cut -c 14-100`
ETCD1=`gcloud compute instances list etcd1 --format=yaml | grep "  networkIP:" | cut -c 14-100`
ETCD2=`gcloud compute instances list etcd2 --format=yaml | grep "  networkIP:" | cut -c 14-100`

cat > etcd.service <<"EOF"
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/bin/etcd --name ETCD_NAME \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --initial-advertise-peer-urls https://INTERNAL_IP:2380 \
  --listen-peer-urls https://INTERNAL_IP:2380 \
  --listen-client-urls https://INTERNAL_IP:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://INTERNAL_IP:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster etcd0=https://ETCD0IP:2380,etcd1=https://ETCD1IP:2380,etcd2=https://ETCD2IP:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/ETCD0IP/${ETCD0}/g" etcd.service
sed -i "s/ETCD1IP/${ETCD1}/g" etcd.service
sed -i "s/ETCD2IP/${ETCD2}/g" etcd.service

export INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

export ETCD_NAME=$(hostname -s)

sed -i "s/INTERNAL_IP/$INTERNAL_IP/g" etcd.service
sed -i "s/ETCD_NAME/$ETCD_NAME/g" etcd.service

sudo mv etcd.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
  