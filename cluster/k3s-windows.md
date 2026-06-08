# K3s on Windows (via WSL2)

Alternative to `kind` for running a local Kubernetes cluster on Windows. Uses
K3s inside a WSL2 Alpine distribution — no Docker Desktop required.

> **Sources:** <https://mrtn.me/autocloud/main/howtos/k3s-windows-install/>

**Better download link**

Go to the MINI ROOT FILESYSTEM section, selest x86_64 [Download Link](https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86_64/alpine-minirootfs-3.23.4-x86_64.tar.gz)

---

## Why K3s instead of kind?

| | kind | K3s (WSL2) |
|---|---|---|
| Requires Docker | Yes | No |
| Startup time | ~30s | ~10s |
| Traefik ingress | manual | built-in |
| Windows Kubernetes toggle | needed | not needed |

---

## Pre-requisites

Verify WSL is working:

```powershell
wsl --status
```

WSL2 must be enabled. On Windows 11 (or Windows 10 build 19041+), if not running:

```powershell
wsl --install
```

Restart when prompted. 

---

## 1. Create the WSL distribution

Download the Alpine minimal root filesystem and import it as a new WSL distro
named `myk3s`:

```powershell
# Download Alpine rootfs
([System.Net.WebClient]::new()).DownloadFile(
    "https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86_64/alpine-minirootfs-3.23.4-x86_64.tar.gz",
    "$PWD/alpine.tgz"
)

# Import as WSL distro in the current directory
wsl --import myk3s . alpine.tgz

> The operation completed successfully/

# Verify the distro exists
wsl --list --verbose

>   NAME              STATE           VERSION
>   ...
>   myk3s             Stopped         2

```

---

## 2. Install K3s

Connect to the distro and install K3s (skipping auto-start so openrc controls
the lifecycle):

```shell
# Enter the distro
wsl -d myk3s

# Install required packages
apk update
apk add curl
apk add openrc

# Install K3s — skip auto-start; openrc will manage it
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh -

# Validate:
which k3s
ls -l /etc/init.d/k3s
```


The installer creates:
- `/usr/local/bin/k3s` (and symlinks: `kubectl`, `crictl`, `ctr`)
- `/usr/local/bin/k3s-killall.sh`
- `/usr/local/bin/k3s-uninstall.sh`
- `/etc/init.d/k3s` (openrc service)

---

## 3. Start K3s

Still inside the WSL distro:

```shell
# Start openrc (brings up the k3s service)
openrc default

rc-service k3s status

# Verify the node is ready
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes

# Confirm all system workloads rolled out
kubectl -n kube-system rollout status deployments,statefulsets,daemonsets
```

Expected node status: `Ready   control-plane,master`

Expected deployments: `local-path-provisioner`, `coredns`, `traefik`,
`metrics-server` — all successfully rolled out.

---

## 4. Access K3s from Windows (PowerShell)

Without touching kubeconfig:

```powershell
wsl -d myk3s k3s kubectl get pods -A
```

### Integrate into your main kubeconfig (optional but recommended)

```powershell
# Point KUBECONFIG to the K3s config inside WSL
$env:KUBECONFIG = "\\wsl$\myk3s\etc\rancher\k3s\k3s.yaml"

# Rename the generic "default" context to something meaningful
kubectl config rename-context default myk3s

# Merge with your existing ~/.kube/config
$env:KUBECONFIG = "$env:KUBECONFIG;$env:USERPROFILE\.kube\config"
kubectl config view --flatten > config.new

# Replace 127.0.0.1 with localhost (required for Windows access)
(Get-Content .\config.new) -replace '127.0.0.1', 'localhost' | Set-Content config.new

# Verify the merged config
$env:KUBECONFIG = "$PWD\config.new"
kubectl config get-contexts
kubectl get nodes

# Backup old config and put the merged one in place
Move-Item $env:USERPROFILE\.kube\config $env:USERPROFILE\.kube\config.bak
Move-Item .\config.new $env:USERPROFILE\.kube\config

# Clear the override — kubectl will now use the standard location
$env:KUBECONFIG = $null
kubectl get nodes
```

---

## 5. Stop K3s

```powershell
# Graceful shutdown (cleans up CNI, iptables, etc.)
wsl -d myk3s k3s-killall.sh

# Terminate the WSL distro
wsl --terminate myk3s
```

---

## 6. Re-start K3s

```powershell
wsl -d myk3s openrc default
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `wsl --install` fails | Enable "Windows Subsystem for Linux" feature in *Turn Windows features on or off* |
| Node stuck in `NotReady` | Wait ~60s; check `wsl -d myk3s journalctl -u k3s` |
| `kubectl` not found on Windows | Use `wsl -d myk3s k3s kubectl` or merge kubeconfig (Step 4) |
| Port conflicts with existing cluster | Stop kind/Docker Desktop first; only one cluster should bind port 6443 |
| `k3s-killall.sh` hangs | Run `wsl --terminate myk3s` to force-stop |

---

## Uninstall

```powershell
# Remove the WSL distro entirely (destroys all K3s state)
wsl --unregister myk3s
```

Or from inside the distro:

```shell
k3s-uninstall.sh
```
