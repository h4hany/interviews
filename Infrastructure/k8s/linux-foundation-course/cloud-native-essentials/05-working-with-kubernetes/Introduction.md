# Introduction

# Chapter Overview

In this chapter, you will learn about the core Kubernetes objects, their roles within a cluster, and how to interact with them effectively.

Once a cluster is set up—either newly created or pre-existing—you can begin deploying workloads. It’s important to note that the smallest compute unit in Kubernetes is not a container, but a Pod. However, Pods are only one part of the workload model. Kubernetes provides several workload objects that determine how Pods are created, scaled, updated, and managed throughout their lifecycle.

Deploying workloads is only one aspect of working with Kubernetes. The platform also provides solutions to operational challenges arising from running containers at scale, including configuration management, cross-node networking, external traffic routing, load balancing, and automated Pod scaling.