# OpenShift CRC Status Checker Demo

This repository contains a simple web application designed to demonstrate how to query and display the status and resources of an OpenShift cluster from *within* the cluster itself. The application uses Python Flask and the `oc` CLI tool to fetch information about projects, pods, and routes, providing a real-time overview of your OpenShift CodeReady Containers (CRC) environment.

**Note:** This application checks the status of the *OpenShift cluster* (the Kubernetes-based platform managed by CRC), not the status of the CRC virtual machine running on your host machine.

## Features

* **Overall Cluster Status:** Displays a high-level summary of the OpenShift cluster's health.
* **Project Listing:** Lists all projects (namespaces) available in the cluster.
* **Pod Details:** Shows details of pods within a specified project.
* **Route Details:** Shows details of routes within a specified project.
* **Interactive Web UI:** Simple interface with refresh buttons and namespace input fields.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

* **OpenShift CodeReady Containers (CRC) v4.18.2 or later:**
    * Ensure your CRC instance is started (`crc start`) and running.
    * [CRC Installation Guide](https://developers.redhat.com/products/codeready-containers/overview)
* **`oc` OpenShift CLI Tool:**
    * Make sure you have the `oc` CLI tool installed locally and configured to interact with your CRC cluster.
    * You should be logged in to your CRC cluster (`oc login`).
* **Git:** To clone this repository.

## Getting Started

Follow these steps to deploy and run the OpenShift CRC Status Checker application on your CRC environment.

### 1. Clone the Repository

```bash
git clone [https://github.com/](https://github.com/)<YourGitHubUsername>/openshift-crc-status-app.git
cd openshift-crc-status-app