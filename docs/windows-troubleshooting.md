# Windows troubleshooting (kind + Docker Desktop)

Tips for running the local CKAD cluster on Windows. macOS and Linux users can skip this page.

## Before you start

1. **Use Docker Desktop with the WSL 2 backend** (Settings → General → *Use the WSL 2 based engine*). The Hyper-V backend works for many setups but WSL 2 is the default Docker recommendation and avoids several networking quirks with `kind`.
2. **Install tools into the same environment you use for kubectl** — either Windows PowerShell or a WSL distro, not both interchangeably. Mixing shells causes “command not found” and wrong kube-context errors.
3. **Restart the terminal** after `winget install` so `kind`, `kubectl`, and `helm` appear on `PATH`.

## Install checklist (Windows)

Run in **PowerShell** (Admin not required for winget if your policy allows user installs):

```powershell
winget install Docker.DockerDesktop
winget install Kubernetes.kind
winget install Kubernetes.kubectl
winget install Helm.Helm
```

Wait for Docker Desktop to finish starting (whale icon steady in the tray), then verify:

```powershell
docker version
kind version
kubectl version --client
helm version
```

Official fallbacks if winget packages are unavailable:

| Tool | Download |
| --- | --- |
| Docker Desktop | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) |
| kubectl | [kubernetes.io/docs/tasks/tools/install-kubectl-windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) |
| Helm | [helm.sh/docs/intro/install](https://helm.sh/docs/intro/install/) |
| kind | [kind.sigs.k8s.io/docs/user/quick-start#installation](https://kind.sigs.k8s.io/docs/user/quick-start#installation) |

## Running the cluster scripts

From the repo root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # once, if scripts are blocked
./cluster/setup.ps1
```

If you prefer **Git Bash** or **WSL**, use the shell scripts instead:

```bash
chmod +x cluster/setup.sh cluster/teardown.sh
./cluster/setup.sh
```

Use one shell family consistently; `kubectl` context and `kind load docker-image` must target the same Docker daemon.

## Common problems

### `Required tool 'kind' not found on PATH`

- Close and reopen the terminal after `winget install`.
- Confirm with `Get-Command kind` (PowerShell) or `which kind` (Git Bash/WSL).
- winget sometimes installs to a user path that older sessions do not load.

### Docker Desktop is running but `docker version` fails

- Open Docker Desktop and wait until it reports *Engine running*.
- Ensure WSL integration is enabled for your distro (Settings → Resources → WSL Integration) if you run Docker commands from WSL.
- Reboot once after the first Docker Desktop install.

### `kind create cluster` hangs or nodes stay NotReady

- Allocate enough memory: Docker Desktop → Settings → Resources (≥ 4 GB RAM recommended for 1 control-plane + 2 workers).
- Delete a broken cluster and retry: `./cluster/teardown.ps1` then `./cluster/setup.ps1`.
- Check nothing else binds host ports **80** or **443** (IIS, other ingress controllers, Skype historically used 80).

### `kubectl` talks to the wrong cluster

```powershell
kubectl config current-context    # should be kind-ckad
kubectl config use-context kind-ckad
```

### Sample app pods stuck in `ImagePullBackOff`

Images are local tags, not pulled from a registry. Build and load before applying manifests:

```powershell
docker build -t ckad-sample-api:dev ./sample-app/api
docker build -t ckad-sample-frontend:dev ./sample-app/frontend
kind load docker-image ckad-sample-api:dev ckad-sample-frontend:dev --name ckad
```

Run `kind load` in the **same environment** as `docker build` (Windows Docker Desktop vs WSL Docker are separate daemons).

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

- **One cluster name (`ckad`)** — teardown when switching branches or after failed experiments to avoid stale contexts.
- **Idempotent setup** — re-running `setup.ps1` / `setup.sh` is safe; it reuses an existing cluster.
- **Keep course notes in `tmp/`** — never commit copyrighted external course material (see [CLAUDE.md](../CLAUDE.md)).
- **Placeholder secrets only** — do not put real credentials in manifests.
- **Prefer `kubectl apply -k`** over hand-editing rendered YAML; Kustomize is built into kubectl.

## Still stuck?

1. `./cluster/teardown.ps1` (or `./cluster/teardown.sh`)
2. Restart Docker Desktop
3. `./cluster/setup.ps1` and re-run the [Getting started](../README.md#getting-started) steps from the root README
