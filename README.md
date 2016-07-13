# Google Cloud + Kubernetes + Terraform 
 
Automated provisioning of kubernetes based off https://github.com/kelseyhightower/kubernetes-the-hard-way

Currently builds the following:
* GCE Network, Firewall rules, Instance pool etc..
* 3 x ETCD nodes in seperate AZ's
* 3 x Controller/API nodes 
* 2 x Worker nodes (due to free account instance limit of 8)

Requires the following: 
* Terraform 7rc1 
* Google Cloud SDK
* Fully functioning service account creds

ToDo:
* ~~Wrapper script~~ - setup.sh now runs and provisons with terraform/ansible
* ~~Better SSL cert generation~~ - setup.sh now creates and syncs certs
* MD5 hash check on certs to reduce provisioning time.
* Terraform state in GCS
* CircleCi intergration
* Terraform modules
* Better exposed variables

Only tested on OSX
