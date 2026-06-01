<#
.SYNOPSIS
  Delete the local CKAD kind cluster.

.DESCRIPTION
  Removes the kind cluster named "ckad" and its kube-context. Safe to run if the
  cluster does not exist.
#>
[CmdletBinding()]
param(
    [string]$ClusterName = "ckad"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command kind -ErrorAction SilentlyContinue)) {
    throw "Required tool 'kind' not found on PATH."
}

$existing = (kind get clusters) -split "`n" | Where-Object { $_.Trim() -eq $ClusterName }
if (-not $existing) {
    Write-Host "Cluster '$ClusterName' does not exist; nothing to do." -ForegroundColor Yellow
    return
}

Write-Host "==> Deleting kind cluster '$ClusterName'..." -ForegroundColor Cyan
kind delete cluster --name $ClusterName
Write-Host "==> Deleted." -ForegroundColor Green
