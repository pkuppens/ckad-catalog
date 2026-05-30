<#
.SYNOPSIS
  Create the local CKAD kind cluster and install ingress-nginx.

.DESCRIPTION
  Idempotent helper for Windows + Docker Desktop. Creates a kind cluster named
  "ckad" from kind-config.yaml, installs the ingress-nginx controller, and waits
  until it is ready. Re-running is safe: an existing cluster is reused.

.NOTES
  Prerequisites: Docker Desktop, kind, kubectl, helm.
  Install (winget):  winget install Kubernetes.kind Kubernetes.kubectl Helm.Helm
#>
[CmdletBinding()]
param(
    [string]$ClusterName = "ckad",
    [string]$ConfigPath = (Join-Path $PSScriptRoot "kind-config.yaml")
)

$ErrorActionPreference = "Stop"

function Assert-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required tool '$Name' not found on PATH. See cluster/README.md for install steps."
    }
}

Assert-Command docker
Assert-Command kind
Assert-Command kubectl

Write-Host "==> Checking for existing kind cluster '$ClusterName'..." -ForegroundColor Cyan
$existing = (kind get clusters) -split "`n" | Where-Object { $_.Trim() -eq $ClusterName }
if ($existing) {
    Write-Host "    Cluster '$ClusterName' already exists; reusing it." -ForegroundColor Yellow
}
else {
    Write-Host "==> Creating kind cluster '$ClusterName'..." -ForegroundColor Cyan
    kind create cluster --name $ClusterName --config $ConfigPath
}

kubectl cluster-info --context "kind-$ClusterName" | Out-Host

Write-Host "==> Installing ingress-nginx (kind provider manifest)..." -ForegroundColor Cyan
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

Write-Host "==> Waiting for ingress-nginx controller to become ready..." -ForegroundColor Cyan
kubectl wait --namespace ingress-nginx `
    --for=condition=ready pod `
    --selector=app.kubernetes.io/component=controller `
    --timeout=180s

Write-Host "==> Done. Nodes:" -ForegroundColor Green
kubectl get nodes -o wide | Out-Host
Write-Host "Context set to 'kind-$ClusterName'. Try: kubectl apply -k kustomize/overlays/dev" -ForegroundColor Green
