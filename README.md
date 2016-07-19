# Google Cloud + Kubernetes + Terraform + Ansible
 
Automated provisioning of kubernetes based off https://github.com/kelseyhightower/kubernetes-the-hard-way

## Currently builds the following:
* GCE Network, Firewall rules, Instance pool etc..
* 3 x ETCD nodes in seperate AZ's
* 3 x Controller/API nodes 
* 2 x Worker nodes (due to free account instance limit of 8)

## Requires the following: 
* Terraform 7rc1 
* Google Cloud SDK
* Ansible
* Fully functioning service account creds

## Usage 
* Put google service creds in folder as account.json
* Make sure you are logged into gcloud
* You have an ssh key generated called "google_compute_1" in your ssh folder 
* Make sure that key has been added to your project metadata

Do the follwing in the root of the folder
```
all:
mkdir creds
cp <YOUR GOOGLE SERVICE ACCOUNT CREDS JSON> creds/account.json

osx:
./setup-osx.sh

linux:
./setup-osx.sh
```

## ToDo:
* ~~Wrapper script~~ 
* ~~Better SSL cert generation~~
* ~~MD5 hash check on certs to reduce provisioning time.~~
* Better Anisible module seperation i.e move ssl to own role
* Remove debug output
* Code Tidy
* Terraform state in GCS
* CircleCi intergration
* Terraform modules
* Better exposed variables

Only tested on OSX
