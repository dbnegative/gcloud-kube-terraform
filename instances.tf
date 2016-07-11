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
}

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
}

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
}