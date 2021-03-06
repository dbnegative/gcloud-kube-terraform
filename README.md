# Google Cloud + Kubernetes + Terraform + Ansible
 
Automated provisioning of kubernetes based off https://github.com/kelseyhightower/kubernetes-the-hard-way

## Why?

Why do this when Google Compute already provides this service? Mostly to learn a bit more about GCE, Kubernetes components and bootstrap that would be necassery in other enviro's like AWS. 

## Currently builds the following:
* GCE Network, Firewall rules, Instance pool etc..
* 3 x ETCD nodes in seperate AZ's - g1-small machine
* 3 x Controller/API nodes - g1-small 
* 2 x Worker nodes (due to free account instance limit of 8) n1-standard-1

## Requires the following: 
* Terraform v7rc1 >
* Google Cloud SDK: gcloud, gsutil 
* Functioning kubectl for your OS
* Ansible v2.0 > 
* Fully functioning service account creds
* Unix tools: sed, wget
* cfssl, cfssljson 

## Usage 
* Put google service creds in folder as account.json
* Make sure you are logged into gcloud
* You have an ssh key generated called "google_compute_1" in your ssh folder 
* Make sure that key has been added to your project metadata

###Do the follwing in the root of the folder:
```
All os's:
mkdir creds
cp <YOUR GOOGLE SERVICE ACCOUNT CREDS JSON> creds/account.json
```

Edit terraform/vars.tf and terraform-routes/vars.tf:

```
variable "project" {
    type = "string"
    default = "<YOUR PROJECT ID>"
}
```

###OSX:
```
./setup-osx.sh
```
###Linux:
```
./setup-osx.sh
```

To teardown and cleanup OSX/Linux:
```
./destroy.sh
```

## Debugging

All ansible roles are tagged so they can be run individually.

```
To display status of all running kube and etcd services, run this in the root of the folder:

export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i gcehosts site.yml --private-key ~/.ssh/google_compute_1 --tags debug

```

## ToDo:
* ~~Wrapper script~~ 
* ~~Better SSL cert generation~~
* ~~MD5 hash check on certs to reduce provisioning time.~~
* ~~Better Anisible module seperation i.e move ssl to own role~~
* Remove debug output
* ~~Update linux setup script~~ Not tested yet
* Code Tidy
* ~~Terraform state in GCS~~
* Better exposed variables