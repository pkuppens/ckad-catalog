# kubectl cheat sheet (CKAD speed)

The exam is time-pressured. Prefer imperative commands + `--dry-run=client -o yaml` to generate manifests, then edit.

## Setup aliases / speed

```bash
alias k=kubectl
export do="--dry-run=client -o yaml"   # k run nginx --image=nginx $do
export now="--force --grace-period=0"  # k delete pod x $now
```

PowerShell equivalents:

```powershell
Set-Alias k kubectl
$do = "--dry-run=client -o yaml"
```

## Context & namespace

```bash
kubectl config get-contexts
kubectl config use-context kind-ckad   # macOS/Linux (kind)
# kubectl config use-context ckad    # Windows (minikube)
kubectl config set-context --current --namespace=ckad
kubectl get ns
```

## Generate manifests (the core CKAD trick)

```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create deployment web --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml
kubectl create job pi --image=perl --dry-run=client -o yaml -- perl -Mbignum -wle 'print bpi(200)'
kubectl create cronjob hello --image=busybox --schedule="*/1 * * * *" --dry-run=client -o yaml -- echo hi
kubectl create configmap app-cfg --from-literal=KEY=val --dry-run=client -o yaml
kubectl create secret generic app-sec --from-literal=PASSWORD=changeme --dry-run=client -o yaml
kubectl expose deployment web --port=80 --target-port=8080 --dry-run=client -o yaml
kubectl create ingress web --rule="example.local/*=web:80" --dry-run=client -o yaml
```

## Edit live objects fast

```bash
kubectl set image deployment/web web=nginx:1.27
kubectl scale deployment/web --replicas=5
kubectl autoscale deployment/web --min=2 --max=10 --cpu-percent=70
kubectl label pod nginx tier=frontend
kubectl annotate pod nginx note="hello"
kubectl set env deployment/web LOG_LEVEL=debug
kubectl rollout status deployment/web
kubectl rollout undo deployment/web
kubectl rollout history deployment/web
```

## Inspect & debug (Observability domain)

```bash
kubectl get pods -o wide --show-labels
kubectl describe pod <pod>
kubectl logs <pod> [-c <container>] [--previous] [-f]
kubectl exec -it <pod> -- sh
kubectl get events --sort-by=.lastTimestamp
kubectl top pod / kubectl top node          # needs metrics-server
kubectl explain pod.spec.containers --recursive
kubectl debug -it <pod> --image=busybox --target=<container>   # ephemeral container
```

## Apply / delete

```bash
kubectl apply -f file.yaml
kubectl apply -k kustomize/overlays/dev
kubectl delete -f file.yaml
kubectl delete pod <pod> --force --grace-period=0
```

## Common gotchas

- `--dry-run=client` builds locally; `--dry-run=server` validates against the API.
- A Pod's `command`/`args` map to the container's entrypoint/cmd, not shell.
- `restartPolicy: Never|OnFailure` is required for Jobs.
- Readiness gates traffic; liveness restarts the container; startup protects slow starts.
- For NetworkPolicy to take effect, the CNI must enforce it (kind's default does for most labs; verify).
