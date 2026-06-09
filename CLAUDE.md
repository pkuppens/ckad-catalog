# CLAUDE.md — ckad-catalog

## Project overview

Generic, reusable Kubernetes building blocks + a local cluster harness + CKAD study coverage. Artifacts are developed abstract-first here, then ported into portfolio projects (`on_prem_rag`, `babblr`).

## Commands

```powershell
./cluster/setup.ps1                       # Windows: minikube profile ckad + ingress
./cluster/teardown.ps1                    # delete cluster/profile
kubectl apply -k kustomize/overlays/dev   # deploy sample app (dev overlay)
helm template ./helm/sample-app           # render Helm chart
kubectl apply -f building-blocks/<domain>/<file>.yaml
```

## Conventions

- Every manifest starts with a comment block: intent + the imperative `kubectl ... --dry-run=client -o yaml` command that generates it.
- One primitive per building-block file; keep them minimal and CKAD-exam-shaped.
- Namespaces: building blocks default to `ckad`; sample app uses `sample`.
- Generic only here. Project-specific wiring lives in the project repos.

## Critical rules

- Never commit copyrighted external course material. Keep it in `tmp/` (gitignored).
- Never commit real secrets. Secret manifests use placeholder values only.
- Coverage: when a building block/lab covers a CKAD subtopic, tick it in `docs/coverage-matrix.md` and the EPIC (pkuppens/pkuppens#109).

## Tooling

- Local cluster: **minikube** (Windows PowerShell), **kind** (macOS/Linux via `setup.sh`). Same profile name `ckad`.
- `kubectl` (v1.3x), `helm`, and `kubectl`'s built-in Kustomize (`apply -k`).
