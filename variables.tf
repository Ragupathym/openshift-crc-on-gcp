## Input Variables

# This file defines all the input variables for the CRC VM module.

variable "gcp_project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for the resources."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "The GCP zone for the VM instance."
  type        = string
  default     = "us-central1-f"
}

variable "instance_name" {
  description = "The name of the GCP VM instance."
  type        = string
  default     = "oc-crc-vm"
}

variable "instance_machine_type" {
  description = "The machine type for the VM instance (e.g., n2-standard-8)."
  type        = string
  default     = "n2-standard-8"
}

variable "boot_disk_image" {
  description = "The boot disk image for the VM instance."
  type        = string
  default     = "centos-stream-9"
}

variable "boot_disk_size" {
  description = "The size of the boot disk in GB."
  type        = number
  default     = 60
}

variable "network_name" {
  description = "The name of the GCP network to attach the VM to."
  type        = string
  default     = "default"
}

variable "ssh_public_key_content" {
  description = "The content of the SSH public key (e.g., from ~/.ssh/id_rsa.pub). This value should be kept secret and is marked as sensitive."
  type        = string
  sensitive   = true # Important: Redacts the value from Terraform CLI output
}

variable "service_account_email" {
  description = "The email of the service account to attach to the VM."
  type        = string
  sensitive   = true
}

variable "crc_setup_username" {
  description = "The username under which CRC will be set up and run on the VM."
  type        = string
}

variable "crc_install_dir" {
  description = "The directory where CRC will be installed on the VM relative to the CRC setup user's home."
  type        = string
  default     = "local/bin" # Relative path within /home/<crc_setup_username>/
}

variable "crc_setup_log" {
  description = "The log file path for CRC setup on the VM."
  type        = string
  default     = "/crc/setup.log"
}

variable "crc_bucket_name" {
  description = "The bucket on which openshift crc files are loaded."
  type        = string
  default     = "oc-files"
}