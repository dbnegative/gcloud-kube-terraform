 data "terraform_remote_state" "default" {
    backend = "gcs"
    config {
        bucket = "terraform-state-kube"
        path = "main/terraform.tfstate"
        project = "kubernetes"
    }
}
