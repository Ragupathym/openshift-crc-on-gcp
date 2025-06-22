#!/bin/bash

# Variables injected from Terraform
USERNAME="${USERNAME}"
CRC_INSTALL_DIR="${CRC_INSTALL_DIR}" # This will be the full path, e.g., /home/ragupathy/local/bin
CRC_SETUP_LOG="${CRC_SETUP_LOG}"

mkdir -p /crc/
echo "Starting CRC VM setup script..." | sudo tee -a "$CRC_SETUP_LOG"

# --- Create the dedicated CRC setup user if it doesn't exist ---
# This ensures the user exists for CRC setup commands, regardless of SSH key injection.
if ! id "$USERNAME" &>/dev/null; then
    echo "Creating user '$USERNAME' for CRC setup..." | sudo tee -a "$CRC_SETUP_LOG"
    sudo useradd -m -s /bin/bash "$USERNAME"
    # Optional: Add user to sudoers group if they need sudo without password
    # sudo usermod -aG wheel "$USERNAME" # For CentOS/RHEL/Fedora
    echo "User '$USERNAME' created." | sudo tee -a "$CRC_SETUP_LOG"
else
    echo "User '$USERNAME' already exists. Skipping creation." | sudo tee -a "$CRC_SETUP_LOG"
fi
# --- End user creation ---


echo "Installing google-cloud-sdk..." | sudo tee -a "$CRC_SETUP_LOG"
if sudo dnf install -y google-cloud-sdk; then
    echo "google-cloud-sdk installation completed successfully." | sudo tee -a "$CRC_SETUP_LOG"

    # Copy files from Google Cloud Storage after successful installation
    echo "Copying CRC binaries and pull secret from GCS..." | sudo tee -a "$CRC_SETUP_LOG"
    gsutil cp gs://oc-files/crc-linux-amd64.tar.xz /crc/crc-linux-amd64.tar.xz
    gsutil cp gs://oc-files/pull-secret.txt /crc/pull-secret.txt
    echo "Files copied successfully." | sudo tee -a "$CRC_SETUP_LOG"
else
    echo "google-cloud-sdk installation failed. Exiting setup." | sudo tee -a "$CRC_SETUP_LOG"
    exit 1
fi

# Install dependencies for CRC and desktop environment
echo "Installing dependencies..." | sudo tee -a "$CRC_SETUP_LOG"
sudo dnf install -y NetworkManager libvirt libvirt-daemon libvirt-daemon-kvm libvirt-client
sudo systemctl enable --now NetworkManager libvirtd
sudo dnf install -y qemu-kvm qemu-img epel-release
sudo dnf --enablerepo=epel group install -y "Xfce" "base-x"
sudo dnf install -y xrdp
sudo systemctl enable --now xrdp
sudo dnf install -y firefox
echo "Dependencies installed." | sudo tee -a "$CRC_SETUP_LOG"

# Open firewall for RDP (This configures the VM's internal firewall.
# Ensure your GCP network firewall also allows 3389 from your source IPs.)
echo "Configuring firewall for RDP..." | sudo tee -a "$CRC_SETUP_LOG"
sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --reload
echo "Firewall rule added." | sudo tee -a "$CRC_SETUP_LOG"

echo "Current user running script: $(whoami)" | sudo tee -a "$CRC_SETUP_LOG"

# Set up CRC for the dedicated user
echo "Setting up CRC environment for user ${USERNAME} in directory ${CRC_INSTALL_DIR}..." | sudo tee -a "$CRC_SETUP_LOG"
sudo -u "$USERNAME" -i -- bash -c "mkdir -p $CRC_INSTALL_DIR"
cd /crc/ || { echo "Error: /crc/ directory not found or accessible." | sudo tee -a "$CRC_SETUP_LOG"; exit 1; }

echo "Extracting CRC archive..." | sudo tee -a "$CRC_SETUP_LOG"
tar xvf crc-linux-amd64.tar.xz

CRC_DIR=$(ls -d crc-linux-*-amd64 2>/dev/null) # Find the extracted CRC directory
if [ -z "$CRC_DIR" ]; then
    echo "Error: CRC extracted directory not found." | sudo tee -a "$CRC_SETUP_LOG"
    exit 1
fi

echo "Moving CRC binary to $CRC_INSTALL_DIR..." | sudo tee -a "$CRC_SETUP_LOG"
mv "$CRC_DIR/crc" "$CRC_INSTALL_DIR/"
sudo chown -R "$USERNAME:$USERNAME" "$CRC_INSTALL_DIR/crc"

# Add CRC to the user's PATH for interactive sessions
export PATH="$CRC_INSTALL_DIR:$PATH"
echo "Current PATH: $PATH" | sudo tee -a "$CRC_SETUP_LOG"
echo "export PATH=$CRC_INSTALL_DIR:\$PATH" | sudo tee -a "/home/$USERNAME/.bashrc"


echo "Running crc config set consent-telemetry no as user $USERNAME..." | sudo tee -a "$CRC_SETUP_LOG"
sudo -u "$USERNAME" -i -- bash -c 'crc config set consent-telemetry no'

echo "Running crc setup as user $USERNAME..." | sudo tee -a "$CRC_SETUP_LOG"
sudo -u "$USERNAME" -i -- bash -c 'crc setup'

echo "crc setup done." | sudo tee -a "$CRC_SETUP_LOG"

# Uncomment the following lines if you want CRC to start automatically after setup
# echo "Starting crc container as user $USERNAME..." | sudo tee -a "$CRC_SETUP_LOG"
# sudo -u "$USERNAME" -i -- bash -c 'crc start -p /crc/pull-secret.txt'
# echo "crc container started." | sudo tee -a "$CRC_SETUP_LOG"