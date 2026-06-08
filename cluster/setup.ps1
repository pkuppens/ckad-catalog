<#
.SYNOPSIS
  Create the local CKAD minikube cluster and enable the ingress addon.

.DESCRIPTION
  Idempotent helper for Windows + Docker Desktop. Starts a minikube profile named
  "ckad" (Docker driver), enables the ingress addon, and waits until the controller
  is ready. Re-running is safe: an existing running profile is reused.

.NOTES
  Prerequisites: Docker Desktop, minikube, kubectl, helm.
  Windows prerequisites + install + version checks:
    docs/windows-prerequisites.md
  macOS/Linux use kind via cluster/setup.sh instead.
#>
[CmdletBinding()]
param(
    [string]$Profile = "ckad",
    [string]$Driver = "docker",
    [int]$Cpus = 4,
    [string]$Memory = "4096"
)

$ErrorActionPreference = "Stop"

function Assert-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required tool '$Name' not found on PATH. See docs/windows-prerequisites.md for install steps."
    }
}

function Parse-SemVerFromText([string]$Text) {
    $m = [regex]::Match($Text, "v(?<v>\d+\.\d+\.\d+)")
    if (-not $m.Success) { return $null }
    return [Version]$m.Groups["v"].Value
}

function Assert-MinVersion([string]$ToolName, [Version]$Actual, [Version]$Min) {
    if (-not $Actual) { throw "Could not parse version for $ToolName." }
    if ($Actual -lt $Min) { throw "$ToolName version $Actual is too old. Need at least $Min." }
}

function Test-MinikubeProfileRunning([string]$Name) {
    $status = minikube status -p $Name 2>&1 | Out-String
    return ($status -match "host:\s*Running") -and ($status -match "kubelet:\s*Running")
}

Assert-Command docker
Assert-Command minikube
Assert-Command kubectl
Assert-Command helm

$minMinikube = [Version]"1.32.0"
$minHelm = [Version]"3.0.0"

$minikubeV = Parse-SemVerFromText (minikube version --short 2>$null | Out-String)
if (-not $minikubeV) {
    $minikubeV = Parse-SemVerFromText (minikube version | Out-String)
}
$helmV = Parse-SemVerFromText (helm version --short 2>$null | Out-String)

Assert-MinVersion "minikube" $minikubeV $minMinikube
Assert-MinVersion "helm" $helmV $minHelm

Write-Host "==> Checking minikube profile '$Profile'..." -ForegroundColor Cyan
if (Test-MinikubeProfileRunning $Profile) {
    Write-Host "    Profile '$Profile' is already running; reusing it." -ForegroundColor Yellow
}
else {
    Write-Host "==> Starting minikube profile '$Profile'..." -ForegroundColor Cyan
    minikube start -p $Profile `
        --driver=$Driver `
        --cpus=$Cpus `
        --memory=$Memory `
        --ports=127.0.0.1:80:80,127.0.0.1:443:443
}

kubectl cluster-info --context $Profile | Out-Host

Write-Host "==> Enabling ingress addon..." -ForegroundColor Cyan
minikube addons enable ingress -p $Profile

Write-Host "==> Waiting for ingress-nginx controller to become ready..." -ForegroundColor Cyan
kubectl config use-context $Profile | Out-Null
kubectl wait --namespace ingress-nginx `
    --for=condition=ready pod `
    --selector=app.kubernetes.io/component=controller `
    --timeout=180s

Write-Host "==> Done. Nodes:" -ForegroundColor Green
kubectl get nodes -o wide | Out-Host
Write-Host "Context set to '$Profile'. Try: kubectl apply -k kustomize/overlays/dev" -ForegroundColor Green
