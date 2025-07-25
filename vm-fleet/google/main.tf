resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "google_compute_instance" "vm" {
  count        = 3
  name         = "vm-${count.index + 1}"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.ssh.public_key_openssh}"
  }

  tags = ["ssh"]
}

resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}
resource "google_compute_instance_group" "vms" {
  name = "vm-group"
  zone = "us-central1-a"
  
  instances = google_compute_instance.vm[*].id
}

resource "google_compute_backend_service" "default" {
  name        = "vm-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = google_compute_instance_group.vms.id
  }

  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_http_health_check" "default" {
  name = "vm-health-check"
  port = 80
}

resource "google_compute_url_map" "default" {
  name            = "vm-lb"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "default" {
  name    = "vm-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "vm-forwarding-rule"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
}

output "loadbalancer_ip" {
  value = google_compute_global_forwarding_rule.default.ip_address
}

output "instance_ips" {
  value = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}

output "ssh_username" {
  value = "ubuntu"
}

output "ssh_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}
