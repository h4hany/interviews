# Ingress

# Ingress (1)

With Services, routing rules are associated with a given Service. They exist for as long as the Service exists, and there are many rules because there are many Services in the cluster. If we can somehow decouple the routing rules from the application and centralize the rules management, we can then update our application without worrying about its external access. This can be done using the _Ingress_ resource - a collection of rules that manage inbound connections to cluster Services.

To allow the inbound connection to reach the cluster Services, Ingress configures a Layer 7 HTTP/HTTPS load balancer for Services and provides the following:

  * TLS (Transport Layer Security)
  * Name-based virtual hosting
  * Fanout routing
  * Loadbalancing
  * Custom rules.



![Ingress](https://d36ai2hkxl16us.cloudfront.net/course-uploads/e0df7fbf-a057-42af-8a1f-590912be5460/ssd5q8n8k3nt-Ingress2023.png)

**Ingress**

With Ingress, users do not connect directly to a Service. Users reach the Ingress endpoint, and, from there, the request is forwarded to the desired Service. You can see an example of a _[Name-Based Virtual Hosting](https://kubernetes.io/docs/concepts/services-networking/ingress/#name-based-virtual-hosting) Ingress_ definition below:

**apiVersion: networking.k8s.io/v1  
kind: Ingress   
metadata:**  
******annotations:**  
**nginx.ingress.kubernetes.io/service-upstream: "true"**  
**name: virtual-host-ingress  
namespace: default   
spec:  
ingressClassName: nginx  
rules:   
\- host: blue.example.com   
http:   
paths:   
\- backend:   
service:   
name: webserver-blue-svc   
port:   
number: 80   
path: /   
pathType: ImplementationSpecific   
\- host: green.example.com   
http:   
paths:   
\- backend:   
service:   
name: webserver-green-svc   
port:   
number: 80   
path: /   
pathType: ImplementationSpecific**

In the example above, user requests to both **blue.example.com** and **green.example.com** would go to the same Ingress endpoint, and, from there, they would be forwarded to **webserver-blue-svc** , and **webserver-green-svc** , respectively.

_Cont’d on the next page._