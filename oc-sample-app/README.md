OpenShift CRC Status Checker Demo
This repository contains a simple web application designed to demonstrate how to query and display the status and resources of an OpenShift cluster from within the cluster itself. The application uses Python Flask and the oc CLI tool to fetch information about projects, pods, and routes, providing a real-time overview of your OpenShift CodeReady Containers (CRC) environment.

Note: This application checks the status of the OpenShift cluster (the Kubernetes-based platform managed by CRC), not the status of the CRC virtual machine running on your host machine.

Features
Overall Cluster Status: Displays a high-level summary of the OpenShift cluster's health.

Project Listing: Lists all projects (namespaces) available in the cluster.

Pod Details: Shows details of pods within a specified project.

Route Details: Shows details of routes within a specified project.

Interactive Web UI: Simple interface with refresh buttons and namespace input fields.

Prerequisites
Before you begin, ensure you have the following installed and configured:

OpenShift CodeReady Containers (CRC) v4.18.2 or later:

Ensure your CRC instance is started (crc start) and running.

CRC Installation Guide

oc OpenShift CLI Tool:

Make sure you have the oc CLI tool installed locally and configured to interact with your CRC cluster.

You should be logged in to your CRC cluster (oc login).

Git: To clone this repository.

Updated Dockerfile and rbac.yaml: Ensure your local copies of these files reflect the latest versions discussed (especially with USER root in Dockerfile and pods, routes in ClusterRole in rbac.yaml).

File Structure
The repository expects the following structure after cloning:

oc-sample-app/
├── Dockerfile                  # Defines the container image build process
├── requirements.txt            # Python dependencies for the Flask app
├── rbac.yaml                   # OpenShift RBAC definitions (ServiceAccount, Roles, Bindings)
└── ocp-healthcheck-app/
    └── app.py                  # The main Flask application code

Getting Started
Follow these steps to deploy and run the OpenShift CRC Status Checker application on your CRC environment.

1. Clone the Repository
Clone this repository to your local machine:

git clone https://github.com/<YourGitHubUsername>/oc-sample-app.git # Replace with your actual repo URL
cd oc-sample-app

2. Prepare Your Environment and Source Files
Ensure your Dockerfile and rbac.yaml are up-to-date with the necessary permissions and build instructions.
Your Dockerfile should include USER root for dnf install and oc client copy.
Your rbac.yaml should grant get and list permissions for pods and routes in the ClusterRole.

Then, create a compressed tarball of your application source. This is the most reliable way to provide local Dockerfile content to OpenShift builds:

tar -czf app-source.tar.gz .

3. Set Up OpenShift Project and RBAC Permissions
This part ensures your application has the necessary permissions to query the cluster.

# Optional: Delete existing project for a clean start (if issues persist)
oc delete project oc-healthcheck --ignore-not-found=true

# Create your OpenShift Project
oc new-project oc-healthcheck

# Apply the RBAC Definitions
# This creates the ServiceAccount, Roles, and RoleBindings.
# Pay attention to the output to ensure 'oc-healthcheck-sa' is created.
oc apply -f rbac.yaml

4. Create OpenShift Build and Deployment Resources
This sets up the ImageStream, BuildConfig, and an initial Deployment for your application.

oc new-app oc-healthcheck-app --docker-image=oc-healthcheck-app:latest \
  --as-deployment-config --strategy=docker --name=oc-healthcheck-app

5. Start the Build by Uploading the Source Archive
This triggers the image build process using the tarball created in Step 2.

oc start-build oc-healthcheck-app --from-file=app-source.tar.gz --follow

Wait for the build to complete successfully. You should see "Build complete" in the logs.

6. Assign the Custom ServiceAccount and Trigger Deployment
After the build, explicitly assign the ServiceAccount with correct permissions to your Deployment and trigger a new rollout. This ensures the running pod has the necessary cluster-reader access.

oc set serviceaccount deployment/oc-healthcheck-app oc-healthcheck-sa
oc rollout restart deployment/oc-healthcheck-app

7. Create a Service and Expose Your Application with an OpenShift Route
These steps make your application accessible from outside the cluster.

# Create a Service to expose your deployment internally
oc expose deployment oc-healthcheck-app --port=8080 --target-port=8080 --name=oc-healthcheck-service

# Expose the Service with a Route (two steps to add TLS)
oc expose service oc-healthcheck-service --name=oc-healthcheck-route --port=8080
oc patch route oc-healthcheck-route -p '{"spec":{"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}}' --type=merge

8. Verify Deployment and Access Your Application
Monitor Pod Status:

oc get pods -w

Wait for a pod named oc-healthcheck-app-XXXXXXXXXX-YYYYY to show 1/1 Running.

View Application Logs (for troubleshooting):
If the pod isn't running or you see errors on the webpage, check the pod logs:

oc logs -f $(oc get pod -l app=oc-healthcheck-app -o jsonpath='{.items[0].metadata.name}')

Look for messages indicating the Flask server has started successfully and oc commands are executing without permission errors.

Get the Public URL (Route):

oc get route oc-healthcheck-route -o jsonpath='{.spec.host}'

This will output the hostname for your application (e.g., oc-healthcheck-route-oc-healthcheck.apps-crc.testing).

Access the Application in Your Browser:
Open your web browser and navigate to the URL you obtained from the previous step. Remember to use https:// (e.g., https://<your-route-url>/).

You should now see your "OpenShift CRC Status Checker" dashboard, displaying live data from your CRC cluster.

Troubleshooting
"ServiceAccount not found" or "Forbidden" errors: This indicates an RBAC issue. Double-check your rbac.yaml content for correct permissions (especially in the ClusterRole for cluster-wide resources like pods and routes in other namespaces) and ensure you've re-applied it and restarted the deployment (oc rollout restart deployment/oc-healthcheck-app).

Pod stuck in Pending or Error state: Use oc describe pod <pod-name> to get detailed events and oc logs <pod-name> to view application logs for clues.

Build failures: Check oc logs -f bc/oc-healthcheck-app for specific errors (e.g., dnf permissions, curl download issues for oc client). Ensure your Dockerfile includes USER root for package installations.
