# GKE Workshop LAB-07

## Workload Identity example with Pub/Sub

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)
[![elasticSearch Version](https://img.shields.io/badge/elasticsearch%20version-6.2.4-green.svg)](#)
[![Build Status](https://img.shields.io/badge/status-unstable-E47911.svg)](#)

## Introduction

In the following lab we will set up our local development environment, provision the workshop GKE cluster with [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) enabled, then run a Deployment and all necessary plumbing for it to communicate to a GCP service using Workload Identity. This lab will give insight into the recommended method of authenticating workloads running within GKE to other GCP services using IAM permissions.

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or MacOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://kubernetes.io/docs/tasks/tools/) tutorial

## Cluster Preparation

The preparation of the GKE cluster is one of the first steps of our workshop and is the basis for all our further activity using the local development environment of all participants. We will pave the way to our first K8s application deployment step by step in the following section, learning some of the basics of using the gcloud SDK CLI and kubectl.

## GCloud SDK Preparation
```bash
gcloud init ;
gcloud config set compute/zone europe-west1-b ;
```

## Cluster Provisioning

The present gcloud command call initializes the workshop in a configuration that is as compatible as possible for all upcoming labs. If you have already initialized the cluster, you can skip this step!

Update `<PROJECT_ID>` with the correct project name throughout the tutorial.

```bash
gcloud container clusters create workshop \
--machine-type n1-standard-4 \
--node-locations europe-west1-b,europe-west1-c,europe-west1-d \
--num-nodes "1" \
--release-channel stable \
--region europe-west1 \
--disk-type "pd-ssd" \
--disk-size "120" \
--network "default" \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform" \
--labels k8s-scope=kubernetes-workshop-doit,k8s-cluster=primary,environment=workshop \
--workload-pool=<PROJECT_ID>.svc.id.goog && \
kubectl cluster-info ;
```

Now it is time to give the current user complete control over the created cluster using RBAC.

```bash
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
```

## Create test Pub/Sub topic and subscription

We will demonstrate the connection between a Deployment running in GKE to a Pub/Sub subscription. Let's create the necessary resources:

```bash
gcloud pubsub topics create echo
gcloud pubsub subscriptions create echo-read --topic=echo
```

## Create a Namespace and ServiceAccount in GKE

We create a Namespace to deploy our application in and a ServiceAccount that will be eventually be used for the Workload Identity binding:

```bash
kubectl create namespace doit-lab-09
kubectl create serviceaccount pubsub-sa --namespace doit-lab-09

```

## Google Service Account and IAM bindings creation

Workload Identity works by creating a relationship between a Google Service Account (GSA) and a Kubernetes Service Account (KSA). We will grant the required IAM permissions to the GSA, and any workload running in GKE using the related KSA will have access to it. In this case, we will create a GSA and give it permission to subscribe to a Pub/Sub subscription.

```bash
gcloud iam service-accounts create gke-pubsub \
    --project=<PROJECT_ID>

gcloud projects add-iam-policy-binding <PROJECT_ID> \
    --member "serviceAccount:gke-pubsub@<PROJECT_ID>.iam.gserviceaccount.com" \
    --role "roles/pubsub.subscriber"
```

Now that we created the GSA, we need to bind the KSA to it. This is done by granting the KSA the `roles/iam.workloadIdentityUser` IAM role on the GSA:

```bash
gcloud iam service-accounts add-iam-policy-binding gke-pubsub@<PROJECT_ID>.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:<PROJECT_ID>.svc.id.goog[doit-lab-09/pubsub-sa]"
```

Eventually, we annotate the KSA with the GSA email address:

```bash
kubectl annotate serviceaccount pubsub-sa \
    --namespace doit-lab-09 \
    iam.gke.io/gcp-service-account=gke-pubsub@<PROJECT_ID>.iam.gserviceaccount.com
```

## Cluster Application Deployment

Make sure you handled all previous steps of this README! Now we'll create a sample Deployment that connects to the Pub/Sub subscription we created in a previous step. Note how we do not pass any credentials at any point, we only specify the KSA to use (the `serviceAccountName` field in the pod spec).

### Run Deployment
```bash
kubectl apply -f pubsub-deployment.yaml

# wait for pod to be ready, break this command once ready
kubectl get pod --watch --selector app=pubsub
```

### Test the Pub/Sub connection

Now we can tail the logs of our newly created pod, then post a message to the Pub/Sub topic and verify the connection:

```bash
kubectl logs -f --selector app=pubsub
```

In another terminal window, post a message to the echo topic:

```bash
gcloud pubsub topics publish echo --message="Hello, world\!"
```

After a slight delay, you should see our pod receiving and processing the message we just posted to the topic.

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-09` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-09
```

## Application Clean-Up

```bash
# delete k8s namespace and resources in it
kubectl delete ns doit-lab-09

# delete IAM Service Account
gcloud iam serviceaccount delete gke-pubsub@<PROJECT_ID>.iam.gserviceaccount.com

# delete Pub/Sub subscription and topic
gcloud pubsub subscriptions delete echo-read
gcloud pubsub topics delete echo

# optional: delete GKE cluster
gcloud container clusters delete workshop
```

## Links

- https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
- https://cloud.google.com/kubernetes-engine/docs/tutorials/authenticating-to-cloud-platform
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/

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
