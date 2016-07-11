variable "project" {
    type = "string"
    default = "kubernetes-1369"
}

variable "region" {
    type = "string"
    default = "europe-west1"
}

variable "network" {
    default = {
    name = "kubernetes"
    iprange = "10.240.0.0/24"
    }
}