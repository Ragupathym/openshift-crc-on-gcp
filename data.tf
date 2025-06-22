## Data Sources

# This file defines data sources used in the Terraform configuration.

data "template_file" "crc_startup_script" {
  template = file("${path.module}/startup-script.sh")
  vars = {
    USERNAME        = var.crc_setup_username
    CRC_INSTALL_DIR = "/home/${var.crc_setup_username}/${var.crc_install_dir}" # Construct full path here
    CRC_SETUP_LOG   = var.crc_setup_log
  }
}