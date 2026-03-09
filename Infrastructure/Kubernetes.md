# Kubernetes Interview Questions

## 1. What is Kubernetes?

**Answer:**
Kubernetes (K8s) is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

## 2. What are the main components of Kubernetes?

**Answer:**
- **Control Plane**: Manages the cluster (API Server, etcd, Scheduler, Controller Manager)
- **Nodes**: Worker machines that run containers (Kubelet, Kube-proxy, Container Runtime)
- **Pods**: Smallest deployable units containing one or more containers
- **Services**: Network abstraction for pods
- **Deployments**: Manages replica sets and rolling updates

## 3. What is a Pod in Kubernetes?

**Answer:**
A Pod is the smallest deployable unit in Kubernetes. It contains one or more containers that share storage, network, and specifications.

## 4. What is the difference between a Pod and a Container?

**Answer:**
- **Container**: A running instance of an image.
- **Pod**: A Kubernetes abstraction that wraps one or more containers, providing shared networking and storage.

## 5. What is a Deployment in Kubernetes?

**Answer:**
A Deployment manages a set of replica Pods and provides declarative updates, rolling updates, and rollback capabilities.

### Example:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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
        image: nginx:1.21
        ports:
        - containerPort: 80
```

## 6. What is a Service in Kubernetes?

**Answer:**
A Service provides a stable network endpoint to access a set of Pods. It abstracts Pod IP addresses and provides load balancing.

### Example:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

## 7. What are the different types of Services in Kubernetes?

**Answer:**
- **ClusterIP**: Default, internal cluster access only
- **NodePort**: Exposes service on each node's IP at a static port
- **LoadBalancer**: Creates external load balancer (cloud provider)
- **ExternalName**: Maps service to external DNS name

## 8. What is a Namespace in Kubernetes?

**Answer:**
A Namespace provides logical separation and resource isolation within a cluster. It's useful for organizing resources and access control.

## 9. What is the difference between `kubectl apply` and `kubectl create`?

**Answer:**
- **`kubectl create`**: Creates new resources (fails if resource exists).
- **`kubectl apply`**: Creates or updates resources (declarative, idempotent).

## 10. What is a ConfigMap in Kubernetes?

**Answer:**
A ConfigMap stores non-confidential configuration data as key-value pairs. Pods can consume ConfigMaps as environment variables or files.

### Example:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://localhost:5432/mydb"
  log_level: "info"
```

## 11. What is a Secret in Kubernetes?

**Answer:**
A Secret stores sensitive data like passwords, tokens, or keys. Similar to ConfigMap but encoded in base64.

### Example:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=
  password: cGFzc3dvcmQ=
```

## 12. What is a PersistentVolume (PV) and PersistentVolumeClaim (PVC)?

**Answer:**
- **PersistentVolume**: Cluster-wide storage resource provisioned by admin.
- **PersistentVolumeClaim**: User's request for storage, binds to a PV.

## 13. What is a StatefulSet in Kubernetes?

**Answer:**
A StatefulSet manages stateful applications with stable network identities and persistent storage. Pods have unique identities.

## 14. What is the difference between Deployment and StatefulSet?

**Answer:**
- **Deployment**: For stateless applications, pods are interchangeable.
- **StatefulSet**: For stateful applications, pods have stable identities and ordered deployment.

## 15. What is a DaemonSet in Kubernetes?

**Answer:**
A DaemonSet ensures all (or specific) nodes run a copy of a Pod. Useful for system services like logging or monitoring.

## 16. What is a Job in Kubernetes?

**Answer:**
A Job creates one or more Pods and ensures they complete successfully. Used for batch processing or one-time tasks.

## 17. What is a CronJob in Kubernetes?

**Answer:**
A CronJob creates Jobs on a time-based schedule, similar to Unix cron.

### Example:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-image
          restartPolicy: OnFailure
```

## 18. What is a ReplicaSet in Kubernetes?

**Answer:**
A ReplicaSet ensures a specified number of Pod replicas are running. Deployments manage ReplicaSets.

## 19. What is the difference between `kubectl get` and `kubectl describe`?

**Answer:**
- **`kubectl get`**: Lists resources in a table format.
- **`kubectl describe`**: Shows detailed information about a resource.

## 20. What is Horizontal Pod Autoscaler (HPA)?

**Answer:**
HPA automatically scales the number of Pods based on CPU utilization or custom metrics.

### Example:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 21. What is a Ingress in Kubernetes?

**Answer:**
An Ingress manages external HTTP/HTTPS access to services, providing load balancing, SSL termination, and name-based virtual hosting.

## 22. What is the difference between Ingress and LoadBalancer?

**Answer:**
- **LoadBalancer**: Creates external load balancer per service (expensive).
- **Ingress**: Single entry point for multiple services, more flexible routing.

## 23. What is a Liveness Probe?

**Answer:**
A Liveness Probe checks if a container is running. If it fails, Kubernetes restarts the container.

### Example:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
```

## 24. What is a Readiness Probe?

**Answer:**
A Readiness Probe checks if a container is ready to accept traffic. If it fails, the Pod is removed from service endpoints.

## 25. What is the difference between Liveness and Readiness Probes?

**Answer:**
- **Liveness Probe**: Determines if container should be restarted.
- **Readiness Probe**: Determines if container can receive traffic.

## 26. What is a Resource Quota?

**Answer:**
A Resource Quota limits the total amount of resources (CPU, memory, storage) that can be consumed in a namespace.

## 27. What is a LimitRange?

**Answer:**
A LimitRange sets default, min, and max resource limits for containers in a namespace.

## 28. What is the difference between `kubectl port-forward` and Service?

**Answer:**
- **`kubectl port-forward`**: Temporary port forwarding for debugging (local access).
- **Service**: Permanent network endpoint for Pods (cluster-wide access).

## 29. What is etcd in Kubernetes?

**Answer:**
etcd is a distributed key-value store that stores all cluster data, configuration, and state. It's the "source of truth" for the cluster.

## 30. What is the Kubelet?

**Answer:**
The Kubelet is an agent that runs on each node and ensures containers are running in Pods. It communicates with the API server.

## 31. What is Kube-proxy?

**Answer:**
Kube-proxy maintains network rules on nodes, enabling Service abstraction and load balancing.

## 32. What is the API Server?

**Answer:**
The API Server is the front-end for the Kubernetes control plane. It validates and processes REST requests, updates etcd, and serves as the communication hub.

## 33. What is the Scheduler?

**Answer:**
The Scheduler assigns Pods to nodes based on resource requirements, constraints, and policies.

## 34. What is a Rolling Update?

**Answer:**
A Rolling Update gradually replaces old Pods with new ones, ensuring zero downtime during updates.

## 35. What is the difference between `kubectl exec` and `kubectl attach`?

**Answer:**
- **`kubectl exec`**: Executes a command in a running container.
- **`kubectl attach`**: Attaches to a running process's stdin/stdout.

## 36. What is a Headless Service?

**Answer:**
A Headless Service (clusterIP: None) doesn't provide load balancing. It's used for StatefulSets where each Pod needs a stable network identity.

## 37. What is a Node Selector?

**Answer:**
A Node Selector constrains Pods to run on specific nodes based on node labels.

## 38. What is an Affinity in Kubernetes?

**Answer:**
Affinity rules allow more complex Pod placement than Node Selector, including preferred/required rules and pod-to-pod affinity.

## 39. What is a Taint and Toleration?

**Answer:**
- **Taint**: Prevents Pods from being scheduled on a node.
- **Toleration**: Allows a Pod to be scheduled on a tainted node.

## 40. What is a Network Policy?

**Answer:**
A Network Policy controls traffic flow between Pods, providing network-level security and isolation.

## 41. What is the difference between `kubectl delete` and `kubectl scale --replicas=0`?

**Answer:**
- **`kubectl delete`**: Removes the resource entirely.
- **`kubectl scale --replicas=0`**: Scales down to zero Pods but keeps the Deployment.

## 42. What is a Custom Resource Definition (CRD)?

**Answer:**
A CRD extends Kubernetes API to add custom resources and controllers, enabling custom functionality.

## 43. What is an Operator in Kubernetes?

**Answer:**
An Operator is a method of packaging, deploying, and managing a Kubernetes application using custom resources and controllers.

## 44. What is Helm?

**Answer:**
Helm is a package manager for Kubernetes that simplifies application deployment using charts (packages of pre-configured resources).

## 45. What is the difference between `kubectl logs` and `kubectl logs -f`?

**Answer:**
- **`kubectl logs`**: Shows logs and exits.
- **`kubectl logs -f`**: Follows logs (streams in real-time).

## 46. What is a Pod Disruption Budget (PDB)?

**Answer:**
A PDB limits the number of Pods that can be voluntarily disrupted during maintenance, ensuring availability.

## 47. What is the difference between `kubectl rollout restart` and `kubectl rollout undo`?

**Answer:**
- **`kubectl rollout restart`**: Restarts all Pods in a Deployment.
- **`kubectl rollout undo`**: Rolls back to the previous revision.

## 48. What is a Service Account?

**Answer:**
A Service Account provides an identity for Pods to authenticate with the Kubernetes API and other services.

## 49. What is RBAC in Kubernetes?

**Answer:**
RBAC (Role-Based Access Control) controls access to Kubernetes resources through Roles, RoleBindings, ClusterRoles, and ClusterRoleBindings.

## 50. What is a Volume in Kubernetes?

**Answer:**
A Volume provides storage to Pods. Types include emptyDir, hostPath, persistentVolumeClaim, configMap, and secret.

