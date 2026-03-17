# Deploying a Standalone Application

# Deploying an Application Using the Dashboard (1)

Let's learn how to deploy an **nginx** webserver using the **nginx** container image from [_Docker Hub_](https://hub.docker.com/).

Start Minikube and verify that it is running. Run this command first:

**$ minikube start**

Then verify Minikube status:

**$ minikube status**

**minikube**  
**type: Control Plane**  
**host: Running**  
**kubelet: Running**  
**apiserver: Running**  
**kubeconfig: Configured**

Start the Minikube Dashboard. To access the Kubernetes Web IU, we need to run the following command:

**$ minikube dashboard**

Running this command will open up a browser with the Kubernetes Web UI, which we can use to manage containerized applications. By default, the dashboard is connected to the **default** Namespace. Therefore, all the operations will be performed inside the **default** Namespace.

![Deploying an Application - Accessing the Dashboard](https://d36ai2hkxl16us.cloudfront.net/course-uploads/e0df7fbf-a057-42af-8a1f-590912be5460/9v8hhlbsi5zl-DeployinganApplication-AccessingtheDashboard.png)

**Deploying an Application - Accessing the Dashboard**

_**NOTE** : In case the browser is not opening another tab and does not display the Dashboard as expected, verify the output in your terminal as it may display a link for the Dashboard (together with some Error messages). Copy and paste that link in a new tab of your browser. Depending on your terminal's features you may be able to just click or right-click the link to open directly in the browser. _

The link may look similar to:

[http://127.0.0.1:40235/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://127.0.0.1:40235/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

Chances are that the only difference is the PORT number, which above is 40235. Your port number may be different.

After a logout/login or a reboot of your workstation the expected behavior may be observed (where the **minikube dashboard** command directly opens a new tab in your browser displaying the Dashboard).

_Cont’d on the next page._