provider "google" {
  credentials = file("schedix-gcp.json")
  project     = var.my_gcp_project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = var.public_key
}

resource "google_compute_instance" "vm_instance" {
  name         = "tflinux"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "fwall" {
  name    = "terraform-network-firewall"
  network = google_compute_network.vpc_network.terraform-network

  allow {
    protocol = "ssh"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["ssh"]
}