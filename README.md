# EKS GitOps Platform

[![ci](https://github.com/jjesusdev/eks-gitops-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/jjesusdev/eks-gitops-platform/actions/workflows/ci.yml)

**Stack:** Terraform · AWS EKS · ArgoCD · GitHub Actions · Kustomize · Prometheus + Grafana

Infraestructura como código para provisionar un clúster Kubernetes en AWS EKS, con despliegues declarativos mediante GitOps (ArgoCD), CI/CD automatizado con GitHub Actions (OIDC auth) y monitoreo con Prometheus y Grafana.

## Arquitectura

```
                    ┌─────────────────────────────────────┐
                    │         GitHub Repository           │
                    │  (Infra + K8s manifests + CI/CD)    │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │      GitHub Actions (OIDC)          │
                    │  terraform plan → build → push ECR  │
                    └──────────────┬──────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
    ┌─────────▼──────┐  ┌─────────▼──────┐  ┌─────────▼──────┐
    │ Terraform      │  │ Docker Build   │  │ Kustomize      │
    │ (EKS + VPC)    │  │ → Amazon ECR   │  │ bump image tag │
    └────────────────┘  └────────────────┘  └────────────────┘
                                                        │
                                            ┌───────────▼───────────┐
                                            │     ArgoCD (GitOps)  │
                                            │  auto-sync to EKS    │
                                            └───────────┬───────────┘
                                                        │
                                            ┌───────────▼───────────┐
                                            │   AWS EKS Cluster     │
                                            │  ┌─────────────────┐  │
                                            │  │   Prometheus     │  │
                                            │  │   + Grafana      │  │
                                            │  │   + Alertmanager │  │
                                            │  └─────────────────┘  │
                                            └───────────────────────┘
```

## Tech Stack

| Capa | Herramienta | Versión |
|------|------------|---------|
| IaC | Terraform | >= 1.5 |
| Cloud | AWS (EKS, VPC, ECR, IAM, S3) | — |
| GitOps | ArgoCD | >= 2.10 |
| CI/CD | GitHub Actions (OIDC) | — |
| Contenedores | Docker + ECR | — |
| Manifiestos | Kustomize | built-in kubectl |
| Monitoreo | Prometheus + Grafana | — |
| Escaneo | Trivy | — |

## Estructura del repositorio

```
├── terraform/
│   ├── bootstrap/              # S3 backend + DynamoDB lock (una sola vez)
│   ├── modules/
│   │   ├── vpc/               # VPC, subnets, NAT gateways
│   │   ├── eks/               # EKS cluster + managed node groups
│   │   ├── ecr/               # ECR repositorios
│   │   └── iam/               # OIDC role para GitHub Actions
│   └── environments/
│       ├── staging/
│       └── production/
├── .github/workflows/          # CI/CD pipelines
├── k8s/
│   ├── base/                  # Deployment, Service, HPA base
│   ├── overlays/
│   │   ├── staging/
│   │   └── production/
│   └── argocd/
│       └── application.yaml   # ArgoCD Application manifest
├── scripts/
│   ├── setup.sh               # Bootstrap inicial automatizado
│   └── cleanup.sh             # Destruir toda la infra
└── docs/
    ├── ARCHITECTURE.md
    └── GETTING-STARTED.md
```

## Quick Start

### Prerrequisitos

```bash
# Herramientas locales necesarias
terraform >= 1.5
awscli >= 2.0
kubectl
docker
git
```

### 1. Bootstrap del state backend

```bash
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tu AWS account ID y región
terraform init
terraform apply
```

### 2. Deploy de staging

```bash
cd terraform/environments/staging
cp terraform.tfvars.example terraform.tfvars
# Editar con tus valores
terraform init
terraform apply
```

### 3. Acceder al cluster

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-gitops-staging
kubectl get nodes
```

### 4. Instalar ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 5. Acceder a ArgoCD

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## CI/CD Pipeline

### Flujo de deploy a staging (automático)

```
Push a rama feature/*
  → GitHub Actions
  → Terraform plan (staging)
  → Docker build → push a ECR
  → ArgoCD auto-sync a staging
```

### Flujo de deploy a producción (con aprobación)

```
Merge a main
  → GitHub Actions
  → Terraform plan (production)
  → Docker build → push a ECR (tag: git SHA)
  → Bump de image tag en k8s/overlays/production
  → ArgoCD auto-sync a producción
```

## Características

- ✅ **Infraestructura como código** — Terraform modular con remote state (S3 + DynamoDB)
- ✅ **GitOps** — ArgoCD auto-sync, self-heal, app-of-apps pattern
- ✅ **OIDC Authentication** — Sin credenciales estáticas en GitHub Actions
- ✅ **Multi-ambiente** — Staging y Production completamente aislados
- ✅ **Auto-scaling** — HPA (pods) + Karpenter (nodos)
- ✅ **Monitoreo** — Prometheus + Grafana + Alertmanager
- ✅ **Seguridad** — IAM least-privilege, IRSA, VPC privada para workers
- ✅ **FinOps** — Infracost en pipeline para visibilidad de costo

## Cómo destruir

```bash
cd terraform/environments/production
terraform destroy
cd ../staging
terraform destroy
cd ../../bootstrap
terraform destroy
```

O usar el script automatizado:

```bash
./scripts/cleanup.sh
```

## Próximos pasos

- [ ] Agregar ExternalDNS para DNS automático
- [ ] Agregar cert-manager + Let's Encrypt para HTTPS
- [ ] Agregar External Secrets Operator (ESO) con AWS Secrets Manager
- [ ] Agregar HashiCorp Vault para secretos dinámicos
- [ ] Agregar ArgoCD Image Updater para actualizaciones automáticas de imágenes
- [ ] Agregar OPA/Gatekeeper para policy as code