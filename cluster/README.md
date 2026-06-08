# cluster — local cluster harness

Local Kubernetes for CKAD practice. **Windows** uses **minikube** (Docker driver); **macOS / Linux** use **kind** (Kubernetes IN Docker).

| OS | Backend | Setup script | Teardown script | kubectl context |
| --- | --- | --- | --- | --- |
| Windows (PowerShell) | minikube | `./cluster/setup.ps1` | `./cluster/teardown.ps1` | `ckad` |
| macOS / Linux / Git Bash / WSL | kind | `./cluster/setup.sh` | `./cluster/teardown.sh` | `kind-ckad` |

Make shell scripts executable once: `chmod +x cluster/setup.sh cluster/teardown.sh`

Windows-specific problems: [`docs/windows-troubleshooting.md`](../docs/windows-troubleshooting.md).

## Prerequisites

You need a container runtime (Docker Desktop or Docker Engine), **kubectl**, and **Helm** (for chart exercises). Kustomize is built into kubectl (`kubectl apply -k`).

- **Windows:** minikube — see [`docs/windows-prerequisites.md`](../docs/windows-prerequisites.md)
- **macOS / Linux:** kind — install steps below

### Windows

Use the dedicated prerequisites page (winget install + **version checks**):

- [`docs/windows-prerequisites.md`](../docs/windows-prerequisites.md)

Download fallbacks: [Docker Desktop](https://www.docker.com/products/docker-desktop/) · [kubectl (Windows)](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) · [Helm](https://helm.sh/docs/intro/install/) · [minikube](https://minikube.sigs.k8s.io/docs/start/)

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
./cluster/setup.ps1       # minikube profile "ckad" + ingress addon, wait until ready
./cluster/teardown.ps1    # delete the profile
```

**Bash (macOS / Linux / WSL / Git Bash):**

```bash
./cluster/setup.sh        # kind cluster "ckad" + ingress-nginx
./cluster/teardown.sh
```

Setup is idempotent: an existing `ckad` cluster/profile is reused. Host ports 80/443 are mapped so Ingress resources are reachable at `http://localhost`.

## Notes

- Profile/cluster name: **`ckad`**
- **Windows:** minikube context `ckad`, single-node cluster
- **macOS / Linux:** kind context `kind-ckad`, 1 control-plane + 2 workers (practice nodeSelector, taints, scheduling)
- Building blocks and manifests are portable; only these harness scripts are platform-specific
