# GKE Workshop LAB-09

## Workload Identity Federation for GKE example with Pub/Sub

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will run a Deployment and all necessary plumbing for it to communicate to a GCP service using [Workload Identity Federation for GKE](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity). This lab will give insight into the recommended method of authenticating workloads running within GKE to other GCP services using IAM permissions.

## Environment preparation

Export the following environment variables that are use throughout this lab:

```bash
# project ID
export PROJECT_ID=$(gcloud config get core/project)

# project number
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)"
)
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

## IAM bindings creation

To let your GKE applications authenticate to Google Cloud APIs using Workload Identity Federation for GKE, you create IAM policies for the specific APIs. The principal in these policies is an IAM principal identifier that corresponds to the workloads, namespaces, or ServiceAccounts. This process returns a federated access token that your workload can use in API calls.

Alternatively, you can configure Kubernetes ServiceAccounts to impersonate IAM service accounts, which configures GKE to exchange the federated access token for an access token from the IAM Service Account Credentials API. We cover this method in the [Config Connector lab](../10-config-connector) and it can also be reviewed in the [official documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#kubernetes-sa-to-iam).

In this case, we will grant our Kubernetes Service Account (KSA) the permission to subscribe to a Pub/Sub subscription.

```bash
gcloud projects add-iam-policy-binding projects/${PROJECT_ID} \
    --role=roles/pubsub.subscriber \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/doit-lab-09/sa/pubsub-sa \
    --condition=None
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

# delete IAM binding to KSA
gcloud projects remove-iam-policy-binding projects/${PROJECT_ID} \
    --role=roles/pubsub.subscriber \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/doit-lab-09/sa/pubsub-sa

# delete Pub/Sub subscription and topic
gcloud pubsub subscriptions delete echo-read
gcloud pubsub topics delete echo
```

## Links

- https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity
- https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
- https://cloud.google.com/kubernetes-engine/docs/tutorials/authenticating-to-cloud-platform
- https://engineering.doit.com/gke-workload-identity-is-now-named-workload-identity-federation-what-else-has-changed-148225d50d04
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
