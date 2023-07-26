# GKE Workshop LAB-09

## Workload Identity example with Pub/Sub

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will run a Deployment and all necessary plumbing for it to communicate to a GCP service using [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity). This lab will give insight into the recommended method of authenticating workloads running within GKE to other GCP services using IAM permissions.

## Environment preparation

Update `${GCP_PROJECT}` with the correct project name throughout the tutorial:

```bash
export GCP_PROJECT=$(gcloud config get core/project)
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
    --project=${GCP_PROJECT}

gcloud projects add-iam-policy-binding ${GCP_PROJECT} \
    --member "serviceAccount:gke-pubsub@${GCP_PROJECT}.iam.gserviceaccount.com" \
    --role "roles/pubsub.subscriber"
```

Now that we created the GSA, we need to bind the KSA to it. This is done by granting the KSA the `roles/iam.workloadIdentityUser` IAM role on the GSA:

```bash
gcloud iam service-accounts add-iam-policy-binding gke-pubsub@${GCP_PROJECT}.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${GCP_PROJECT}.svc.id.goog[doit-lab-09/pubsub-sa]"
```

Eventually, we annotate the KSA with the GSA email address:

```bash
kubectl annotate serviceaccount pubsub-sa \
    --namespace doit-lab-09 \
    iam.gke.io/gcp-service-account=gke-pubsub@${GCP_PROJECT}.iam.gserviceaccount.com
```

## Cluster Application Deployment

Make sure you handled all previous steps of this README! Now we'll create a sample Deployment that connects to the Pub/Sub subscription we created in a previous step. Note how we do not pass any credentials at any point, we only specify the KSA to use (the `serviceAccountName` field in the pod spec).

### Run Deployment

```bash
kubectl apply -f 00-pubsub-deployment.yaml

# wait for pod to be ready, break this command once ready
kubectl get pod --watch --selector app=pubsub --namespace doit-lab-09
```

### Test the Pub/Sub connection

Now we can tail the logs of our newly created pod, then post a message to the Pub/Sub topic and verify the connection:

```bash
kubectl logs -f --selector app=pubsub --namespace doit-lab-09
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
gcloud iam service-accounts delete gke-pubsub@${GCP_PROJECT}.iam.gserviceaccount.com

# delete Pub/Sub subscription and topic
gcloud pubsub subscriptions delete echo-read
gcloud pubsub topics delete echo
```

## Links

- https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
- https://cloud.google.com/kubernetes-engine/docs/tutorials/authenticating-to-cloud-platform
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
