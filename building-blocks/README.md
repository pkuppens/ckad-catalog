# building-blocks

Small, annotated, single-primitive manifests grouped by CKAD domain. Apply any of
them to the kind cluster to study one concept at a time. Most files include the
imperative `kubectl ... --dry-run=client -o yaml` command that generates them.

```powershell
kubectl apply -f building-blocks/namespace.yaml          # create the "ckad" namespace first
kubectl apply -f building-blocks/design-build/job.yaml
kubectl apply -f building-blocks/observability/probes.yaml
```

| Folder | CKAD domain | Examples |
| --- | --- | --- |
| `design-build/` | 1. Design and Build | Pod, Job, CronJob, init container, sidecar, emptyDir |
| `deployment/` | 2. Deployment | Deployment with rolling update / rollback |
| `observability/` | 3. Observability and Maintenance | liveness/readiness/startup probes, crashloop for debugging |
| `config-security/` | 4. Environment, Config and Security | ConfigMap, Secret, SecurityContext, ServiceAccount, resources, quota/limitrange, PVC |
| `services-networking/` | 5. Services and Networking | ClusterIP/NodePort/LoadBalancer, Ingress, NetworkPolicy |

See [`../docs/coverage-matrix.md`](../docs/coverage-matrix.md) for the subtopic-to-file map.
