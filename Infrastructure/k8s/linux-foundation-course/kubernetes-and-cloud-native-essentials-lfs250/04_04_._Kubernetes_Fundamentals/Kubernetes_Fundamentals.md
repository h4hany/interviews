# Kubernetes Fundamentals

# Kubernetes Architecture

Kubernetes is typically deployed as a cluster, meaning it runs across multiple servers that share workloads, improve reliability, and scale applications efficiently. This design reflects Google’s original requirements, where billions of containers are started each week. Thanks to its strong horizontal scalability, Kubernetes can support clusters with thousands of nodes spread across data centers and even regions.

From a high-level perspective, Kubernetes clusters consist of two different server node types that make up a cluster:

  * **Control plane node(s)**  
These nodes act as the “brains” of the cluster. They run components that manage the overall system, including workload scheduling, deployments, and self-healing behaviors.
  * **Worker nodes**  
Worker nodes are responsible for running applications—nothing more. They do not make decisions on their own; instead, they follow instructions from the control plane, such as when to start or stop containers.



![Diagram of a Kubernetes cluster showing control plane components \(API server, etcd, controller manager, scheduler\) and worker nodes running kubelet, containerd, and kube-proxy with containers.](https://media.thoughtindustries.com/course-uploads/e0df7fbf-a057-42af-8a1f-590912be5460/gk8f9crkgwju-k8sarchitecture2.png)This diagram illustrates the core architecture of a Kubernetes cluster. The control plane manages the overall state of the cluster, while worker nodes run containers through components like kubelet, containerd, and kube-proxy. Together, these elements coordinate scheduling, networking, and the execution of workloads.

**Kubernetes architecture**

Similar to a microservice architecture you would choose for your own application, Kubernetes incorporates multiple smaller services that need to be installed on the nodes.