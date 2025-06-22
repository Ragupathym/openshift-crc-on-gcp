## Main VM Instance for CRC Container

# This file defines the core infrastructure for the CRC VM.

resource "google_compute_instance" "crc_vm" {
  name         = var.instance_name
  project      = var.gcp_project_id
  zone         = var.gcp_zone
  machine_type = var.instance_machine_type

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network = var.network_name
    access_config {} # Assigns a public IP address.
  }

  advanced_machine_features {
    enable_nested_virtualization = true
  }

  # Inject SSH public key for remote access.
  # The 'ssh_public_key_content' variable is marked as sensitive.
  metadata = {
    ssh-keys = "${var.crc_setup_username}:${var.ssh_public_key_content}"
  }

  # Attaching the service account with required permissions for GCP services.
  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_write"]
  }

  # Render and execute the startup script on instance creation.
  # The startup script will set up CRC and its dependencies.
  metadata_startup_script = data.template_file.crc_startup_script.rendered
}