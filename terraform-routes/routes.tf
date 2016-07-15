resource "google_compute_route" "kubernetes-route-10-200-0-0-24" {
  name        = "kubernetes-route-10-200-0-0-24"
  dest_range  = "10.200.0.0/24"
  network     = "kubernetes"
  next_hop_ip = "10.240.0.7"
  priority = 1000
}

resource "google_compute_route" "kubernetes-route-10-200-1-0-24" {
  name        = "kubernetes-route-10-200-1-0-24"
  dest_range  = "10.200.1.0/24"
  network     = "kubernetes"
  next_hop_ip = "10.240.0.5"
  priority = 1000
}
