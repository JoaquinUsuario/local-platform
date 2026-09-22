# Local GitOps Platform

[![Terraform CI](https://github.com/JoaquinUsuario/local-platform/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/JoaquinUsuario/local-platform/actions/workflows/terraform-ci.yml)
[![K8s Validation](https://github.com/JoaquinUsuario/local-platform/actions/workflows/k8s-validate.yml/badge.svg)](https://github.com/JoaquinUsuario/local-platform/actions/workflows/k8s-validate.yml)

A complete GitOps platform environment runnable entirely on a local machine to achieve **100% cost optimization**. This project demonstrates advanced Cloud and Platform Engineering skills by provisioning infrastructure as code (IaC) and managing the cluster state via GitOps principles.

## 🚀 Key Features & Technologies

- **100% Local & Free:** Uses `kind` (Kubernetes IN Docker) to avoid cloud provider costs while testing platform engineering patterns.
- **Infrastructure as Code (IaC):** `Terraform` provisions the local Kubernetes cluster and bootstraps the GitOps controller.
- **GitOps Engine:** `ArgoCD` manages cluster state, implementing the "App of Apps" pattern to control the platform tools and demo applications directly from this Git repository.
- **Observability:** `Prometheus` and `Grafana` deployed via Helm (managed by ArgoCD) for cluster monitoring.
- **CI/CD:** `GitHub Actions` validate Terraform syntax and Kubernetes manifests automatically on every push.

## 🏗️ Architecture & GitOps Flow

1. **Bootstrap:** `terraform apply` spins up the `kind` cluster and installs `ArgoCD`.
2. **Platform Sync:** ArgoCD reads the `platform/argocd-apps` directory in this repository and automatically installs:
   - The Observability Stack (kube-prometheus-stack).
   - The Demo Application.
3. **Continuous Delivery:** Any changes merged into `main` (e.g., updating a container image in `apps/demo-app/deployment.yaml`) are automatically synchronized to the cluster by ArgoCD.

## 📂 Repository Structure

- `bootstrap/`: Terraform configurations to create the cluster and install ArgoCD.
- `platform/`: ArgoCD applications and platform-level helm charts (Observability).
- `apps/`: Kubernetes manifests for the demo microservice.
- `.github/workflows/`: CI pipelines for Terraform and Kubernetes YAML validation.

## 🛠️ How to run locally

### Prerequisites
- Docker
- Terraform >= 1.0
- `kubectl`
- `kind` (Kubernetes IN Docker)

### Step 1: Clone and Update Repo URL
First, fork or clone this repository.
**Important:** Update the `repoURL` in `platform/argocd-apps/observability.yaml` and `platform/argocd-apps/demo-app.yaml` to point to YOUR GitHub repository URL.

### Step 2: Provision Infrastructure
```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

### Step 3: Apply the "App of Apps"
Once Terraform finishes, point ArgoCD to this repository:
```bash
kubectl apply -f ../platform/argocd-apps/
```

### Step 4: Access the Dashboards

**ArgoCD UI:**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Login at https://localhost:8080 
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Grafana UI:**
```bash
kubectl port-forward svc/observability-grafana -n monitoring 3000:80
# Login at http://localhost:3000
# Username: admin
# Password: prom-operator
```

**Demo App:**
```bash
kubectl port-forward svc/demo-app -n demo-app 9898:9898
# Access at http://localhost:9898
```

## 🧹 Cleanup
To destroy the local environment and free up resources:
```bash
cd bootstrap
terraform destroy -auto-approve
```
