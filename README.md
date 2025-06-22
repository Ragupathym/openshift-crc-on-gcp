# GCP CRC VM Terraform Module

This Terraform module deploys a Google Cloud Platform (GCP) Virtual Machine (VM) configured to run a CodeReady Containers (CRC) instance. It automates the provisioning of the VM, installation of necessary dependencies, and the setup of CRC.

---

## Features

* **Customizable VM:** Easily configure machine type, boot disk size, and image.
* **Automated Setup:** Uses a startup script to install dependencies, copy CRC binaries, and perform CRC setup.
* **SSH Access:** Configures SSH access using a provided public key.
* **Service Account Integration:** Attaches a service account for secure access to GCP services (e.g., Google Cloud Storage).
* **Nested Virtualization Enabled:** Required for running CRC.

---

## Prerequisites

Before using this module, ensure you have:

* **Terraform CLI:** Installed and configured on your local machine.
* **GCP Project:** An active GCP project with billing enabled.
* **GCP Service Account:** A service account with the `roles/compute.instanceAdmin.v1` and `roles/iam.serviceAccountUser` roles at a minimum, and any additional roles required for your specific service account needs (e.g., `roles/storage.objectViewer` if files are downloaded from GCS).
* **SSH Key Pair:** An SSH key pair (`id_rsa` and `id_rsa.pub`) generated in your `.ssh` directory or a specified path.
* **CRC Binaries and Pull Secret:** Ensure your `gs://openshift-files` bucket contains `crc-linux-amd64.tar.xz` and `pull-secret.txt`.

---

## Usage

1.  **Clone this repository:**
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2.  **Edit `terraform.tfvars` (create if it doesn't exist):**
    Create a `terraform.tfvars` file in the root of the module to provide values for the input variables.

    ```terraform
    gcp_project_id        = "your-gcp-project-id"
    gcp_region            = "us-central1"
    gcp_zone              = "us-central1-f"
    instance_name         = "my-crc-vm"
    instance_machine_type = "n2-standard-8"
    boot_disk_image       = "centos-stream-9"
    boot_disk_size        = 80 # Example: Increased size
    ssh_public_key_path   = "~/.ssh/id_rsa.pub" # Or specify an absolute path
    ssh_username          = "your-gcp-username"
    service_account_email = "your-service-account@your-project-id.iam.gserviceaccount.com"
    ```
    **Note:** Adjust `ssh_public_key_path` and `ssh_username` to match your local setup and desired VM user.

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Review the plan:**
    ```bash
    terraform plan
    ```

5.  **Apply the configuration:**
    ```bash
    terraform apply
    ```

    Confirm with `yes` when prompted.

---

## Outputs

After successful deployment, the following outputs will be available:

* `instance_public_ip`: The public IP address of the deployed CRC VM.
* `instance_name`: The name of the deployed CRC VM.

---

## Clean Up

To destroy the created resources:

```bash
terraform destroy