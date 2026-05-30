# kustomize

CKAD domain 2 (Kustomize). The `base` reuses `sample-app/k8s/`; overlays patch it
per environment.

```powershell
kubectl apply -k kustomize/overlays/dev    # 1 replica each, :dev images
kubectl apply -k kustomize/overlays/prod   # more replicas, larger limits, :prod images
kubectl kustomize kustomize/overlays/prod  # render without applying
kubectl delete -k kustomize/overlays/dev
```

Practice ideas: add a `staging` overlay, change `images[].newTag`, add a
`configMapGenerator`, or use `namePrefix`/`nameSuffix`.
