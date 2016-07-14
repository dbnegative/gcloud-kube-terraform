#!/bin/sh
#Makes assumptions for many things such as terraform, ansible and cfssl being 
#installed and located in PATH etc.. tread lightly

#Assumes ssl folder exists and contains ca config files
cd ssl

#Generate cert assume cfssl is installed
if [ ! -f ca.pem ]
then
	echo "Generating CA\n"
	cfssl gencert -initca ca-csr.json | cfssljson -bare ca
else
	echo "CA exists..skipping\n"
fi

cd ..

#Check if credentials exist then run Terraform
if [ -f account.json ]
then
	echo "Running Terraform Plan\n"
	terraform plan > plannedchanges.log

	echo "Running Terraform Apply\n"
  terraform apply
else
	echo "Google service credentials missing, cannot find account.json"
fi

#Create list of servers for ansible and ssl cert gen
ETCD0_IP=`gcloud compute instances list etcd0 --format=yaml | grep "  networkIP:" | cut -c 14-100`
ETCD1_IP=`gcloud compute instances list etcd1 --format=yaml | grep "  networkIP:" | cut -c 14-100`
ETCD2_IP=`gcloud compute instances list etcd2 --format=yaml | grep "  networkIP:" | cut -c 14-100`
CTRL0_IP=`gcloud compute instances list controller0 --format=yaml | grep "  networkIP:" | cut -c 14-100`
CTRL1_IP=`gcloud compute instances list controller1 --format=yaml | grep "  networkIP:" | cut -c 14-100`
CTRL2_IP=`gcloud compute instances list controller2 --format=yaml | grep "  networkIP:" | cut -c 14-100`
WORKER0_IP=`gcloud compute instances list worker0 --format=yaml | grep "  networkIP:" | cut -c 14-100`
WORKER1_IP=`gcloud compute instances list worker1 --format=yaml | grep "  networkIP:" | cut -c 14-100`
KUBERNETES_PUBLIC_IP_ADDRESS=$(gcloud compute addresses describe kubernetes \
  --format 'value(address)')

# cd to working dir
cd ssl 

# copy over template
cp kubernetes-csr.json.tmpl kubernetes-csr.json

#Add ip's' to the kubernetes csr config file assumes terraform was successful
sed -i "s/ETCD0IP/${ETCD0_IP}/g" kubernetes-csr.json
sed -i "s/ETCD1IP/${ETCD1_IP}/g" kubernetes-csr.json 
sed -i "s/ETCD2IP/${ETCD2_IP}/g" kubernetes-csr.json
sed -i "s/CTRL0IP/${CTRL0_IP}/g" kubernetes-csr.json
sed -i "s/CTRL1IP/${CTRL1_IP}/g" kubernetes-csr.json
sed -i "s/CTRL2IP/${CTRL2_IP}/g" kubernetes-csr.json
sed -i "s/WORKER0IP/${WORKER0_IP}/g" kubernetes-csr.json
sed -i "s/WORKER1IP/${WORKER1_IP}/g" kubernetes-csr.json
sed -i "s/KUBERNETES_PUBLIC_IP/${KUBERNETES_PUBLIC_IP_ADDRESS}/g" kubernetes-csr.json

#Generate kube cert
#TODO run only when md5 hash changes
echo "Generatining kubernetes cert and key"
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

#Change to ansible workdir
cd ../ansible

#Copy template file
cp gcehosts.tmpl gcehosts

#Copy over ssl certs to be provisioned
cp ../ssl/kubernetes.pem roles/common/files/
cp ../ssl/kubernetes-key.pem roles/common/files/
cp ../ssl/ca.pem roles/common/files/

#Get Nat IP's of all hosts
echo "Collecting node IP's from gcloud'"
ETCD0_NAT_IP=`gcloud compute instances list etcd0 --format=yaml | grep "  natIP:" | cut -c 12-100`
ETCD1_NAT_IP=`gcloud compute instances list etcd1 --format=yaml | grep "  natIP:" | cut -c 12-100`
ETCD2_NAT_IP=`gcloud compute instances list etcd2 --format=yaml | grep "  natIP:" | cut -c 12-100`
CTRL0_NAT_IP=`gcloud compute instances list controller0 --format=yaml | grep "  natIP:" | cut -c 12-100`
CTRL1_NAT_IP=`gcloud compute instances list controller1 --format=yaml | grep "  natIP:" | cut -c 12-100`
CTRL2_NAT_IP=`gcloud compute instances list controller2 --format=yaml | grep "  natIP:" | cut -c 12-100`
WORKER0_NAT_IP=`gcloud compute instances list worker0 --format=yaml | grep "  natIP:" | cut -c 12-100`
WORKER1_NAT_IP=`gcloud compute instances list worker1 --format=yaml | grep "  natIP:" | cut -c 12-100`

#Add ip's' to the ansible inventory file assumes terraform was successful
sed -i "s/ETCD0IP/${ETCD0_NAT_IP}/g" gcehosts
sed -i "s/ETCD1IP/${ETCD1_NAT_IP}/g" gcehosts 
sed -i "s/ETCD2IP/${ETCD2_NAT_IP}/g" gcehosts
sed -i "s/CTRL0IP/${CTRL0_NAT_IP}/g" gcehosts
sed -i "s/CTRL1IP/${CTRL1_NAT_IP}/g" gcehosts
sed -i "s/CTRL2IP/${CTRL2_NAT_IP}/g" gcehosts
sed -i "s/WORKER0IP/${WORKER0_NAT_IP}/g" gcehosts
sed -i "s/WORKER1IP/${WORKER1_NAT_IP}/g" gcehosts

#Export IP's' to vars file
echo "Exporting IP's to Ansible vars'"
echo "
etcd:
  etcd0: $ETCD0_IP
  etcd1: $ETCD1_IP
  etcd2: $ETCD2_IP

ctrl:
  ctrl0: $CTRL0_IP
  ctrl1: $CTRL1_IP
  ctrl2: $CTRL2_IP

worker:
  worker0: $WORKER0_IP
  worker1: $WORKER1_IP

ansible_connection: ssh 
ansible_ssh_user: shortjay
" > group_vars/all

echo "Sleeping 10s, waiting for nodes to be ready"
sleep 10

#configure nodes
echo "Starting Ansible"
export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i gcehosts site.yml --private-key ~/.ssh/google_compute_1

#clean up
rm group_vars/all