# Stage 1: Download oc
# Start as root for dnf install, then switch to a safe user if UBI defaults to non-root later
FROM registry.access.redhat.com/ubi8/python-39:latest as downloader

# Switch to root user to allow dnf install
USER root
RUN dnf install -y curl tar gzip && \
    dnf clean all

# Ensure the oc client version matches your CRC version for best compatibility
ENV OC_VERSION="4.6"
RUN curl -LO "https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OC_VERSION}/linux/oc.tar.gz" && \
    tar -xzf oc.tar.gz -C /usr/local/bin && \
    rm oc.tar.gz

# --- Multi-stage build ends for 'downloader' stage ---

# Stage 2: App container
# Start from the base image again. This image might also default to non-root.
FROM registry.access.redhat.com/ubi8/python-39:latest

# Set environment variables for non-interactive commands
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container
WORKDIR /app

# Switch to root user to allow copying oc to /usr/local/bin
USER root
# Copy the 'oc' binary from the 'downloader' stage
COPY --from=downloader /usr/local/bin/oc /usr/local/bin/oc
# Ensure it's executable
RUN chmod +x /usr/local/bin/oc

# Switch back to a non-root user if the base image provides one (UBI does)
# This is generally 'default' or a specific UID like 1001 for OpenShift compatibility
# The 'ubi8/python-39' image typically uses '1001' or 'default' user.
# Check the image documentation or `podman inspect registry.access.redhat.com/ubi8/python-39:latest`
# If in doubt, USER 1001 or USER default is common.
# For simplicity, we'll ensure dnf runs as root and then rely on OpenShift's SCCs if not explicitly set.
# If you explicitly want to run as non-root within the container for the app, add:
# USER 1001 # Or whatever non-root user the UBI image defaults to for running apps

# Copy application files (relative to current build context, from oc-sample-app folder)
COPY ./ocp-healthcheck-app /app/app
COPY requirements.txt .

# Install Python dependencies (pip usually doesn't need root, but dnf did)
# Ensure requirements.txt is at the root of the build context as per Dockerfile, not nested.
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the Flask app runs on (OpenShift commonly uses 8080)
EXPOSE 8080

# Command to run the application
CMD ["python", "app/app.py"]

