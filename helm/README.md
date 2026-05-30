# helm

CKAD domain 2 (Helm). A skeleton chart for the sample app.

```powershell
helm template sample ./helm/sample-app                 # render to stdout
helm install sample ./helm/sample-app -n sample --create-namespace
helm upgrade sample ./helm/sample-app -n sample --set api.replicas=4
helm uninstall sample -n sample
```

Values live in `sample-app/values.yaml`. Override at install/upgrade time, e.g.
`--set db.password=...` (never commit real secrets).
