# 🌐 Google Cloud

Google Cloud support in DevKit gives you powerful CLI shortcuts, automation workflows, and project setup utilities for Django deployments on GCP. Manage accounts, projects, services, databases, storage, secrets, and deploy your application end-to-end.

## 📑 Table of Contents

- [🌐 Google Cloud](#-google-cloud)
  - [🧩 Essentials](#-essentials)
  - [🔐 Account Management](#-account-management)
  - [📂 Project Management](#-project-management)
  - [🔧 Django Deployment Shortcuts](#-django-deployment-shortcuts)
    - [🚨 Important: Prepare your .env file](#-important-prepare-your-env-file)
    - [📦 Artifact Registry Utilities](#-artifact-registry-utilities)
    - [🚀 Cloud Run Deployment Utilities](#-cloud-run-deployment-utilities)
    - [📆 Google Cloud Scheduler Utilities](#-google-cloud-scheduler-utilities)
    - [🐘 Google Cloud SQL for PostgreSQL](#-google-cloud-sql-for-postgresql)
    - [🔐 Google Secret Manager](#-google-secret-manager)
    - [💾 Google Cloud Storage Management](#-google-cloud-storage-management)
      - [📂 Bucket Management](#-bucket-management)
    - [📤 Static Files & Access Control](#-static-files--access-control)
    - [🌐 Google Compute Engine - Load Balancer Automation](#-google-compute-engine---load-balancer-automation)
      - [🚦 Load Balancer Setup & Teardown](#-load-balancer-setup--teardown)
      - [🌍 IP Management](#-ip-management)
      - [🔐 SSL Certificate Management](#-ssl-certificate-management)
      - [🧩 Network Endpoint Group (NEG)](#-network-endpoint-group-neg)
      - [🔧 Backend Service Management](#-backend-service-management)
      - [🔧 URL Map Management](#-url-map-management)
      - [🔐 Target Proxies (HTTP / HTTPS)](#-target-proxies-http--https)
      - [🚦 Global Forwarding Rules](#-global-forwarding-rules)

## 🧩 Essentials

- `gcloud-init` — Initialize Google Cloud SDK and set up configurations.

- `gcloud-login-cli` — Authenticate user account for CLI access.

- `gcloud-login-adc` — Authenticate application default credentials.

- `gcloud-logout` — Revoke current authentication.

- `gcloud-info` — Show current SDK details and configuration.

- `gcloud-update` — Update installed components of the SDK.

## 🔐 Account Management

- `gcloud-account-list` — List all authenticated accounts.

- `gcloud-config-account-set <account>` — Set the active account for gcloud CLI.

## 📂 Project Management

- `gcloud-projects-list` — List all accessible projects.

- `gcloud-project-describe <project>` — Show details of a specific project.

- `gcloud-config-project-set <project>` — Set active project for gcloud CLI.

## 🔧 Django Deployment Shortcuts

A set of powerful functions to automate Django deployments on Google Cloud:

- `gcloud-project-django-setup` — 🛠️ Full project setup: Cloud SQL, buckets, secrets, Cloud Run deployment, load balancer, and scheduler jobs.

- `gcloud-project-django-teardown` — 💣 Clean teardown: destroys all GCP resources tied to your Django project.

- `gcloud-project-django-update` — 🔁 Redeploy and update services: deploy latest image, sync storage and secrets, update scheduler jobs.

**💡 Notes**  
All setup, teardown, and update functions automatically validate environment variables and .env secrets before execution.  
Log files are generated automatically for setup, teardown, and update steps, with timestamps for easy tracking.  
Secret files are written to /tmp/env_secrets securely during execution and deleted after loading.  
With these GCloud integrations, DevKit boosts your cloud automation game by allowing you to fully manage GCP Django deployments from the terminal — from project provisioning to full teardown and redeployment. ☁️🚀

### 🚨 Important: Prepare your .env file

All Django Deployment Shortcuts and GCP automations rely on environment variables defined in your local .env file.

Before using these functions, ensure you:

1. Prepare and fill the .env file properly.  
   Your .env must include all required variables, such as:

   - ```# Example .env file
     GCP_PROJECT_ID=your-gcp-project-id                       # e.g., project-id
     GCP_PROJECT_NUMBER=your-gcp-project-number               # e.g., 1052922103635
     GCP_PROJECT_NAME=your-gcp-project-name                   # e.g., Hello World
     GCP_REGION=your-gcp-region                               # e.g., europe-west3
     GCP_RUN_NAME=your-cloud-run-service-name                 # e.g., project-django-run
     GCP_RUN_MIN_INSTANCES=your-min-instances                 # e.g., 0
     GCP_RUN_MAX_INSTANCES=your-max-instances                 # e.g., 5
     GCP_RUN_CPU=your-cpu                                     # e.g., 1
     GCP_RUN_MEMORY=your-memory                               # e.g., 1Gi
     GCP_EXTENDED_IMAGE_NAME=your-extended-image-name         # e.g., project-django-extended-run-image
     GCP_RUN_CPU=your-cpu                                     # e.g., 1
     GCP_RUN_MEMORY=your-memory                               # e.g., 1Gi
     GCP_SQL_INSTANCE_ID=your-sql-instance-id                 # e.g., project-sql-instance
     GCP_SQL_INSTANCE_PASSWORD=your-sql-instance-password     # e.g., your-sql-password
     GCP_SQL_DB_NAME=your-database-name                       # e.g., project_db
     GCP_SQL_DB_USERNAME=your-database-username               # e.g., project_db_user
     GCP_SQL_DB_PASSWORD=your-database-password               # e.g., your-database-password
     GCP_SQL_DB_VERSION=your-database-version                 # e.g., POSTGRES_15
     GCP_SECRET_NAME=your-secret-manager-name                 # e.g., project-django-secret
     GCP_ARTIFACT_REGISTRY_NAME=your-artifact-registry-name   # e.g., project-artifact-registry
     GCP_SCHEDULER_TOKEN=your-cloud-scheduler-bearer-token    # e.g., your-cloud-scheduler-token
     GCP_EXTENDED_IMAGE_NAME=your-extended-image-name         # e.g., project-django-extended-run-image
     GCP_SQL_PROXY_PORT=your-sql-proxy-port                   # e.g., 5432
     GS_BUCKET_STATIC=your-static-bucket-name                 # e.g., project-django-static
     GS_BUCKET_NAME=your-bucket-name                          # e.g., project-django-bucket
     OFFICIAL_DOMAIN=your-official-domain.com                 # e.g., project.com
     DJANGO_SECRET_KEY=your-django-secret-key                 # e.g., your-django-secret-key
     ADMIN_DOMAIN=your-admin-domain.com                       # e.g., admin.project.com
     GCP_CREDS=your-gcp-credentials-file.json                 # e.g., /path/to/your-credentials.json
     ```

2. Follow the official GCP Django sample app for best practices.  
   Reference: Cloud Run Django Sample App
3. Update any project-specific fields.  
   For example, buckets names, database credentials, and Cloud Run service names must match your actual resources.
4. Secrets are handled safely.  
   DevKit reads from .env, writes secrets to secure temporary files (/tmp/env_secrets), and cleans up after execution.
5. Always check your .env before running destructive commands.  
   Functions like gcloud-project-django-teardown will permanently delete resources defined in your .env.

✅ Once your .env is configured, DevKit handles the rest.
You’ll be able to run end-to-end Django deployments on GCP — securely and repeatably.

### 📦 Artifact Registry Utilities

Manage Docker Artifact Registries for Cloud Run deployments.

- `gcloud-artifact-registry-repository-create` — Create a new Docker Artifact Registry repository
- `gcloud_artifact_registry_repository_delete` — Delete an Artifact Registry repository and its contents

### 🚀 Cloud Run Deployment Utilities

DevKit automates building Docker images, pushing to Artifact Registry, and deploying services to Cloud Run.

- `gcloud-run-build-image` — Build Docker image and push to Artifact Registry
- `gcloud-run-deploy-initial` — Deploy service to Cloud Run for the first time
- `gcloud-run-deploy-latest` — Redeploy service to Cloud Run with the latest image
- `gcloud-run-set-service-urls-env` — Update service URLs environment variable in Cloud Run
- `gcloud-run-build-and-deploy-initial` — Build and deploy service (first-time setup)
- `gcloud-run-build-and-deploy-latest` — Build and redeploy service (update)
- `gcloud-run-service-delete` — Delete Cloud Run service and job

### 📆 Google Cloud Scheduler Utilities

Automate Django cron jobs as scheduled Cloud Tasks using GCP Cloud Scheduler. Sync local URLs, create, update, and delete jobs easily.

- `gcloud-scheduler-jobs-list` — List all Cloud Scheduler jobs in the current project and region
- `gcloud-scheduler-jobs-delete` — Delete all Cloud Scheduler jobs with confirmation
- `gcloud-scheduler-jobs-sync` — Sync local Django cron jobs with Cloud Scheduler (creates or deletes jobs as needed)

### 🐘 Google Cloud SQL for PostgreSQL

Automate Cloud SQL instance creation, proxy connections, user management, and Django setup.

- `gcloud-sql-instance-create` — Create Cloud SQL PostgreSQL instance with backups and monitoring
- `gcloud-sql-instance-delete` — Delete Cloud SQL PostgreSQL instance
- `gcloud-sql-proxy-start` — Start the Cloud SQL Proxy for local secure connections
- `gcloud-sql-postgres-connect` — Connect to Cloud SQL PostgreSQL instance via gcloud CLI
- `gcloud-sql-db-and-user-create` — Create new PostgreSQL database and user inside Cloud SQL
- `gcloud-sql-db-and-user-delete` — Delete PostgreSQL database and user from Cloud SQL
- `gcloud-sql-proxy-and-django-setup` — Start SQL Proxy, run Django migrations, and populate the database

### 🔐 Google Secret Manager

Automate the management of environment secrets for your projects using Google Secret Manager.

- `gcloud-secret-manager-env-create` — 🔐 Create new secret from .env file
- `gcloud-secret-manager-env-update` — 🔄 Update secret with new version and disable old versions
- `gcloud-secret-manager-env-delete` — 🗑️ Delete secret from Secret Manager
- `gcloud-secret-manager-env-download` — 📥 Download secret to local .env file

### 💾 Google Cloud Storage Management

Full control over your static, media, and artifact storage buckets — create, configure access, sync, and clean up effortlessly.

#### 📂 Bucket Management

- `gcloud-storage-buckets-create` — 🗃️ Create static, media, and artifacts buckets with access control and CORS
- `gcloud-storage-buckets-delete` — 🗑️ Delete all storage buckets and their contents

### 📤 Static Files & Access Control

- `gcloud-storage-buckets-sync-static` — 📤 Upload and sync local static files to the bucket
- `gcloud-storage-buckets-set-public-read` — 🌐 Set public read access on static and media buckets
- `gcloud-storage-buckets-set-cross-origin` — 🔄 Apply CORS policy to buckets

### 🌐 Google Compute Engine - Load Balancer Automation

Automate the complete lifecycle of your Google Cloud Load Balancer setup, including IP allocation, SSL certs, network groups, backend services, proxies, forwarding rules, and teardown.

#### 🚦 Load Balancer Setup & Teardown

- `gcloud-compute-engine-cloud-load-balancer-setup` — ⚙️ Full setup: static IP, SSL, NEG, backend, URL map, proxies, forwarding rules
- `gcloud-compute-engine-cloud-load-balancer-teardown` — 🔄 Full teardown of the Cloud Load Balancer components

#### 🌍 IP Management

- `gcloud-compute-engine-ipv4-create` — 🌐 Create global static IPv4 address for Load Balancer
- `gcloud-compute-engine-ipv4-delete` — 🗑️ Delete static IPv4 address

#### 🔐 SSL Certificate Management

- `gcloud-compute-engine-ssl-certificate-create` — 🔐 Create Google-managed SSL certificate
- `gcloud-compute-engine-ssl-certificate-delete` — 🗑️ Delete SSL certificate

#### 🧩 Network Endpoint Group (NEG)

- `gcloud-compute-engine-network-endpoint-group-create` — 🔌 Create serverless NEG for Cloud Run
- `gcloud-compute-engine-network-endpoint-group-delete` — 🗑️ Delete serverless NEG

#### 🔧 Backend Service Management

- `gcloud-compute-engine-backend-service-create` — ⚙️ Create backend service and attach NEG
- `gcloud-compute-engine-backend-service-delete` — 🗑️ Delete backend service and detach NEG

#### 🔧 URL Map Management

- `gcloud-compute-engine-url-map-create` — 🗺️ Create URL map to route traffic to backend
- `gcloud-compute-engine-url-map-delete` — 🗑️ Delete URL map

#### 🔐 Target Proxies (HTTP / HTTPS)

- `gcloud-compute-engine-target-https-proxy-and-attach-ssl-certificate` — 🔐 Create HTTPS target proxy and attach SSL cert
- `gcloud-compute-engine-target-https-proxy-delete` — 🗑️ Delete target HTTP/HTTPS proxies

#### 🚦 Global Forwarding Rules

- `gcloud-compute-engine-global-forwarding-rule-create` — 🚦 Create global forwarding rules for HTTP/HTTPS
- `gcloud-compute-engine-global-forwarding-rule-delete` — 🗑️ Delete forwarding rules

> DevKit is your all-in-one, scriptable Swiss Army knife for macOS development environments. Automate everything — and focus on building.
