#!/bin/sh
sudo mkdir -p /var/lib/kubernetes
sudo mv ca.pem kubernetes-key.pem kubernetes.pem /var/lib/kubernetes/

curl -L https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-apiserver --output kube-apiserver
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-controller-manager --output kube-controller-manager
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-scheduler --output kube-scheduler
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl --output kubectl
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/bin/

curl -L https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/token.csv --output token.csv
sudo mv token.csv /var/lib/kubernetes/

curl -L https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/authorization-policy.jsonl --output authorization-policy.jsonl
sudo mv authorization-policy.jsonl /var/lib/kubernetes/

export INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

#GET IP'S OF OTHER ETC NODES - THIS IS CRUFT
ETCD0=`gcloud compute instances list etcd0 --format=yaml | grep "  networkIP:" | cut -c 14-100`
ETCD1=`gcloud compute instances list etcd1 --format=yaml | grep "  networkIP:" | cut -c 14-100`
ETCD2=`gcloud compute instances list etcd2 --format=yaml | grep "  networkIP:" | cut -c 14-100`

#API SETUP
cat > kube-apiserver.service <<"EOF"
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-apiserver \
  --admission-control=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota \
  --advertise-address=INTERNAL_IP \
  --allow-privileged=true \
  --apiserver-count=3 \
  --authorization-mode=ABAC \
  --authorization-policy-file=/var/lib/kubernetes/authorization-policy.jsonl \
  --bind-address=0.0.0.0 \
  --enable-swagger-ui=true \
  --etcd-cafile=/var/lib/kubernetes/ca.pem \
  --insecure-bind-address=0.0.0.0 \
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \
  --etcd-servers=https://ETCD0IP:2379,https://ETCD1IP:2379,https://ETCD2IP:2379 \
  --service-account-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --token-auth-file=/var/lib/kubernetes/token.csv \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/ETCD0IP/${ETCD0}/g" kube-apiserver.service
sed -i "s/ETCD1IP/${ETCD1}/g" kube-apiserver.service
sed -i "s/ETCD2IP/${ETCD2}/g" kube-apiserver.service
sed -i "s/INTERNAL_IP/$INTERNAL_IP/g" kube-apiserver.service
sudo mv kube-apiserver.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver
sudo systemctl start kube-apiserver

#CONTROLLER SETUP
cat > kube-controller-manager.service <<"EOF"
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-controller-manager \
  --allocate-node-cidrs=true \
  --cluster-cidr=10.200.0.0/16 \
  --cluster-name=kubernetes \
  --leader-elect=true \
  --master=http://INTERNAL_IP:8080 \
  --root-ca-file=/var/lib/kubernetes/ca.pem \
  --service-account-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --service-cluster-ip-range=10.32.0.0/24 \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/INTERNAL_IP/$INTERNAL_IP/g" kube-controller-manager.service
sudo mv kube-controller-manager.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable kube-controller-manager
sudo systemctl start kube-controller-manager

#SCHEDULER SETUP
cat > kube-scheduler.service <<"EOF"
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-scheduler \
  --leader-elect=true \
  --master=http://INTERNAL_IP:8080 \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/INTERNAL_IP/$INTERNAL_IP/g" kube-scheduler.service
sudo mv kube-scheduler.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable kube-scheduler
sudo systemctl start kube-scheduler