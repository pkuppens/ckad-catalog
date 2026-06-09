<#
.SYNOPSIS
  Delete the local CKAD minikube profile.

.DESCRIPTION
  Removes the minikube profile named "ckad" and its kube-context. Safe to run if the
  profile does not exist.
#>
[CmdletBinding()]
param(
    [string]$Profile = "ckad"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    throw "Required tool 'minikube' not found on PATH."
}

$status = minikube status -p $Profile 2>&1 | Out-String
if ($status -match "does not exist" -or $status -match "Profile .* not found") {
    Write-Host "Profile '$Profile' does not exist; nothing to do." -ForegroundColor Yellow
    return
}

Write-Host "==> Deleting minikube profile '$Profile'..." -ForegroundColor Cyan
minikube delete -p $Profile
Write-Host "==> Deleted." -ForegroundColor Green
