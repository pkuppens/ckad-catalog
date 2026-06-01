# ckad-catalog

A catalog of **generic, reusable Kubernetes building blocks**, a local cluster harness, and study material for the **CKAD (Certified Kubernetes Application Developer)** exam. Artifacts are built abstract-first here, proven on a local cluster, then ported into portfolio projects (`on_prem_rag`, `babblr`).

> Build abstract/generic here first → prove it on a local `kind` cluster → port the result into the projects.

**Platforms:** Windows, macOS, and Linux with [Docker](https://docs.docker.com/get-docker/) and [kind](https://kind.sigs.k8s.io/). Harness scripts are provided for PowerShell and Bash; Kubernetes manifests work on any cluster.

### Why this repo

- CKAD tests how you **deploy and operate apps on Kubernetes** (Deployments, Services, Ingress, ConfigMaps/Secrets, probes, PVCs, HPA, NetworkPolicies, Jobs).
- Generic, annotated building blocks stay reusable across projects and easy to showcase.
- A coverage matrix gives **traceability** so no exam domain is missed.

### Layout

| Path | Purpose |
| --- | --- |
| [`cluster/`](cluster/README.md) | Local `kind` cluster harness + ingress install |
| [`building-blocks/`](building-blocks/README.md) | One primitive per file, grouped by CKAD domain |
| [`sample-app/`](sample-app/README.md) | Minimal three-tier app to exercise every primitive |
| [`kustomize/`](kustomize/README.md) | Base + dev/prod overlays for the sample app |
| [`helm/`](helm/README.md) | Helm chart skeleton for the sample app |
| [`docs/`](docs/coverage-matrix.md) | Coverage matrix, cheat sheet, [Windows troubleshooting](docs/windows-troubleshooting.md) |
| `tmp/` | Gitignored scratch — never commit copyrighted course material |

## Getting started

### Prerequisites

Install Docker, [kind](https://kind.sigs.k8s.io/), [kubectl](https://kubernetes.io/docs/tasks/tools/), and [Helm](https://helm.sh/). Kustomize is built into kubectl (`apply -k`).

<details>
<summary><strong>Windows</strong> (PowerShell + winget)</summary>

```powershell
winget install Docker.DockerDesktop
winget install Kubernetes.kind
winget install Kubernetes.kubectl
winget install Helm.Helm
```

1. Start **Docker Desktop** and wait until the engine is running.
2. **Restart your terminal**, then verify: `docker version`, `kind version`, `kubectl version --client`, `helm version`.

Downloads if winget is unavailable: [Docker Desktop](https://www.docker.com/products/docker-desktop/) · [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) · [Helm](https://helm.sh/docs/intro/install/) · [kind](https://kind.sigs.k8s.io/docs/user/quick-start#installation)

**Windows troubleshooting:** [`docs/windows-troubleshooting.md`](docs/windows-troubleshooting.md) (WSL 2, PATH, ImagePullBackOff, ingress, script execution).

</details>

<details>
<summary><strong>macOS</strong> (Homebrew)</summary>

Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/), then:

```bash
brew install kind kubectl helm
docker version && kind version && kubectl version --client && helm version
```

</details>

<details>
<summary><strong>Linux</strong> (Docker Engine + curl)</summary>

Install [Docker Engine](https://docs.docker.com/engine/install/) for your distro, then kind, kubectl, and Helm using the commands in [`cluster/README.md`](cluster/README.md#linux).

</details>

Full per-OS notes: [`cluster/README.md`](cluster/README.md).

### Run the sample app on kind

From the repo root.

**Windows (PowerShell):**

```powershell
./cluster/setup.ps1
kubectl get nodes

docker build -t ckad-sample-api:dev ./sample-app/api
docker build -t ckad-sample-frontend:dev ./sample-app/frontend
kind load docker-image ckad-sample-api:dev ckad-sample-frontend:dev --name ckad

kubectl apply -k kustomize/overlays/dev
curl -H "Host: sample.local" http://localhost/

./cluster/teardown.ps1
```

**macOS / Linux / WSL / Git Bash:**

```bash
chmod +x cluster/setup.sh cluster/teardown.sh   # first time only
./cluster/setup.sh
kubectl get nodes

docker build -t ckad-sample-api:dev ./sample-app/api
docker build -t ckad-sample-frontend:dev ./sample-app/frontend
kind load docker-image ckad-sample-api:dev ckad-sample-frontend:dev --name ckad

kubectl apply -k kustomize/overlays/dev
curl -H "Host: sample.local" http://localhost/

./cluster/teardown.sh
```

More deploy options and practice ideas: [`sample-app/README.md`](sample-app/README.md).

## Build and test

There is no CI pipeline or automated test suite. Verify changes manually with `kubectl`, Docker Compose, or Helm render.

From a fresh clone:

```bash
git clone https://github.com/pkuppens/ckad-catalog.git
cd ckad-catalog
./cluster/setup.ps1          # Windows PowerShell
# or: ./cluster/setup.sh    # macOS / Linux / WSL
```

**Sample app (Docker Compose, no cluster):**

```bash
cd sample-app
docker compose up --build
# frontend: http://localhost:8080   api: http://localhost:8000/
```

**Helm chart (render without applying):**

```bash
helm template sample ./helm/sample-app
```

**Single building blocks (cluster must be running):**

```bash
kubectl apply -f building-blocks/namespace.yaml
kubectl apply -f building-blocks/design-build/job.yaml
```

See [`building-blocks/README.md`](building-blocks/README.md), [`kustomize/README.md`](kustomize/README.md), and [`helm/README.md`](helm/README.md) for full command lists.

Study traceability: [`docs/coverage-matrix.md`](docs/coverage-matrix.md).

## Contributing

This is a personal study repo. Effort is tracked under EPIC [pkuppens/pkuppens#109](https://github.com/pkuppens/pkuppens/issues/109). Repo issues: [github.com/pkuppens/ckad-catalog/issues](https://github.com/pkuppens/ckad-catalog/issues).

When adding or changing manifests:

- One primitive per building-block file; keep manifests minimal and CKAD-exam-shaped.
- Start each manifest with a comment block: intent + the `kubectl ... --dry-run=client -o yaml` command that generates it.
- Never commit real secrets (placeholders only) or copyrighted external course material (keep course notes in `tmp/`, gitignored).
- When a lab covers a CKAD subtopic, tick it in [`docs/coverage-matrix.md`](docs/coverage-matrix.md).

Full conventions: [`CLAUDE.md`](CLAUDE.md).

## License

MIT — see [LICENSE](LICENSE).
