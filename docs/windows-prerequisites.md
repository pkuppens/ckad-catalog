# Windows prerequisites (Docker Desktop + minikube + kubectl + Helm)

This page is the single source of truth for installing and verifying the tools needed to run this repo on **Windows**.

## 1) Install with winget

Run in **PowerShell** (Admin is usually not required for winget):

```powershell
winget install Docker.DockerDesktop
winget install Kubernetes.minikube
winget install Kubernetes.kubectl
winget install Helm.Helm
```

After installing, **restart your terminal** so the new tools are available on `PATH`.

## 2) Start Docker Desktop

- Open Docker Desktop and wait until it reports **Engine running**.
- Recommended: Docker Desktop **WSL 2 backend** (Settings → General → *Use the WSL 2 based engine*).

## 3) Verify versions (with checks)

Run:

```powershell
docker version
minikube version
kubectl version --client
helm version
```

If you want a strict automated check (recommended), run this:

```powershell
$ErrorActionPreference = "Stop"

function Assert-Command([string]$Name) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required tool '$Name' not found on PATH. Restart the terminal after winget install."
  }
}

function Parse-SemVerFromText([string]$Text) {
  # Accepts strings like: "minikube version: v1.35.0" or "v3.17.2+g...."
  $m = [regex]::Match($Text, "v(?<v>\d+\.\d+\.\d+)")
  if (-not $m.Success) { return $null }
  return [Version]$m.Groups["v"].Value
}

function Assert-MinVersion([string]$ToolName, [Version]$Actual, [Version]$Min) {
  if (-not $Actual) { throw "Could not parse version for $ToolName." }
  if ($Actual -lt $Min) { throw "$ToolName version $Actual is too old. Need at least $Min." }
}

Assert-Command docker
Assert-Command minikube
Assert-Command kubectl
Assert-Command helm

$minMinikube = [Version]"1.32.0"
$minHelm = [Version]"3.0.0"

$minikubeV = Parse-SemVerFromText (minikube version --short 2>$null | Out-String)
if (-not $minikubeV) { $minikubeV = Parse-SemVerFromText (minikube version | Out-String) }
$helmV = Parse-SemVerFromText (helm version --short 2>$null | Out-String)

Assert-MinVersion "minikube" $minikubeV $minMinikube
Assert-MinVersion "helm" $helmV $minHelm

Write-Host "OK: docker/minikube/kubectl/helm installed. minikube=$minikubeV helm=$helmV" -ForegroundColor Green
```

## 4) Next step

Back to the repo flow:

- Create the cluster: `./cluster/setup.ps1`
- If something fails: see [`docs/windows-troubleshooting.md`](windows-troubleshooting.md)
