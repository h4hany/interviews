# Kubernetes and Cloud Native Associate (KCNA) Study Plan

This study plan is designed to guide you through the Kubernetes African Developer Training Program, preparing you for the KCNA certification exam. It incorporates the structure of the LFS250: Kubernetes and Cloud Native Essentials course and aligns with the official KCNA exam curriculum.

## Program Structure Overview

The Kubernetes African Developer Training Program follows these key steps:

1.  **Complete the readiness form:** Confirm your interest and eligibility to receive your course voucher.
2.  **Receive your LFS250 course voucher:** Get access to the LFS250: Kubernetes and Cloud Native Essentials course.
3.  **Complete the LFS250 course:** Study the foundational concepts at your own pace, aiming to complete by the end of July.
4.  **Receive your KCNA Exam Voucher:** Vouchers are distributed weekly, starting in April, after course completion.
5.  **Take the KCNA Exam:** Prepare thoroughly, as you have only one attempt to pass.

## KCNA Exam Domains and Weightage

The KCNA exam is structured around five key domains, each contributing a specific percentage to the overall score [1]:

| Domain                               | Weightage |
| :----------------------------------- | :-------- |
| Kubernetes Fundamentals              | 44%       |
| Container Orchestration              | 28%       |
| Cloud Native Application Delivery    | 16%       |
| Cloud Native Architecture            | 12%       |

## Study Plan Outline

This study plan is divided into sections corresponding to the KCNA exam domains, integrating the LFS250 course content. Each section will include a summary, recommended resources, and mock assessment questions.

### Section 1: Kubernetes Fundamentals (44%)

**Summary:** This section covers the core concepts of Kubernetes, including its architecture, components, and basic operations. It will delve into topics such as pods, deployments, services, and namespaces, providing a strong foundation for understanding how Kubernetes manages containerized applications. This aligns with LFS250 Chapters 1, 4, and 5.

### Section 2: Container Orchestration (28%)

**Summary:** This section focuses on the principles and practices of container orchestration, with a specific emphasis on Kubernetes' role in managing the lifecycle of containers. Topics will include networking within Kubernetes, storage solutions, security best practices, and troubleshooting common issues. This aligns with LFS250 Chapter 3.

### Section 3: Cloud Native Application Delivery (16%)

**Summary:** This section explores how applications are delivered and managed in a cloud-native environment using Kubernetes. It will cover deployment strategies, application updates, and debugging techniques specific to containerized applications orchestrated by Kubernetes. This aligns with LFS250 Chapter 6.

### Section 4: Cloud Native Architecture (12%)

**Summary:** This section provides an overview of cloud-native architectural principles and the broader ecosystem surrounding Kubernetes. It will cover concepts like observability, the cloud-native landscape, and community collaboration. This aligns with LFS250 Chapter 2 and 7.

## References

[1] Kubernetes and Cloud Native Associate (KCNA) - Linux Foundation. (n.d.). Retrieved from https://training.linuxfoundation.org/certification/kubernetes-cloud-native-associate/

### Section 1: Kubernetes Fundamentals (44%)

**Summary:** This section covers the core concepts of Kubernetes, including its architecture, components, and basic operations. It will delve into topics such as pods, deployments, services, and namespaces, providing a strong foundation for understanding how Kubernetes manages containerized applications. This aligns with LFS250 Chapters 1, 4, and 5.

**Key Topics:**

*   **Kubernetes Overview:** What is Kubernetes, its purpose, and its role in managing containerized workloads [1].
*   **Cluster Architecture:** Understanding the components of a Kubernetes cluster, including the Control Plane (kube-apiserver, etcd, kube-scheduler, kube-controller-manager, cloud-controller-manager) and Worker Nodes (kubelet, kube-proxy, container runtime) [2].
*   **Pods:** The smallest deployable units in Kubernetes, encapsulating one or more containers, storage, and network resources [3].
*   **Workloads:** Managing applications using higher-level abstractions like Deployments (for stateless applications), StatefulSets (for stateful applications), DaemonSets (for node-local services), Jobs (for one-off tasks), and CronJobs (for scheduled tasks) [3].
*   **Services, Load Balancing, and Networking:** How applications communicate within and outside the cluster, including the Kubernetes network model, Services, Ingress, Network Policies, and DNS [4].
*   **Storage:** Providing persistent and temporary storage to Pods using Volumes, Persistent Volumes, Storage Classes, and Dynamic Volume Provisioning [5].

**Resources:**

*   [Kubernetes Concepts - Official Documentation](https://kubernetes.io/docs/concepts/) [1]
*   [Kubernetes Cluster Architecture - Official Documentation](https://kubernetes.io/docs/concepts/architecture/) [2]
*   [Kubernetes Workloads - Official Documentation](https://kubernetes.io/docs/concepts/workloads/) [3]
*   [Kubernetes Services, Load Balancing, and Networking - Official Documentation](https://kubernetes.io/docs/concepts/services-networking/) [4]
*   [Kubernetes Storage - Official Documentation](https://kubernetes.io/docs/concepts/storage/) [5]

**Mock Assessment - Kubernetes Fundamentals:**

1.  What is the primary function of the `kube-apiserver` in a Kubernetes cluster?
2.  Explain the difference between a Pod and a Deployment.
3.  How do Pods communicate with each other within the same Node and across different Nodes?
4.  Describe the purpose of a PersistentVolume (PV) and a PersistentVolumeClaim (PVC).
5.  Which Kubernetes component is responsible for assigning Pods to Nodes?


### Section 2: Container Orchestration (28%)

**Summary:** This section focuses on the principles and practices of container orchestration, with a specific emphasis on Kubernetes' role in managing the lifecycle of containers. Topics will include networking within Kubernetes, storage solutions, security best practices, and troubleshooting common issues. This aligns with LFS250 Chapter 3.

**Key Topics:**

*   **Container Runtime Interface (CRI):** Understanding how Kubernetes interacts with container runtimes like containerd or CRI-O.
*   **Networking Model:** In-depth look at the Kubernetes networking model, including Pod-to-Pod communication, Service networking, DNS, and Network Policies [4].
*   **Storage Management:** Advanced concepts of storage, including different types of volumes, PersistentVolumes, PersistentVolumeClaims, StorageClasses, and dynamic provisioning [5].
*   **Security:** Best practices for securing Kubernetes clusters, including RBAC, network segmentation, image security, and API server access control [6].
*   **Troubleshooting:** Common issues in Kubernetes and strategies for diagnosing and resolving them, utilizing `kubectl` commands and logs [7].

**Resources:**

*   [Kubernetes Services, Load Balancing, and Networking - Official Documentation](https://kubernetes.io/docs/concepts/services-networking/) [4]
*   [Kubernetes Storage - Official Documentation](https://kubernetes.io/docs/concepts/storage/) [5]
*   [Securing a Cluster | Kubernetes - Official Documentation](https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/) [6]
*   [Troubleshooting Clusters | Kubernetes - Official Documentation](https://kubernetes.io/docs/tasks/debug/debug-cluster/) [7]

**Mock Assessment - Container Orchestration:**

1.  How does Kubernetes ensure communication between Pods on different nodes?
2.  What is the role of Network Policies in Kubernetes, and how are they applied?
3.  Explain the concept of a StorageClass and its benefits.
4.  List three best practices for securing a Kubernetes cluster.
5.  Which `kubectl` commands would you use to diagnose why a Pod is not starting?


### Section 3: Cloud Native Application Delivery (16%)

**Summary:** This section explores how applications are delivered and managed in a cloud-native environment using Kubernetes. It will cover deployment strategies, application updates, and debugging techniques specific to containerized applications orchestrated by Kubernetes. This aligns with LFS250 Chapter 6.

**Key Topics:**

*   **Deployment Strategies:** Understanding various deployment strategies such as Rolling Updates, Blue/Green Deployments, and Canary Deployments, and their use cases [8].
*   **Application Updates and Rollbacks:** Managing application versions, performing updates, and rolling back to previous stable versions using Kubernetes Deployments [8].
*   **Debugging Applications:** Techniques and tools for troubleshooting issues within running applications in Kubernetes, including inspecting logs, events, and using `kubectl` commands for debugging Pods [9].
*   **CI/CD Integration:** Overview of how Continuous Integration and Continuous Delivery (CI/CD) pipelines integrate with Kubernetes for automated application delivery.

**Resources:**

*   [Deployments | Kubernetes - Official Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) [8]
*   [Monitoring, Logging, and Debugging | Kubernetes - Official Documentation](https://kubernetes.io/docs/tasks/debug/) [9]
*   [8 Kubernetes Deployment Strategies: Pros, Cons & Use Cases](https://www.groundcover.com/blog/kubernetes-deployment-strategies)

**Mock Assessment - Cloud Native Application Delivery:**

1.  Describe the Rolling Update deployment strategy and its advantages.
2.  How would you roll back a Kubernetes Deployment to a previous revision?
3.  What are the key steps to debug a Pod that is continuously crashing?
4.  Explain the concept of a Canary Deployment.
5.  How does Kubernetes facilitate automated application delivery in a CI/CD pipeline?


### Section 4: Cloud Native Architecture (12%)

**Summary:** This section provides an overview of cloud-native architectural principles and the broader ecosystem surrounding Kubernetes. It will cover concepts like observability, the cloud-native landscape, and community collaboration. This aligns with LFS250 Chapter 2 and 7.

**Key Topics:**

*   **Cloud Native Principles:** Understanding the core tenets of cloud-native development, such as microservices, immutability, declarative APIs, and automation [10].
*   **Observability:** The importance of monitoring, logging, and tracing in cloud-native environments to understand system behavior and troubleshoot issues effectively [11].
*   **Cloud Native Ecosystem (CNCF Landscape):** Familiarity with key projects and technologies within the Cloud Native Computing Foundation (CNCF) landscape, including prominent tools beyond Kubernetes [12].
*   **Community and Collaboration:** The role of open-source communities in the development and adoption of cloud-native technologies.

**Resources:**

*   [Cloud Native Principles](https://networking.cloud-native-principles.org/cloud-native-principles) [10]
*   [Observability | Kubernetes - Official Documentation](https://kubernetes.io/docs/concepts/cluster-administration/observability/) [11]
*   [Cloud Native Computing Foundation (CNCF)](https://www.cncf.io/) [12]

**Mock Assessment - Cloud Native Architecture:**

1.  What are the key characteristics of a cloud-native application?
2.  Explain the three pillars of observability in a cloud-native context.
3.  Name three projects or technologies from the CNCF landscape other than Kubernetes.
4.  How does the cloud-native approach differ from traditional application development?
5.  Why is community collaboration important in the cloud-native ecosystem?

