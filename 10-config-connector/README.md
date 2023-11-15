# GKE Workshop LAB-10

## Config Connector example

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

On standard GKE cluster, Config Connector can be installed as an [add-on](https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall), unfortunately this currently not supported for Autopilot clusters.
Therefore we will install the [Config Connector operator manually](https://cloud.google.com/config-connector/docs/how-to/advanced-install#installing_the_operator), which also gives us the advantage of running the latest available version.

## Core Requirements

For the use of the local development environment for all GKE/K8s relevant CLI/API calls a certain tool set is required and Linux or MacOS as operating system is recommended. If it is not possible to install our stack due to limitations in terms of feasibility/availability in the preparation, you can alternatively use the browser-internal cloud shell of your GCP console.

- `gcloud sdk` [installation](https://cloud.google.com/sdk/docs/install) tutorial
- `kubectl` [installation](https://kubernetes.io/docs/tasks/tools/) tutorial
- `${GCP_PROJECT}` is used throughout the lab as a placeholder, `envsubst` is used in each kubectl command that needs to evaluate this variable, so make sure to export the project name:

```bash
export GCP_PROJECT=$(gcloud config get core/project)
```

- Enable Cloud Resource Manager API:

```bash
gcloud services enable cloudresourcemanager.googleapis.com
```

## Install Config Connector in our cluster

Instructions from the [official documentation](https://cloud.google.com/config-connector/docs/how-to/advanced-install#installing_the_operator):

```bash
gsutil cp gs://configconnector-operator/latest/release-bundle.tar.gz release-bundle.tar.gz

tar zxvf release-bundle.tar.gz

kubectl apply -f operator-system/autopilot-configconnector-operator.yaml
```

## Create an identity for Config Connector

The Config Connector controller utilizes [Workload Identity](../09-workload-identity-pubsub/README.md) to impersonate an IAM service account with permissions in the project. This service account needs to have `roles/owner` role (if you plan to manage IAM, or resources on the folder/organization level), or `roles/editor` otherwise.

```bash
gcloud iam service-accounts create config-connector-sa

gcloud projects add-iam-policy-binding ${GCP_PROJECT} \
    --member="serviceAccount:config-connector-sa@${GCP_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/owner"
```

Then allow the Config Connector controller KSA to use the GSA we just created:

```bash
gcloud iam service-accounts add-iam-policy-binding \
    config-connector-sa@${GCP_PROJECT}.iam.gserviceaccount.com \
    --member="serviceAccount:${GCP_PROJECT}.svc.id.goog[cnrm-system/cnrm-controller-manager]" \
    --role="roles/iam.workloadIdentityUser"
```

## Configure Config Connector to run in cluster mode

Config Connector can run either in `cluster` or in `namespaced` mode. `cluster` mode will allow the controller to monitor the entire cluster for Config Connector resources. `namespaced` mode will require additional configuration that will allow the controller to monitor only specific namespaces.
We will configure Config Connector to run in `cluster` mode, read [here](https://cloud.google.com/config-connector/docs/how-to/advanced-install#namespaced-mode) for instructions for `namespaced` mode.

```bash
# replace ${GCP_PROJECT} with the correct value in this file before applying!!
envsubst < 00-configconnector.yaml | kubectl apply -f -
```

As mentioned above, Config Connector can create resource in the [Organization, Folder or Project level](https://cloud.google.com/config-connector/docs/how-to/organizing-resources/overview), we will focus on creating resources in the project.
For that, we will need to set an [annotation specifying the project id](https://cloud.google.com/config-connector/docs/how-to/organizing-resources/project-scoped-resources), either on the Namespace level, or on each individual resource.

## Create a Namespace

In order to avoid annotating each individual resource, we will create the Namespace with the annotation setting the correct project id:

```bash
# replace ${GCP_PROJECT} with the correct value in this file before applying!!
envsubst < 01-namespace.yaml | kubectl apply -f -
```

## Create Pub/Sub topic and subscription

Similar to the previous lab, we will create a Pub/Sub topic and subscription, this time using Config Connector (I suggest reviewing the manifests):

```bash
envsubst < 02-pubsub.yaml | kubectl apply -f  -
```

Wait for our newly created resources to be ready:

```bash
kubectl -n doit-lab-10 wait --for=condition=READY pubsubtopics echo

kubectl -n doit-lab-10 wait --for=condition=READY pubsubsubscription echo-read
```

## Create KSA, GSA and IAM bindings

We will use Config Connector in conjunction with Workload Identity, to create a GSA with IAM permissions to subscribe to pubsub, then create a KSA that can use that GSA with Workload Identity.

```bash
# replace ${GCP_PROJECT} with the correct value in this file before applying!!
envsubst < 03-iam.yaml | kubectl apply -f -

envsubst < 04-serviceaccount.yaml | kubectl apply -f -
```

### Run Deployment

```bash
kubectl apply -f 05-pubsub-deployment.yaml

# wait for pod to be ready, break this command once ready
kubectl -n doit-lab-10 get pod --watch --selector app=pubsub
```

### Test the Pub/Sub connection

Now we can tail the logs of our newly created pod, then post a message to the Pub/Sub topic and verify the connection:

```bash
kubectl -n doit-lab-10 logs -f --selector app=pubsub
```

In another terminal window, post a message to the echo topic:

```bash
gcloud pubsub topics publish echo --message="Hello, world\!"
```

## Additional notes on Config Connector

### Acquiring existing resources

If a resource created by Config Connector already exists in the project/folder/org, [Config Connector will take control over it](https://cloud.google.com/config-connector/docs/how-to/managing-deleting-resources#acquiring_an_existing_resource). It will also modify any configuration that diverges from the manifest.

### Deletion policy

[By default](https://cloud.google.com/config-connector/docs/how-to/managing-deleting-resources#keeping_resources_after_deletion), Config Connector will delete the associated GCP resource when you delete Config Connector resource. If this is not desired, an annotation can be set to abandon the GCP resource on deletion:
`cnrm.cloud.google.com/deletion-policy: abandon`

### Conflict prevention

It is possible to create several Config Connector resources that are backed by the same GCP resource, this can lead to conflicts. If you have a use-case the necessitates doing that, [you can disable conflict prevention](https://cloud.google.com/config-connector/docs/concepts/managing-conflicts#modifying_conflict_prevention) to allow multiple Config Connector resources backed by the same GCP resource.
This will usually require configuring the [deletion policy](#deletion-policy) of the resource as well.

## Optional Steps

Now we can set the current k8s context to our lab exercise namespace `doit-lab-10` to make sure that every command set is run against this lab resources.

```bash
kubectl config set-context --current --namespace=doit-lab-10
```

Inspect each YAML manifest before applying, describe created resources with `kubectl` to inspect each object after creation.

## Application Clean-Up

```bash
# delete k8s namespace and resources in it
kubectl delete ns doit-lab-10

# optional: delete Config Connector IAM Service Account (if cluster is deleted)
gcloud iam service-accounts delete config-connector-sa@${GCP_PROJECT}.iam.gserviceaccount.com
```

## Links

- https://cloud.google.com/config-connector/docs/overview
- https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall
- https://cloud.google.com/config-connector/docs/how-to/advanced-install#installing_the_operator
- https://cloud.google.com/config-connector/docs/how-to/organizing-resources/overview
- https://cloud.google.com/config-connector/docs/how-to/getting-started
- https://cloud.google.com/config-connector/docs/reference/overview
- https://cloud.google.com/config-connector/docs/how-to/managing-deleting-resources
- https://cloud.google.com/config-connector/docs/concepts/managing-conflicts
- https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
- https://cloud.google.com/kubernetes-engine/docs/tutorials/authenticating-to-cloud-platform
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
