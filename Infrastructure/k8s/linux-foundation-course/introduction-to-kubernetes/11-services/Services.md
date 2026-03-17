# Services

# Accessing Application Pods

To access the application, a user or another application needs to connect to a Pod running the target application. As Pods are ephemeral in nature, resources like IP addresses allocated to them cannot be static. Pods could be terminated abruptly or be rescheduled based on existing requirements.

Let's take, for example, a scenario where an operator manages a set of Pods and a user/client is accessing the Pods directly by using their individual IP addresses. This access method requires the client to retrieve the target Pods’ IP addresses in advance, introducing an unnecessary overhead for the client.

![A Scenario Where a User Is Accessing Pods via their IP Addresses](https://d36ai2hkxl16us.cloudfront.net/course-uploads/e0df7fbf-a057-42af-8a1f-590912be5460/kyy1eh5no6ln-1.AScenarioWhereaUserIsAccessingPodsviatheirIPAddresses.png)

**A Scenario Where a User Is Accessing Pods via their IP Addresses**

Unexpectedly, one of the Pods the user/client is accessing is terminated, and a new Pod is created by the controller. The new Pod will be assigned a new IP address that will not be immediately known by the user/client. If the client tries to watch the target Pods’ IP addresses for any changes and updates, this will result in an inefficient approach that will only increase the client’s overhead.

![A New Pod Is Created After an Old One Terminated Unexpectedly](https://d36ai2hkxl16us.cloudfront.net/course-uploads/e0df7fbf-a057-42af-8a1f-590912be5460/pwbpa4aswxia-2.ANewPodIsCreatedAfteranOldOneTerminatedUnexpectedly.png)

**A New Pod Is Created After an Old One Terminated Unexpectedly**

To overcome this situation, Kubernetes provides a higher-level abstraction called _Service_ , which logically groups Pods and defines a policy to access them. This grouping is achieved via _Labels_ and _Selectors_. This logical grouping strategy is used by Pod controllers, such as ReplicaSets, Deployments, and even DaemonSets. Below is a Deployment definition manifest for the **frontend** app, to aid with the correlation of Labels, Selectors, and port values between the Deployment controller, its Pod replicas, and the Service definition manifest presented in an upcoming section.

**apiVersion: apps/v1  
kind: Deployment   
metadata:   
labels:   
app: frontend   
name: frontend   
spec:   
replicas: 3   
selector:   
matchLabels:   
app: frontend   
template:   
metadata:   
labels:   
app: frontend   
spec:   
containers:   
\- image: frontend-application   
name: frontend-application   
ports:   
\- containerPort: 5000 **