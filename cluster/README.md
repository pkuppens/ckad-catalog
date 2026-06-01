# cluster — local kind harness

Local Kubernetes for CKAD practice using **kind** (Kubernetes IN Docker) on Windows + Docker Desktop.

## Prerequisites

| Tool | Install (winget) | Check |
| --- | --- | --- |
| Docker Desktop | `winget install Docker.DockerDesktop` | `docker version` |
| kind | `winget install Kubernetes.kind` | `kind version` |
| kubectl | `winget install Kubernetes.kubectl` | `kubectl version --client` |
| helm | `winget install Helm.Helm` | `helm version` |

`kustomize` is not required separately: use `kubectl apply -k` (built in).

## Usage

```powershell
./setup.ps1       # create cluster "ckad" + ingress-nginx, wait until ready
./teardown.ps1    # delete the cluster
```

`setup.ps1` is idempotent: an existing `ckad` cluster is reused. The control-plane
maps host ports 80/443, so Ingress resources are reachable at `http://localhost`.

## Notes

- Cluster name: `ckad`; context: `kind-ckad`.
- Topology: 1 control-plane + 2 workers (lets you practise nodeSelector, taints, scheduling).
- Alternatives: minikube (`minikube start`) or k3d (`k3d cluster create`). The building
  blocks are portable; only the harness scripts are kind-specific.
