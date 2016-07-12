#------------------ ETCD -------------------------------------------
resource "google_compute_instance" "etcd-cluster" {
  name         = "etcd${count.index}"
  machine_type = "${var.instance-type}"
  zone         = "${var.region}-${element(var.az, count.index)}"
  disk {
      image = "${var.disk["image"]}"
      size = 200
  }
  count = 3

  network_interface {
      #network = "${google_compute_network.default.name}"
      subnetwork = "${google_compute_subnetwork.default.name}"
       access_config {
    }
  }
  
  can_ip_forward = true
  
   service_account {
    scopes = ["compute-ro", "storage-ro"]
  }
  
  provisioner "file" {
        source = "scripts/etcd_configure.sh"
        destination = "~/etcd_configure.sh"
        
        connection {
        type = "ssh"
        user = "shortjay"
        private_key = "~/.ssh/google_compute_1"
      }
    }
  
  provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "shortjay"
        private_key = "~/.ssh/google_compute_1"
    }
      
      inline = [
          "gsutil cp gs://kube-ssl-certs/kubernetes.pem  ~/.",
          "gsutil cp gs://kube-ssl-certs/kubernetes-key.pem  ~/.",
          "gsutil cp gs://kube-ssl-certs/ca.pem  ~/.", 
          "chmod 755 ~/etcd_configure.sh",
          "~/etcd_configure.sh"
      ]
  }
  
}

#---------------- CONTROLLER ----------------------------------------

resource "google_compute_instance" "controller-cluster" {
  name         = "controller${count.index}"
  machine_type = "${var.instance-type}"
  zone         = "${var.region}-${element(var.az, count.index)}"
  disk {
      image = "${var.disk["image"]}"
      size = 200
  }
  count = 3

  network_interface {
      #network = "${google_compute_network.default.name}"
      subnetwork = "${google_compute_subnetwork.default.name}"
       access_config {
    }
  }
  
  can_ip_forward = true
  
  service_account {
    scopes = ["compute-ro", "storage-ro"]
  }
  
  provisioner "file" {
        source = "scripts/kubectrl_configure.sh"
        destination = "~/kubectrl_configure.sh"
        
        connection {
        type = "ssh"
        user = "shortjay"
        private_key = "~/.ssh/google_compute_1"
      }
    }

  provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "shortjay"
        private_key = "~/.ssh/google_compute_1"
    }
      
      inline = [
          "gsutil cp gs://kube-ssl-certs/kubernetes.pem  ~/.",
          "gsutil cp gs://kube-ssl-certs/kubernetes-key.pem  ~/.",
          "gsutil cp gs://kube-ssl-certs/ca.pem  ~/.",
          "chmod 755 ~/kubectrl_configure.sh",
          "~/kubectrl_configure.sh"
      ]
  }
}
#----------------- WORKER ------------------------------------
#
resource "google_compute_instance" "worker-cluster" {
  name         = "worker${count.index}"
  machine_type = "${var.instance-type}"
  zone         = "${var.region}-${element(var.az, count.index)}"
  disk {
      image = "${var.disk["image"]}"
      size = 200
  }
  count = 2

  network_interface {
      #network = "${google_compute_network.default.name}"
       subnetwork = "${google_compute_subnetwork.default.name}"
       access_config {
    }
  }
  
  can_ip_forward = true
  
  service_account {
    scopes = ["compute-ro", "storage-ro"]
  }
  
 provisioner "file" {
        source = "scripts/kubeworker_configure.sh"
        destination = "~/kubeworker_configure.sh"
        
        connection {
        type = "ssh"
        user = "shortjay"
        private_key = "~/.ssh/google_compute_1"
      }
    }

  provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "shortjay"
        private_key = "~/.ssh/google_compute_1"
    }
      
      inline = [
          "gsutil cp gs://kube-ssl-certs/kubernetes.pem  ~/.",
          "gsutil cp gs://kube-ssl-certs/kubernetes-key.pem  ~/.",
          "gsutil cp gs://kube-ssl-certs/ca.pem  ~/.",
          "chmod 755 ~/kubeworker_configure.sh",
          "~/kubeworker_configure.sh"
      ]
  }
}