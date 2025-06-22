## Outputs

# This file defines the output values from the Terraform configuration.

output "instance_public_ip" {
  value       = google_compute_instance.crc_vm.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the GCP VM instance."
}

output "instance_name" {
  value       = google_compute_instance.crc_vm.name
  description = "The name of the GCP VM instance."
}

output "ssh_connection_command" {
  value = "ssh ${var.crc_setup_username}@${google_compute_instance.crc_vm.network_interface[0].access_config[0].nat_ip}"
  description = "SSH command to connect to the instance using the provided public key. Ensure your private key is accessible."
}