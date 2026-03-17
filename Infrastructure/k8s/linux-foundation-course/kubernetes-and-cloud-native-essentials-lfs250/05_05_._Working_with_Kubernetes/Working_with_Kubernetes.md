# Working with Kubernetes

# Kubernetes Objects

One of Kubernetes’ core principles is that it represents system behavior through a collection of abstract resources—called objects—that define how workloads should run and be managed. Some objects focus on orchestration tasks such as scheduling, scaling, and self-healing, while others address fundamental container concerns like configuration, networking, and security.

Kubernetes objects generally fall into two categories: workload objects, which define and manage containerized applications, and infrastructure objects, which provide supporting functionality such as networking, access control, and configuration management. Many objects are scoped to a specific namespace, while others exist at the cluster level and apply globally.

Users define these objects using YAML, a common data serialization format, and submit them to the Kubernetes API server, where the definitions are validated and then used to create or modify resources in the cluster.

**apiVersion: apps/v1  
kind: Deployment   
metadata:   
name: nginx-deployment   
spec:   
****selector:  
matchLabels:   
app: nginx   
replicas: 2 # tells deployment to run 2 pods matching the template   
template:   
metadata:   
labels:   
app: nginx   
spec:   
containers:   
\- name: nginx   
image: nginx:1.29   
ports:   
\- containerPort: 80**

The fields highlighted in red are required fields. They include:

  * **apiVersion**  
Specifies which version of the object’s schema is being used. The structure of an object can change between versions, so this field determines how Kubernetes interprets it.
  * **kind**  
Defines the type of Kubernetes object you want to create.
  * **metadata**  
Contains identifying information, such as the object’s name. Each object must have a unique name within its scope; namespaces allow objects with the same name to coexist in different logical groups.
  * **spec**  
Describes the desired state of the object. The structure of this field depends on the object type and may vary across versions, so be careful to match it with the correct **apiVersion**.



It's important to understand that creating, updating, or deleting an object in Kubernetes expresses intent—you’re declaring the state you want, not manually starting containers like you would on a local machine. Kubernetes evaluates that desired state and works to reconcile the system so that it matches what you’ve defined.