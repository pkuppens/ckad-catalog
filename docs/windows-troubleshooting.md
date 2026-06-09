# Windows troubleshooting (minikube + Docker Desktop)

Tips for running the local CKAD cluster on Windows. macOS and Linux users can skip this page (they use **kind** via `cluster/setup.sh`).

## Before you start

1. **Use Docker Desktop with the WSL 2 backend** (Settings → General → *Use the WSL 2 based engine*). The Hyper-V backend works for many setups but WSL 2 is the default Docker recommendation and avoids several networking quirks with local clusters.
2. **Install tools into the same environment you use for kubectl** — either Windows PowerShell or a WSL distro, not both interchangeably. Mixing shells causes “command not found” and wrong kube-context errors.
3. **Restart the terminal** after `winget install` so `minikube`, `kubectl`, and `helm` appear on `PATH`.

## Install checklist (Windows)

Use the dedicated prerequisites page (winget install + **version checks**):

- [`docs/windows-prerequisites.md`](windows-prerequisites.md)

Official fallbacks if winget packages are unavailable:

| Tool | Download |
| --- | --- |
| Docker Desktop | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) |
| kubectl | [kubernetes.io/docs/tasks/tools/install-kubectl-windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) |
| Helm | [helm.sh/docs/intro/install](https://helm.sh/docs/intro/install/) |
| minikube | [minikube.sigs.k8s.io/docs/start](https://minikube.sigs.k8s.io/docs/start/) |

## Meta-validation: confirm Kubernetes responds (Windows)

Run this **before** the repo end-to-end workflow. Every command must succeed without `connection refused`, `Unable to connect`, or `The connection to the server ... was refused`.

### Step 1 — Docker and CLI tools (client only)

```powershell
docker version          # Client AND Server sections present
minikube version
kubectl version --client
helm version
```

### Step 2 — Create any minikube cluster (minimal smoke test)

If you have never run minikube on this machine, prove the toolchain works:

```powershell
winget install Kubernetes.minikube   # skip if already installed
minikube version
minikube start --driver=docker       # default profile "minikube"
```

Use **one kubectl context at a time** — check with `kubectl config current-context`. If you already have a working cluster (any profile), you can skip to Step 3.

### Step 3 — Client **and** server respond

```powershell
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
kubectl version                  # shows Client Version AND Server Version
```

**Pass when:**

| Check | Expected |
| --- | --- |
| `kubectl get nodes` | At least one node, status `Ready` |
| `kubectl cluster-info` | Kubernetes control plane URL prints (no error) |
| `kubectl version` | **Server Version** line is present (not client-only) |
| `kubectl get pods -A` | Lists system pods (may take a minute after create) |

Example of a healthy `kubectl get nodes`:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   2m    v1.x.x
```

### Step 4 — Switch to the repo cluster

The catalog uses a dedicated minikube profile **`ckad`**. From the repo root:

```powershell
./cluster/setup.ps1
kubectl config current-context    # should be ckad
kubectl get nodes                 # 1 node Ready
```

If you have other minikube profiles and get the wrong context:

```powershell
kubectl config get-contexts
kubectl config use-context ckad
```

### Quick diagnostic one-liner

```powershell
kubectl get nodes 2>&1; if ($LASTEXITCODE -ne 0) { Write-Host 'FAIL: kubectl cannot reach a cluster' -ForegroundColor Red } else { Write-Host 'OK: cluster responds' -ForegroundColor Green }
```

## Running the cluster scripts

From the repo root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # once, if scripts are blocked
./cluster/setup.ps1
```

If you prefer **Git Bash** or **WSL** on Windows, use the **kind** shell scripts instead (different backend):

```bash
chmod +x cluster/setup.sh cluster/teardown.sh
./cluster/setup.sh
```

Use one shell family consistently; `kubectl` context and `minikube image load` must target the same Docker daemon.

## Common problems

### `Required tool 'minikube' not found on PATH`

- Close and reopen the terminal after `winget install`.
- Confirm with `Get-Command minikube` (PowerShell) or `which minikube` (Git Bash/WSL).
- winget sometimes installs to a user path that older sessions do not load.

### Docker Desktop is running but `docker version` fails

- Open Docker Desktop and wait until it reports *Engine running*.
- Ensure WSL integration is enabled for your distro (Settings → Resources → WSL Integration) if you run Docker commands from WSL.
- Reboot once after the first Docker Desktop install.

### `minikube start` hangs or nodes stay NotReady

- Allocate enough memory: Docker Desktop → Settings → Resources (≥ 4 GB RAM recommended).
- Delete a broken profile and retry: `./cluster/teardown.ps1` then `./cluster/setup.ps1`.
- Check nothing else binds host ports **80** or **443** (IIS, other ingress controllers, Skype historically used 80).

### Cluster starts then fails after a while

This usually points to Docker Desktop / WSL 2 / resource issues rather than Kubernetes YAML.

- Confirm Docker Desktop is healthy: `docker version` shows **Client** and **Server** sections.
- Ensure WSL 2 backend is enabled (Docker Desktop → Settings → General).
- Increase resources: Docker Desktop → Settings → Resources (RAM/CPU).
- Check for port conflicts (80/443) and stop IIS if needed: `netstat -ano | findstr ":80"` and `netstat -ano | findstr ":443"`.
- Inspect minikube logs:

```powershell
minikube logs -p ckad
```

### `kubectl` talks to the wrong cluster

```powershell
kubectl config current-context    # should be ckad
kubectl config use-context ckad
```

If you run multiple profiles (e.g. default `minikube` and repo `ckad`), list contexts with `kubectl config get-contexts`.

### Sample app pods stuck in `ImagePullBackOff`

Images are local tags, not pulled from a registry. Build and load before applying manifests:

```powershell
docker build -t ckad-sample-api:dev ./sample-app/api
docker build -t ckad-sample-frontend:dev ./sample-app/frontend
minikube image load ckad-sample-api:dev -p ckad
minikube image load ckad-sample-frontend:dev -p ckad
```

Run `minikube image load` in the **same environment** as `docker build` (Windows Docker Desktop vs WSL Docker are separate daemons).

### Ingress / `curl http://localhost/` returns connection refused

- Wait for ingress-nginx: `kubectl get pods -n ingress-nginx`.
- Confirm the dev overlay is applied: `kubectl get ingress -n sample`.
- Use the Host header: `curl -H "Host: sample.local" http://localhost/` (or add `127.0.0.1 sample.local` to `C:\Windows\System32\drivers\etc\hosts`).

### PowerShell script execution disabled

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Or run: `powershell -ExecutionPolicy Bypass -File ./cluster/setup.ps1`

### Line endings after cloning on Windows

If `.sh` scripts fail in Git Bash with `$'\r': command not found`, configure Git once:

```powershell
git config core.autocrlf input
```

Re-clone or run `dos2unix cluster/*.sh` in Git Bash.

## Best practices

- **One profile name (`ckad`)** — teardown when switching branches or after failed experiments to avoid stale contexts.
- **Idempotent setup** — re-running `setup.ps1` / `setup.sh` is safe; it reuses an existing cluster.
- **Keep course notes in `tmp/`** — never commit copyrighted external course material (see [CLAUDE.md](../CLAUDE.md)).
- **Placeholder secrets only** — do not put real credentials in manifests.
- **Prefer `kubectl apply -k`** over hand-editing rendered YAML; Kustomize is built into kubectl.

## Still stuck?

1. `./cluster/teardown.ps1` (or `./cluster/teardown.sh` on macOS/Linux)
2. Restart Docker Desktop
3. `./cluster/setup.ps1` and re-run the [Getting started](../README.md#getting-started) steps from the root README
