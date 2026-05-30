# Deployment strategies (CKAD domain 2)

## Rolling update (default)

The built-in `RollingUpdate` strategy replaces pods gradually using `maxSurge` /
`maxUnavailable`. Demonstrated in `building-blocks/deployment/deployment.yaml`.

```bash
kubectl set image deployment/web web=nginx:1.27   # trigger update
kubectl rollout status deployment/web
kubectl rollout undo deployment/web               # roll back
kubectl rollout history deployment/web
```

## Blue/green (two Deployments, switch the Service)

Run `web-blue` and `web-green` Deployments. A single Service selects one colour via
its `selector`. Cut over by editing the Service selector; roll back by switching it
back. Zero in-flight version mixing.

```bash
kubectl patch service web -p '{"spec":{"selector":{"app":"web","color":"green"}}}'
```

## Canary (weight by replica count)

Run a small number of `web-canary` pods sharing the Service label with the stable
pods. Traffic splits roughly by replica ratio (e.g. 1 canary : 9 stable ~ 10%).
Scale the canary up as confidence grows, then promote.

```bash
kubectl scale deployment/web-canary --replicas=3   # increase canary share
```

CKAD-level expectation: understand the trade-offs and be able to express blue/green
and canary with plain Deployments + Services (no service mesh required).
