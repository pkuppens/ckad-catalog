# sample-app

A minimal, generic three-tier app to exercise CKAD primitives end-to-end without
any ML/GPU complexity:

- **frontend** — nginx serving static HTML, proxying `/api/` to the API (stateless).
- **api** — FastAPI visit counter (stateless).
- **db** — PostgreSQL (stateful, PVC).

It touches all five CKAD domains: container images, Deployments + rolling updates,
liveness/readiness probes, ConfigMap/Secret/SecurityContext/resources, Services +
Ingress + NetworkPolicy, and an HPA.

## Local (Docker Compose)

```powershell
cd sample-app
docker compose up --build
# frontend: http://localhost:8080   api: http://localhost:8000/
```

## On the kind cluster

```powershell
# 1) build images and load them into kind (no registry needed)
docker build -t ckad-sample-api:dev ./sample-app/api
docker build -t ckad-sample-frontend:dev ./sample-app/frontend
kind load docker-image ckad-sample-api:dev ckad-sample-frontend:dev --name ckad

# 2a) the base (sample-app/k8s is a kustomize base)
kubectl apply -k sample-app/k8s

# 2b) or via an environment overlay
kubectl apply -k kustomize/overlays/dev

# 3) reach it through Ingress
curl -H "Host: sample.local" http://localhost/
```

## Things to practise

- `kubectl rollout` an image change and `rollout undo` it.
- Scale the API and watch the HPA (`kubectl get hpa -n sample`); needs metrics-server.
- Break readiness by deleting the DB and watch the API drop out of Service endpoints.
- Confirm the NetworkPolicy blocks non-API pods from reaching Postgres.
