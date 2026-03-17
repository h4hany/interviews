# Authentication, Authorization, Admission Control

# Authentication, Authorization, and Admission Control - Overview

To access and manage Kubernetes resources or objects in the cluster, we need to access a specific API endpoint on the API server. Each access request goes through the following access control stages:

  * **Authentication**  
Authenticate a user based on credentials provided as part of API requests.
  * **Authorization**  
Authorizes the API requests submitted by the authenticated user.
  * **Admission Control**  
Software modules that validate and/or modify user requests.



The following image depicts the above stages:

![Controlling Access to the API](https://d36ai2hkxl16us.cloudfront.net/course-uploads/e0df7fbf-a057-42af-8a1f-590912be5460/9qc8l9vt06dc-ControllingAccesstotheAPI.png)

**Controlling Access to the API  
**(Retrieved from [kubernetes.io](https://kubernetes.io/docs/concepts/security/controlling-access/))