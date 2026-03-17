# Kubernetes Building Blocks

# Kubernetes Object Model

Kubernetes became popular due to its advanced application lifecycle management capabilities, implemented through a rich object model, representing different persistent entities in the Kubernetes cluster. Those entities describe:

  * What containerized applications we are running.
  * The nodes where the containerized applications are deployed.
  * Application resource consumption.
  * Policies attached to applications, like restart/upgrade policies, fault tolerance, ingress/egress, access control, etc.



With each object, we declare our intent, or the desired state of the object, in the **spec** section. The Kubernetes system manages the **status** section for objects, where it records the actual state of the object. At any given point in time, the Kubernetes Control Plane tries to match the object's actual state to the object's desired state. An object definition manifest must include other fields that specify the version of the API we are referencing as the **apiVersion** , the object type as **kind** , and additional data helpful to the cluster or users for accounting purposes - the **metadata**. In certain object definitions, however, we find different sections that replace **spec** , they are **data** and **stringData**. Both **data** and **stringData** sections facilitate the declaration of information that should be stored by their respective objects.

Examples of Kubernetes object types are Nodes, Namespaces, Pods, ReplicaSets Deployments, DaemonSets, etc. We will explore them next.

When creating an object, the object's configuration data section from below the **spec** field has to be submitted to the Kubernetes API Server. The API request to create an object must have the **spec** section, describing the desired state, as well as other details. Although the API Server accepts object definitions in a JSON format, most often we provide such definition manifests in a YAML format which is converted by **kubectl** in a JSON payload and sent to the API Server.