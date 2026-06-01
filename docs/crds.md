# Custom Resource Definitions (CKAD domain 4)

CKAD expects you to *use* CRDs (discover, inspect, create custom resources), not to
write controllers.

## Inspect what custom resources exist

```bash
kubectl get crds
kubectl api-resources --api-group=<group>
kubectl explain <kind> --recursive
kubectl get <kind> -A
```

## Minimal CRD example (for local practice)

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.example.com
spec:
  group: example.com
  scope: Namespaced
  names:
    plural: widgets
    singular: widget
    kind: Widget
    shortNames: ["wg"]
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                size:
                  type: string
```

Then create an instance:

```yaml
apiVersion: example.com/v1
kind: Widget
metadata:
  name: my-widget
spec:
  size: large
```

```bash
kubectl apply -f widget-crd.yaml
kubectl apply -f my-widget.yaml
kubectl get widgets
```
