#!/usr/bin/env bash
# Delete the local CKAD kind cluster.
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-ckad}"

if ! command -v kind >/dev/null 2>&1; then
  echo "Required tool 'kind' not found on PATH." >&2
  exit 1
fi

if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo "Cluster '$CLUSTER_NAME' does not exist; nothing to do."
  exit 0
fi

echo "==> Deleting kind cluster '$CLUSTER_NAME'..."
kind delete cluster --name "$CLUSTER_NAME"
echo "==> Deleted."
