variable "project" {
    type = "string"
    default = "kubernetes-1369"
}

variable "region" {
    type = "string"
    default = "europe-west1"
}

variable "network" {
    type = "map"
    default = {
    name = "kubernetes"
    iprange = "10.240.0.0/24"
    }
}
variable "instance-type" {
    type = "string"
    default = "n1-standard-1"
}

variable "az" {
    type = "list"
    default = ["b", "c", "d"]    
}

variable "disk" {
    default = {
        image = "ubuntu-os-cloud/ubuntu-1604-xenial-v20160627"
    }
}
