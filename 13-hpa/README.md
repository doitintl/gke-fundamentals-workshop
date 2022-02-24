# GKE Workshop LAB-13

## Scaling a deployment using HPA

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GKE/K8s Version](https://img.shields.io/badge/k8s%20version-1.18.20-blue.svg)](#)
[![GCloud SDK Version](https://img.shields.io/badge/gcloud%20version-359.0.0-blue.svg)](#)


## Cluster Provisioning

The present gcloud command call initializes the workshop-cluster as regional cluster configuration with one node in each of three availability zones.

_If you have already initialized the cluster, you can skip this step now!_

- Please make sure that you are also in the project prepared for this workshop or that your used dev/sandbox project has also been selected via `cloud init`!

- Init your GKE-Cluster with a unique identifier suffix

    ```bash
    printf "%s\n" "[INIT] workshop cluster"
    UNIQUE_CLUSTER_KEY=$RANDOM; gcloud container clusters create workshop-${UNIQUE_CLUSTER_KEY} \
    --machine-type n2-standard-2 \
    --scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform" \
    --region europe-west1 \
    --node-locations europe-west1-b,europe-west1-c,europe-west1-d \
    --release-channel stable \
    --disk-type "pd-ssd" \
    --disk-size "60" \
    --num-nodes "1" \
    --max-nodes "1" \
    --min-nodes "1" \
    --logging=SYSTEM,WORKLOAD \
    --monitoring=SYSTEM \
    --network "default" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS \
    --labels k8s-scope=gke-workshop-doit,k8s-cluster=primary,k8s-env=workshop && \
    printf "%s\n" "[INIT] test access new cluster using k8s API via kubectl" \
    kubectl get all --all-namespaces && kubectl cluster-info && \
    printf "\n%s\n\n" "[INIT] workshop cluster finally initialized and available by ID -> [ workshop-${UNIQUE_CLUSTER_KEY} ] <-"
    ```

- (optional) If it is necessary to re-authenticate to the created GKE cluster (e.g. to run kubectl commands) the following command may help:

    ```bash
    gcloud container clusters get-credentials workshop-${UNIQUE_CLUSTER_KEY}
    ```



## Cluster Application Deployment

Make sure you handled all previous steps of this README! Now, as announced, we perform the actual deployment of the kubernetes-dashboard and provision an access-authorized user for token-based authentication at the frontend of the application.

1. Create namespace and deployments:
  ```bash
  kubectl apply -f 00-namespace.yaml
  kubectl apply -f 01-php-deployment.yaml
  ```

2. Inspect the pods once they are running:

  ```bash
  kubectl get pods -n doit-lab-13
  kubectl describe pod ... -n doit-lab-13
  ```

3. Deploy the load generator:

  ```bash
  kubectl apply -f 02-load-generator-pod.yaml
  ```

4. Check/wait until CPU and memory metrics are coming in:

  ```bash
  watch -n 1 'kubectl top pod -n doit-lab-13'
  ```

5. Deploy the Horizontal Pod Autoscaler:

  ```bash
  kubectl apply -f 03-php-hpa.yaml
  ```
6. Check/wait for scaleup:

  ```bash
  watch -n 1 'kubectl top pod -n doit-lab-13'
  ```


## Application Clean-Up

```bash
kubectl delete -f .
```
