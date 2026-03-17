# Introduction

# Chapter Overview

In an earlier chapter, we saw how we can access our deployed containerized application from the external world via _Services_. Among the _ServiceTypes_ the NodePort and LoadBalancer are the most often used. For the LoadBalancer _ServiceType_ , we need to have support from the underlying infrastructure. Even after having the support, we may not want to use it for every Service, as LoadBalancer resources are limited and they can increase costs significantly. Managing the NodePort _ServiceType_ can also be tricky at times, as we need to keep updating our proxy settings and keep track of the assigned ports.

In this chapter, we will explore the [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) API resource, which represents another layer of abstraction, deployed in front of the _Service_ API resources, offering a unified method of managing access to our applications from the external world.