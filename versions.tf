## Terraform and Provider Versions

# This file specifies the required Terraform version and provider versions.
# It also configures the remote backend for state management.

terraform {
  required_version = ">= 1.0.0" # Adjust based on your Terraform CLI version

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Pin to a major version to avoid breaking changes
    }
  }

  # Configure Google Cloud Storage (GCS) as the remote backend for Terraform state.
  # This helps secure your state file (including sensitive values) and enables collaboration.
  backend "gcs" {
    bucket = "oc-files" # <<< IMPORTANT: REPLACE WITH YOUR GCS BUCKET NAME
    prefix = "crc-vm-state"               # Optional: Path within the bucket for this project's state
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}