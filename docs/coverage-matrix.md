# CKAD domain coverage matrix

Single source of truth that maps every CKAD domain subtopic to the building block(s) / lab(s) that cover it. Mirror of the matrix in EPIC [pkuppens/pkuppens#109](https://github.com/pkuppens/pkuppens/issues/109).

**How to use:** When a building block or course lab demonstrates a subtopic on the kind cluster, tick its box, fill the "Building block / evidence" column, and link the tracking issue. Course-driven work often covers only part of a domain or combines several — that is fine; this matrix is what guarantees the whole curriculum is eventually covered.

Status legend: `[ ]` not started, `[~]` in progress, `[x]` covered + verified on cluster.

Weights are the official CKAD domain weights.

## 1. Application Design and Build (~20%)

| Done | Subtopic | Building block / evidence | Issue |
| --- | --- | --- | --- |
| [ ] | Define, build and modify container images | `sample-app/*/Dockerfile` | #114 |
| [ ] | Jobs | `building-blocks/design-build/job.yaml` | #113 |
| [ ] | CronJobs | `building-blocks/design-build/cronjob.yaml` | #113 |
| [ ] | Multi-container: init container | `building-blocks/design-build/pod-init-container.yaml` | #113 |
| [ ] | Multi-container: sidecar | `building-blocks/design-build/pod-sidecar.yaml` | #113 |
| [ ] | Volumes (emptyDir) | `building-blocks/design-build/pod-emptydir.yaml` | #113 |
| [ ] | Volumes (PVC usage) | `building-blocks/config-security/pvc.yaml` | #113 |

## 2. Application Deployment (~20%)

| Done | Subtopic | Building block / evidence | Issue |
| --- | --- | --- | --- |
| [ ] | Deployments | `building-blocks/deployment/deployment.yaml` | #113 |
| [ ] | Rolling updates + rollback | `building-blocks/deployment/deployment.yaml` (+ cheat sheet) | #113 |
| [ ] | Deployment strategies (blue/green, canary basics) | `docs/deployment-strategies.md` | #113 |
| [ ] | Helm | `helm/sample-app/` | #115 |
| [ ] | Kustomize (base + overlays) | `kustomize/` | #115 |

## 3. Application Observability and Maintenance (~15%)

| Done | Subtopic | Building block / evidence | Issue |
| --- | --- | --- | --- |
| [ ] | Liveness probe | `building-blocks/observability/probes.yaml` | #113 |
| [ ] | Readiness probe | `building-blocks/observability/probes.yaml` | #113 |
| [ ] | Startup probe | `building-blocks/observability/probes.yaml` | #113 |
| [ ] | Container logging | `docs/cheatsheet.md` (logs) | #111 |
| [ ] | Monitoring applications | `kubectl top` (metrics-server) | #111 |
| [ ] | Debugging | `building-blocks/observability/crashloop.yaml` + cheat sheet | #113 |
| [ ] | API deprecations awareness | `docs/cheatsheet.md` notes | #112 |

## 4. Application Environment, Configuration and Security (~25%)

| Done | Subtopic | Building block / evidence | Issue |
| --- | --- | --- | --- |
| [ ] | ConfigMaps | `building-blocks/config-security/configmap.yaml` | #113 |
| [ ] | Secrets | `building-blocks/config-security/secret.yaml` | #113 |
| [ ] | SecurityContext | `building-blocks/config-security/securitycontext.yaml` | #113 |
| [ ] | ServiceAccounts | `building-blocks/config-security/serviceaccount.yaml` | #113 |
| [ ] | Resource requests/limits | `building-blocks/config-security/resources.yaml` | #113 |
| [ ] | ResourceQuota / LimitRange | `building-blocks/config-security/quota-limitrange.yaml` | #113 |
| [ ] | CRDs usage | `docs/crds.md` | #113 |
| [ ] | AuthN / AuthZ / admission basics | `building-blocks/config-security/serviceaccount.yaml` notes | #113 |

## 5. Services and Networking (~20%)

| Done | Subtopic | Building block / evidence | Issue |
| --- | --- | --- | --- |
| [ ] | Service: ClusterIP | `building-blocks/services-networking/service-clusterip.yaml` | #113 |
| [ ] | Service: NodePort | `building-blocks/services-networking/service-nodeport.yaml` | #113 |
| [ ] | Service: LoadBalancer | `building-blocks/services-networking/service-loadbalancer.yaml` | #113 |
| [ ] | NetworkPolicy | `building-blocks/services-networking/networkpolicy.yaml` | #113 |
| [ ] | Ingress | `building-blocks/services-networking/ingress.yaml` | #113 |

## End-to-end coverage

The `sample-app` (#114) deploys with Kustomize/Helm and is expected to demonstrate
multiple domains at once (Deployment + probes + ConfigMap/Secret + Service/Ingress +
HPA + NetworkPolicy). The project ports (#116 `on_prem_rag`, #117 `babblr`) are the
real-world showcases.
