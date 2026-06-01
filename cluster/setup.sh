#!/usr/bin/env bash
# Create the local CKAD kind cluster and install ingress-nginx.
# Idempotent: reuses an existing cluster named "ckad".
# Prerequisites: docker, kind, kubectl (helm optional for chart work).
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-ckad}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="${CONFIG_PATH:-$SCRIPT_DIR/kind-config.yaml}"

for cmd in docker kind kubectl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required tool '$cmd' not found on PATH. See cluster/README.md for install steps." >&2
    exit 1
  fi
done

echo "==> Checking for existing kind cluster '$CLUSTER_NAME'..."
if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo "    Cluster '$CLUSTER_NAME' already exists; reusing it."
else
  echo "==> Creating kind cluster '$CLUSTER_NAME'..."
  kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_PATH"
fi

kubectl cluster-info --context "kind-$CLUSTER_NAME"

echo "==> Installing ingress-nginx (kind provider manifest)..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "==> Waiting for ingress-nginx controller to become ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "==> Done. Nodes:"
kubectl get nodes -o wide
echo "Context set to 'kind-$CLUSTER_NAME'. Try: kubectl apply -k kustomize/overlays/dev"
