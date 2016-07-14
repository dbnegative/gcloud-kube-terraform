resource "google_compute_http_health_check" "kube_apiserver_check" {
  name         = "kube-apiserver-check"
  description = "Kubernetes API Server Health Check"
  request_path = "/healthz"
  port = 8080
}

resource "google_compute_target_pool" "kubernetes_pool" {
  name = "kubernetes-pool"

  instances = [
    "${var.region}-b/controller0",
    "${var.region}-c/controller1",
    "${var.region}-d/controller2",
  ]

  health_checks = [
    "${google_compute_http_health_check.kube_apiserver_check.name}",
  ]
}

resource "google_compute_forwarding_rule" "kubernetes_rule" {
  name       = "kubernetes-rule"
  target     = "${google_compute_target_pool.kubernetes_pool.self_link}"
  port_range = "6443"
  ip_address = "${google_compute_address.default.address}"
}