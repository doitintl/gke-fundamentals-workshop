# GKE Workshop LAB-01 (C)

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will set up our local development environment, provision the workshop cluster and roll out our next workload: the NGINX Operator. After learning about the controller fundamentals and the differences between con- trollers and operators, we are ready to implement an operator! The sample operator will solve a real-life task: managing a suite of NGINX servers with preconfigured static content. The operator will allow the user to specify a list of NGINX servers and config- ure static files mounted on each server. The task is not trivial and demonstrates the flexibility and power of Kubernetes.

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or MacOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

_please ensure that you are using the latest version of kubectl for this tutorial (version 1.16 or later). The --output-watch-events option was added relatively recently._

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://kubernetes.io/docs/tasks/tools/) tutorial

## Cluster Preparation

The preparation of the GKE cluster is one of the first steps of our workshop and is the basis for all our further activity using the local development environment of all participants. We will pave the way to our first K8s application deployment step by step in the following section, learning some of the basics of using the gcloud SDK CLI and kubectl.

## GCloud SDK Preparation

```bash
gcloud init
gcloud config set compute/zone europe-west1-b
```

## Cluster Provisioning

The present gcloud command call initializes the workshop in a configuration that is as compatible as possible for all upcoming labs.

_If you have already initialized the cluster, you can skip this step!_

```bash
gcloud container clusters create workshop \
--machine-type n1-standard-4 \
--node-locations europe-west1-b,europe-west1-c,europe-west1-d \
--num-nodes "1" \
--release-channel stable \
--region europe-west1 \
--image-type "ubuntu" \
--disk-type "pd-ssd" \
--disk-size "120" \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--network "default" \
--scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform" \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS \
--labels k8s-scope=kubernetes-workshop-doit,k8s-cluster=primary,environment=workshop && \
kubectl cluster-info && \
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account) && \
gcloud container clusters get-credentials workshop
```

## Workload Description

### Design

As mentioned earlier in this chapter, Kubernetes’ architecture allows you to leverage an existing controller’s functionality through delegation. Our NGINX controller is going to leverage Deployment resources to delegate the NGINX deployment task.
The next question is which resource should be used to configure the list of servers and customized static content. The most appropriate existing resource is the Config- Map. According to the official Kubernetes documentation, the ConfigMap is “an API object used to store non-confidential data in key-value pairs.”7 The ConfigMap can be consumed as environment variables, command-line arguments, or config files in a Vol- ume. The controller will create a Deployment for each ConfigMap and mount the ConfigMap data into the default NGINX static website directory.

### Implementation

Once we’ve decided on the design of the main building blocks, it is time to write some code. Most Kubernetes-related projects, including Kubernetes itself, are implemented using Go. However, Kubernetes controllers can be implemented using any language, including Java, C++, or even JavaScript. For the sake of simplicity, we are going to use a language that is most likely familiar to you: the Bash scripting language. We mentioned that each controller maintains an infinite loop and continuously reconciles the desired and actual state. In our example, the desired state is represented by the list of ConfigMaps. The most efficient way to loop through every ConfigMap change is using the Kubernetes watch API. The watch feature is provided by the Kubernetes API for most resource types and allows the caller to be notified when a resource is created, modified, or deleted. The kubectl utility allows watching for resource changes using the get command with the --watch flag. The --output- watch-events command instructs kubectl to output the change type, which takes one of the following values: ADDED, MODIFIED, or DELETED.

## Workload Provisioning

Make sure you handled all previous steps of this README before starting this section of our lab!

1. In one terminal, run the following command:

   ```bash
   ./nginx-controller.sh
   ```

2. In another terminal window, run:

   ```bash
   kubectl apply -f nginx-config-map.yaml
   ```

3. To remove resources completely, run:
   ```bash
    kubectl delete -f nginx-config-map.yaml
   ```

you can always make changes to the nginx delivery content by adjusting the key 'index.html: your-string-here' and confirming the change to the `nginx-config-map.yaml` file accordingly with `kubectl apply`.

## Additional (Optional) Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-01-c` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-01-c
```

## Application Clean-Up

- run `kubectl delete -f nginx-config-map.yaml`
- after that perform a IPC termination of nginx-controller.sh process (CTRL+c)

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

## Copyright

Copyright © 2021 DoiT International
