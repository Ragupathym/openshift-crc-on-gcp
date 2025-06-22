from flask import Flask, render_template, jsonify, request
import subprocess
import os

app = Flask(__name__)

# Function to execute oc commands and return output
def run_oc_command(command, namespace=None):
    cmd = ["oc"] + command
    if namespace:
        cmd += ["-n", namespace]
    
    try:
        # Use a service account token for authentication within the cluster
        # The pod's service account automatically gets mounted tokens for API access
        result = subprocess.run(cmd, capture_output=True, text=True, check=True, timeout=30)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing command: {e}\n{e.stderr}"
    except FileNotFoundError:
        return "Error: 'oc' command not found. Ensure it's installed in the container."
    except subprocess.TimeoutExpired:
        return "Error: Command timed out."

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/status')
def get_cluster_status():
    output = run_oc_command(["status"])
    return jsonify({"status": output})

@app.route('/api/projects')
def get_projects():
    # List all projects (namespaces)
    output = run_oc_command(["get", "projects", "-o", "name"])
    return jsonify({"projects": output.splitlines()})

@app.route('/api/pods')
def get_pods():
    namespace = request.args.get('namespace', 'openshift-console') # Default namespace
    output = run_oc_command(["get", "pods"], namespace=namespace)
    return jsonify({"pods": output})

@app.route('/api/routes')
def get_routes():
    namespace = request.args.get('namespace', 'openshift-console') # Default namespace
    output = run_oc_command(["get", "routes"], namespace=namespace)
    return jsonify({"routes": output})

if __name__ == '__main__':
    # OpenShift applications often listen on 0.0.0.0 and a specific port (like 8080 or 8081)
    app.run(host='0.0.0.0', port=8080)