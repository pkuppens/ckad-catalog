# ckad-catalog

A catalog of **generic, reusable Kubernetes building blocks** plus a local cluster harness and study material, built to earn the **CKAD (Certified Kubernetes Application Developer)** certification and then **ported into real portfolio projects**.

> Build abstract/generic here first -> prove it on a local `kind` cluster -> port the result into the projects (`on_prem_rag`, `babblr`).

## Why this repo

- CKAD tests how you **deploy and operate apps on Kubernetes** (Deployments, Services, Ingress, ConfigMaps/Secrets, probes, PVCs, HPA, NetworkPolicies, Jobs).
- Keeping the building blocks generic and annotated makes them reusable across projects and clean to showcase.
- A coverage matrix gives **traceability** so no exam domain is missed, even when study tasks come piecemeal from an external course.

## Layout

| Path | Purpose |
| --- | --- |
| `cluster/` | Local `kind` cluster harness (Windows PowerShell) + ingress install |
| `building-blocks/` | Small, annotated manifests, one primitive each, grouped by CKAD domain |
| `sample-app/` | Minimal generic multi-tier app to exercise every primitive end-to-end |
| `kustomize/` | Base + overlays (dev/prod) for the sample app |
| `helm/` | Helm chart skeleton for the sample app |
| `docs/` | Coverage matrix, kubectl cheat sheet, course log, Kustomize-vs-Helm note |
| `tmp/` | Gitignored scratch (course notes etc.) — never commit copyrighted course material |

## Quick start

```powershell
# Prerequisites: Docker Desktop, kind, kubectl, helm (see cluster/README.md)
./cluster/setup.ps1        # create kind cluster + ingress-nginx
kubectl get nodes          # nodes should be Ready
kubectl apply -k kustomize/overlays/dev   # deploy the sample app
./cluster/teardown.ps1     # delete the cluster
```

## Tracking

- Effort tracked under EPIC [pkuppens/pkuppens#109](https://github.com/pkuppens/pkuppens/issues/109).
- Study traceability: [`docs/coverage-matrix.md`](docs/coverage-matrix.md).

## License

MIT — see [LICENSE](LICENSE).
