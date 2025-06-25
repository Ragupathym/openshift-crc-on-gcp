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

* **Redhat developer account:** From where we get the CRC installation package and pull secret `crc-linux-amd64.tar.xz` and `pull-secret.txt`.
* **Terraform CLI:** Installed and configured on your local machine.
* **GCP Project:** An active GCP project with billing enabled.
* **GCP Project:** Create a GCP bucket and push the installation files into it.
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
    crc_setup_username          = "your-gcp-username" # The user the startup script will create for CRC setup
    service_account_email = "your-service-account@your-project-id.iam.gserviceaccount.com"
    ssh_public_key_content = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3... your_user"
    ```
    **Note:** Adjust `ssh_public_key_content` and `crc_setup_username` to match your local setup and desired VM user.

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
