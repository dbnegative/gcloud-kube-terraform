resource "google_compute_network" "default" {
  name       = "${var.network["name"]}"
}

resource "google_compute_subnetwork" "default" {
  name          = "default-${var.region}"
  ip_cidr_range = "${var.network["iprange"]}"
  network       = "${google_compute_network.default.self_link}"
  region        = "${var.region}"
}

resource "google_compute_address" "default" {
  name = "${var.network["name"]}"
}

resource "google_compute_firewall" "kube-allow-icmp" {
  name    = "kubernetes-allow-icmp"
  network = "${google_compute_network.default.name}"
  allow {
    protocol = "icmp"  
  }
   source_ranges = ["0.0.0.0/0"] 
}

resource "google_compute_firewall" "kube-allow-internal" {
  name    = "kubernetes-allow-internal"
  network = "${google_compute_network.default.name}"
  allow {
    protocol = "tcp"
    ports = ["0-65535"]  
  }
  
  allow {
      protocol = "udp"
      ports = ["0-65535"]
  }
  
  allow {
      protocol = "icmp"     
  }
  
   source_ranges = ["10.240.0.0/24"] 
}

resource "google_compute_firewall" "kube-allow-rdp" {
  name    = "kubernetes-allow-rdp"
  network = "${google_compute_network.default.name}"
  allow {
    protocol = "tcp"
    ports = ["3389"]  
  }
   source_ranges = ["0.0.0.0/0"] 
}


resource "google_compute_firewall" "kube-allow-ssh" {
  name    = "kubernetes-allow-ssh"
  network = "${google_compute_network.default.name}"
  allow {
    protocol = "tcp"
    ports = ["22"]  
  }
   source_ranges = ["0.0.0.0/0"] 
}

resource "google_compute_firewall" "kube-allow-healthz" {
  name    = "kubernetes-allow-healthz"
  network = "${google_compute_network.default.name}"
  allow {
    protocol = "tcp"
    ports = ["8080"]  
  }
   source_ranges = ["130.211.0.0/22"] 
}

resource "google_compute_firewall" "kube-allow-api-server" {
  name    = "kubernetes-allow-api-server"
  network = "${google_compute_network.default.name}"
  allow {
    protocol = "tcp"
    ports = ["6443"]  
  }
   source_ranges = ["0.0.0.0/0"] 
}