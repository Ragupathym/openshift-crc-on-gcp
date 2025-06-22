# Use a Universal Base Image (UBI) with Python 3.9
FROM registry.access.redhat.com/ubi8/python-39:latest

# Set environment variables for non-interactive commands
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container
WORKDIR /app

# Install necessary packages for downloading and extracting oc CLI
# dnf is for UBI8 (Red Hat based)
RUN dnf install -y curl tar gzip && \
    dnf clean all

# Download and install the OpenShift 'oc' CLI tool
# Using a general 'latest' version from OpenShift mirrors.
# For a specific CRC version match (e.g., v4.18.2), you might
# replace 'latest' with '4.18' if that specific client version is available.
ENV OC_VERSION="4.18.2" # You can try to set this to your CRC version, e.g., 4.18
RUN curl -LO "https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OC_VERSION}/linux/oc.tar.gz" && \
    tar -xzf oc.tar.gz -C /usr/local/bin && \
    rm oc.tar.gz && \
    chmod +x /usr/local/bin/oc

# Copy application files
COPY ./app /app/app
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the Flask app runs on (OpenShift commonly uses 8080)
EXPOSE 8080

# Command to run the application
CMD ["python", "app/app.py"]