# Introduction

# Chapter Overview

While deploying an application, we may need to pass such runtime parameters like configuration details, permissions, passwords, keys, certificates, or tokens.

Let's assume we need to deploy ten different applications for our customers, and for each customer, we need to display the name of the company in the UI. Then, instead of creating ten different container images for each customer, we may just use the same template image and pass customers' names as runtime parameters. In such cases, we can use the ConfigMap API resource.

Similarly, when we want to pass sensitive information, we can use the Secret API resource. In this chapter, we will explore ConfigMaps and Secrets.