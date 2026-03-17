# Kubernetes Cheatsheet

Quick reference for everything you need to work with Kubernetes. Based on the Linux Foundation courses in this folder.

---

## 1. kubectl — Basics

| Action | Command |
|--------|--------|
| Check cluster & config | `kubectl cluster-info` |
| Current context | `kubectl config current-context` |
| List contexts | `kubectl config get-contexts` |
| Use a context | `kubectl config use-context <name>` |
| API resources | `kubectl api-resources` |
| API versions | `kubectl api-versions` |

---

## 2. kubectl — Create & Apply

| Action | Command |
|--------|--------|
| Create from file | `kubectl create -f manifest.yaml` |
| Create from URL | `kubectl create -f https://...` |
| Apply (declare state) | `kubectl apply -f manifest.yaml` |
| Apply directory | `kubectl apply -f ./dir/` |
| Apply with label | `kubectl apply -f manifest.yaml -l app=nginx` |
| Dry run (client) | `kubectl apply -f manifest.yaml --dry-run=client` |
| Dry run (server) | `kubectl apply -f manifest.yaml --dry-run=server` |
| Run a Pod (imperative) | `kubectl run nginx --image=nginx:latest` |
| Create Deployment | `kubectl create deployment nginx --image=nginx` |

---

## 3. kubectl — Read & List

| Action | Command |
|--------|--------|
| Get all in namespace | `kubectl get all` or `kubectl get all -n <ns>` |
| Get pods | `kubectl get pods` / `kubectl get po` |
| Get pods all namespaces | `kubectl get pods -A` |
| Get with labels | `kubectl get pods -l app=nginx` |
| Wide output | `kubectl get pods -o wide` |
| YAML output | `kubectl get pod <name> -o yaml` |
| JSON output | `kubectl get pod <name> -o json` |
| Describe resource | `kubectl describe pod <name>` |
| Get Deployments | `kubectl get deploy` |
| Get Services | `kubectl get svc` |
| Get ConfigMaps | `kubectl get configmap` |
| Get Secrets | `kubectl get secrets` |
| Get Ingress | `kubectl get ingress` |
| Get nodes | `kubectl get nodes` |
| Get namespaces | `kubectl get namespaces` / `kubectl get ns` |
| Watch (live updates) | `kubectl get pods -w` |

---

## 4. kubectl — Update & Delete

| Action | Command |
|--------|--------|
| Delete from file | `kubectl delete -f manifest.yaml` |
| Delete by name | `kubectl delete pod <name>` |
| Delete by label | `kubectl delete pods -l app=nginx` |
| Delete all in namespace | `kubectl delete all --all -n <ns>` |
| Edit resource | `kubectl edit pod <name>` |
| Scale Deployment | `kubectl scale deployment nginx --replicas=3` |
| Set image | `kubectl set image deployment/nginx nginx=nginx:1.21` |
| Rollout restart | `kubectl rollout restart deployment nginx` |
| Rollout status | `kubectl rollout status deployment nginx` |
| Rollback | `kubectl rollout undo deployment nginx` |

---

## 5. kubectl — Debug & Interact

| Action | Command |
|--------|--------|
| Logs (single container) | `kubectl logs <pod>` |
| Logs (follow) | `kubectl logs -f <pod>` |
| Logs (all containers in pod) | `kubectl logs <pod> --all-containers=true` |
| Logs (previous crash) | `kubectl logs <pod> --previous` |
| Exec into pod | `kubectl exec -it <pod> -- /bin/sh` |
| Exec specific container | `kubectl exec -it <pod> -c <container> -- /bin/sh` |
| Copy from pod | `kubectl cp <pod>:<path> <local-path>` |
| Copy to pod | `kubectl cp <local-path> <pod>:<path>` |
| Port forward | `kubectl port-forward pod/<name> 8080:80` |
| Port forward Service | `kubectl port-forward svc/<name> 8080:80` |
| Port forward Deployment | `kubectl port-forward deployment/<name> 8080:80` |

---

## 6. Minikube

| Action | Command |
|--------|--------|
| Start cluster | `minikube start` |
| Stop | `minikube stop` |
| Status | `minikube status` |
| Delete cluster | `minikube delete` |
| Dashboard | `minikube dashboard` |
| SSH into node | `minikube ssh` |
| Docker env (use Minikube’s Docker) | `eval $(minikube docker-env)` |
| Service URL | `minikube service <svc-name> --url` |
| Tunnel (LoadBalancer on non-cloud) | `minikube tunnel` |
| List addons | `minikube addons list` |
| Enable addon | `minikube addons enable ingress` |

---

## 7. Namespaces

| Action | Command |
|--------|--------|
| List | `kubectl get ns` |
| Create | `kubectl create namespace <name>` |
| Use default for commands | `kubectl config set-context --current --namespace=<name>` |
| Get/describe with namespace | `kubectl get pods -n <ns>` |
| Delete namespace (and all in it) | `kubectl delete ns <name>` |

---

## 8. Core object YAML structure

Every manifest needs:

```yaml
apiVersion: ...   # e.g. v1, apps/v1, networking.k8s.io/v1
kind: ...         # Pod, Deployment, Service, ConfigMap, Secret, Ingress, etc.
metadata:
  name: ...
  namespace: ...  # optional
  labels: ...
spec: ...         # desired state (structure depends on kind)
# status: ...     # managed by Kubernetes, don’t set in manifests
```

---

## 9. Pod (minimal)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

---

## 10. Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.29
          ports:
            - containerPort: 80
```

---

## 11. Service types

| Type | Use case |
|------|----------|
| **ClusterIP** (default) | Internal cluster access only |
| **NodePort** | Expose on each node’s IP on a fixed port (30000–32767) |
| **LoadBalancer** | Cloud LB; on Minikube use `minikube tunnel` or NodePort |

**Service (ClusterIP):**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

**Service (NodePort):**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

---

## 12. ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  key1: value1
  config.json: |
    { "option": true }
---
# In Pod: env from ConfigMap
spec:
  containers:
    - name: app
      image: myapp
      envFrom:
        - configMapRef:
            name: app-config
# Or single env var:
#   env:
#     - name: KEY1
#       valueFrom:
#         configMapKeyRef:
#           name: app-config
#           key: key1
# Or as volume:
#   volumeMounts:
#     - name: config
#       mountPath: /etc/config
#   volumes:
#     - name: config
#       configMap:
#         name: app-config
```

Create from literal:  
`kubectl create configmap my-cm --from-literal=key=value`  
Create from file:  
`kubectl create configmap my-cm --from-file=app.properties`

---

## 13. Secret (generic / opaque)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:   # plain text; Kubernetes encodes to base64
  username: admin
  password: secret123
# Or use "data" with base64-encoded values
---
# In Pod:
#   env:
#     - name: PASSWORD
#       valueFrom:
#         secretKeyRef:
#           name: app-secret
#           key: password
```

Create from literal:  
`kubectl create secret generic my-secret --from-literal=password=xxx`  
Create from file:  
`kubectl create secret generic my-secret --from-file=./tls.crt`

---

## 14. Ingress (HTTP routing)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-svc
                port:
                  number: 80
```

On Minikube: `minikube addons enable ingress`

---

## 15. PersistentVolumeClaim (storage)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard   # or omit for default
---
# In Pod spec:
#   volumes:
#     - name: data
#       persistentVolumeClaim:
#         claimName: my-pvc
#   containers:
#     - volumeMounts:
#         - name: data
#           mountPath: /data
```

---

## 16. Quick reference — apiVersion & kind

| kind | apiVersion (common) |
|------|----------------------|
| Pod, Service, ConfigMap, Secret, Namespace, PVC | `v1` |
| Deployment, ReplicaSet, DaemonSet, StatefulSet | `apps/v1` |
| Ingress | `networking.k8s.io/v1` |
| IngressClass | `networking.k8s.io/v1` |
| NetworkPolicy | `networking.k8s.io/v1` |
| Role, RoleBinding | `rbac.authorization.k8s.io/v1` |
| ClusterRole, ClusterRoleBinding | `rbac.authorization.k8s.io/v1` |
| Job, CronJob | `batch/v1` |

---

## 17. Labels & selectors

- **Labels:** key-value pairs on objects (e.g. `app: nginx`, `tier: frontend`).
- **Selectors:** used by Deployments, Services, etc. to target resources.
  - Equality: `matchLabels: { app: nginx }`
  - Set-based: `matchExpressions: [{ key: env, operator: In, values: [prod] }]`

List by label:  
`kubectl get pods -l app=nginx`  
`kubectl get pods -l 'env in (prod, staging)'`

---

## 18. Useful one-liners

```bash
# Get pod names only
kubectl get pods -o name

# Get pod IPs
kubectl get pods -o wide

# Delete failed / Evicted pods
kubectl delete pods --field-selector=status.phase=Failed

# Restart all pods of a Deployment
kubectl rollout restart deployment/<name>

# Run a temporary debug Pod
kubectl run debug --rm -it --image=busybox -- sh

# Get events (all namespaces)
kubectl get events -A --sort-by='.lastTimestamp'
```

---

## 19. Where to go next

- Course material in this repo: [Introduction to Kubernetes](introduction-to-kubernetes/README.md), [Cloud Native Essentials](cloud-native-essentials/README.md).
- Official docs: [kubernetes.io/docs](https://kubernetes.io/docs/).
- Interactive tutorials: [kubernetes.io/docs/tutorials](https://kubernetes.io/docs/tutorials/).
