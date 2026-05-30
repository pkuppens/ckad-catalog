# Kustomize vs Helm (CKAD domain 2)

Both package/parameterise manifests; CKAD may touch either.

| Aspect | Kustomize | Helm |
| --- | --- | --- |
| Model | Patch/overlay plain YAML (no templating) | Go-templated charts + values |
| Built into kubectl | Yes (`kubectl apply -k`) | No (separate `helm` binary) |
| Best for | Environment variants of the same manifests | Reusable, parameterised, distributable packages |
| State | Stateless transform | Tracks releases (`helm list`, rollback) |
| Secrets | Plain (use SOPS/sealed-secrets externally) | `--set`/values (still plaintext unless plugins) |

Rule of thumb: **Kustomize** for "same app, different environments" (this repo's
`kustomize/overlays`); **Helm** when you want versioned releases, upgrade/rollback,
or to share the app as an installable unit (this repo's `helm/sample-app`).
