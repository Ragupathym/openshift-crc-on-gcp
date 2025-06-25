# OpenShift CRC Status Checker - Consolidated Deployment Guide

## Note: This is a demo app just to show the functionality.Please use for learning purpose.

This guide provides a streamlined, step-by-step process to deploy the OpenShift CRC Status Checker application. It combines all necessary commands and configurations for quick and easy deployment, assuming you are starting from a clean state and have your CRC instance running.

## 1. Prerequisites and Setup

Ensure you have the following:

* OpenShift CodeReady Containers (CRC) v4.18.2+ running

  ```bash
  crc start
  ```

* oc CLI tool installed and logged into your CRC cluster

  ```bash
  oc login
  ```

* Git installed on your system

## 2. File Structure and Required Files

Ensure your local repository (e.g., oc-sample-app) contains the following:

```
oc-sample-app/
├── Dockerfile                  # Defines the container image build process
├── requirements.txt            # Python dependencies for the Flask app
├── rbac.yaml                   # OpenShift RBAC definitions (ServiceAccount, Roles, Bindings)
└── ocp-healthcheck-app/
    └── app.py                  # The main Flask application code
```

Make sure Dockerfile and rbac.yaml match the official version in your project. These are critical for the app to build and run with the correct permissions.

## 3. Deployment Steps

### 3.1 Navigate to Project Directory

```bash
cd /path/to/your/oc-sample-app  # Replace with your actual path
```

### 3.2 Clean Up (Optional) & Create New Project

```bash
oc delete project oc-healthcheck --ignore-not-found=true
oc new-project oc-healthcheck
```

### 3.3 Apply RBAC Permissions

```bash
oc apply -f rbac.yaml
```

### 3.4 Package Source & Build Image

```bash
tar -czf app-source.tar.gz .

oc new-app oc-healthcheck-app \
  --docker-image=oc-healthcheck-app:latest \
  --as-deployment-config \
  --strategy=docker \
  --name=oc-healthcheck-app

oc start-build oc-healthcheck-app --from-file=app-source.tar.gz --follow
```

### 3.5 Assign Service Account & Trigger Deployment

```bash
oc set serviceaccount deployment/oc-healthcheck-app oc-healthcheck-sa
oc rollout restart deployment/oc-healthcheck-app
```

### 3.6 Create Service & Expose Route

```bash
oc expose deployment oc-healthcheck-app \
  --port=8080 --target-port=8080 \
  --name=oc-healthcheck-service

oc expose service oc-healthcheck-service \
  --name=oc-healthcheck-route \
  --port=8080

oc patch route oc-healthcheck-route \
  -p '{"spec":{"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}}' \
  --type=merge
```

## 4. Verify & Access Your Application

### Monitor Pod Status

```bash
oc get pods -w
```

Wait until the pod shows as 1/1 Running.

### View Application Logs (For Troubleshooting)

```bash
oc logs -f $(oc get pod -l app=oc-healthcheck-app -o jsonpath='{.items[0].metadata.name}')
```

### Get Public Route URL

```bash
oc get route oc-healthcheck-route -o jsonpath='{.spec.host}'
```

### Access in Browser

Open the following in your web browser:

```
https://<your-route-url>
```

## 5. Troubleshooting Quick Notes

### "Forbidden" or "ServiceAccount not found"

* Verify your rbac.yaml content
* Re-apply:

  ```bash
  oc apply -f rbac.yaml
  oc rollout restart deployment/oc-healthcheck-app
  ```

### Pod stuck in Pending/Error

* Use:

  ```bash
  oc describe pod <pod-name>
  oc logs <pod-name>
  ```

### Build Failures

* Check:

  ```bash
  oc logs -f bc/oc-healthcheck-app
  ```

* Common Issues:

  * Ensure Dockerfile has:

    ```dockerfile
    USER root
    ```
  * Verify OC\_VERSION and URL used in Dockerfile.

You are done. The CRC Health Check App should now be running inside your OpenShift environment.

