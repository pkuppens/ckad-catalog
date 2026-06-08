# cluster — local kind harness

Local Kubernetes for CKAD practice using **kind** (Kubernetes IN Docker). Works on **Windows**, **macOS**, and **Linux** with Docker installed.

| OS | Setup script | Teardown script |
| --- | --- | --- |
| Windows (PowerShell) | `./cluster/setup.ps1` | `./cluster/teardown.ps1` |
| macOS / Linux / Git Bash / WSL | `./cluster/setup.sh` | `./cluster/teardown.sh` |

Make shell scripts executable once: `chmod +x cluster/setup.sh cluster/teardown.sh`

Windows-specific problems: [`docs/windows-troubleshooting.md`](../docs/windows-troubleshooting.md).

## Prerequisites

You need a container runtime (Docker Desktop or Docker Engine), **kind**, **kubectl**, and **Helm** (for chart exercises). Kustomize is built into kubectl (`kubectl apply -k`).

### Windows

Install with [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) in PowerShell:

```powershell
winget install Docker.DockerDesktop
winget install Kubernetes.kind
winget install Kubernetes.kubectl
winget install Helm.Helm
```

Restart the terminal, start Docker Desktop, then verify: `docker version`, `kind version`, `kubectl version --client`, `helm version`.

Download fallbacks: [Docker Desktop](https://www.docker.com/products/docker-desktop/) · [kubectl (Windows)](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) · [Helm](https://helm.sh/docs/intro/install/) · [kind](https://kind.sigs.k8s.io/docs/user/quick-start#installation)

### macOS

Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/), then:

```bash
brew install kind kubectl helm
```

Or install kubectl via the [official macOS guide](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/).

### Linux

Install [Docker Engine](https://docs.docker.com/engine/install/) for your distro, add your user to the `docker` group, then:

```bash
# kind — pick the latest version from https://kind.sigs.k8s.io/dl/
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64"
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
# arm64: use kind-linux-arm64 in the URL above

# kubectl — https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# helm — https://helm.sh/docs/intro/install/
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Adjust architecture (`arm64` vs `amd64`) if needed.

## Usage

**PowerShell (Windows):**

```powershell
./cluster/setup.ps1       # create cluster "ckad" + ingress-nginx, wait until ready
./cluster/teardown.ps1    # delete the cluster
```

**Bash (macOS / Linux / WSL / Git Bash):**

```bash
./cluster/setup.sh
./cluster/teardown.sh
```

Setup is idempotent: an existing `ckad` cluster is reused. The control-plane maps host ports 80/443, so Ingress resources are reachable at `http://localhost`.

## Notes

- Cluster name: `ckad`; context: `kind-ckad`.
- Topology: 1 control-plane + 2 workers (practice nodeSelector, taints, scheduling).
- Alternatives: minikube (`minikube start`) or k3d (`k3d cluster create`). Building blocks are portable; only these harness scripts are kind-specific.
