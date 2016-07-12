#!/bin/sh
sudo mkdir -p /var/lib/kubernetes
sudo mv ca.pem kubernetes-key.pem kubernetes.pem /var/lib/kubernetes/

CTRL0=`gcloud compute instances list controller0 --format=yaml | grep "  networkIP:" | cut -c 14-100`
CTRL1=`gcloud compute instances list controller1 --format=yaml | grep "  networkIP:" | cut -c 14-100`
CTRL2=`gcloud compute instances list controller2 --format=yaml | grep "  networkIP:" | cut -c 14-100`

#DOCKER CONFIGURE
curl -L https://get.docker.com/builds/Linux/x86_64/docker-1.11.2.tgz --output docker-1.11.2.tgz
tar -xvf docker-1.11.2.tgz
sudo cp docker/docker* /usr/bin/

cat > docker.service <<"EOF"
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
ExecStart=/usr/bin/docker daemon \
  --iptables=false \
  --ip-masq=false \
  --host=unix:///var/run/docker.sock \
  --log-level=error \
  --storage-driver=overlay
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv docker.service /etc/systemd/system/ 

sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker

#KUBELET
sudo mkdir -p /opt/cni
curl -L https://storage.googleapis.com/kubernetes-release/network-plugins/cni-c864f0e1ea73719b8f4582402b0847064f9883b0.tar.gz --output cni.tar.gz
sudo tar -xvf cni.tar.gz -C /opt/cni

curl -L https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl --output kubectl
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-proxy --output kube-proxy
curl -L https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubelet --output kubelet

chmod +x kubectl kube-proxy kubelet

sudo mv kubectl kube-proxy kubelet /usr/bin/

sudo mkdir -p /var/lib/kubelet/

cat > kubeconfig <<"EOF" 
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /var/lib/kubernetes/ca.pem
    server: https://CTRL0:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet
current-context: kubelet
users:
- name: kubelet
  user:
    token: chAng3m3
EOF
    
sed -i "s/CTRL0/${CTRL0}/g" kubeconfig
sudo mv kubeconfig /var/lib/kubelet/

#SYSTEMD
cat > kubelet.service <<"EOF"
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \
  --allow-privileged=true \
  --api-servers=https://CTRL0:6443,https://CTRL1:6443,https://CTRL2:6443 \
  --cloud-provider= \
  --cluster-dns=10.32.0.10 \
  --cluster-domain=cluster.local \
  --configure-cbr0=true \
  --container-runtime=docker \
  --docker=unix:///var/run/docker.sock \
  --network-plugin=kubenet \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --reconcile-cidr=true \
  --serialize-image-pulls=false \
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --v=2

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/CTRL0/${CTRL0}/g" kubelet.service
sed -i "s/CTRL1/${CTRL1}/g" kubelet.service
sed -i "s/CTRL2/${CTRL2}/g" kubelet.service

sudo mv kubelet.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet

cat > kube-proxy.service <<"EOF"
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-proxy \
  --master=https://CTRL0:6443 \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --proxy-mode=iptables \
  --v=2

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/CTRL0/${CTRL0}/g" kube-proxy.service

sudo mv kube-proxy.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable kube-proxy
sudo systemctl start kube-proxy