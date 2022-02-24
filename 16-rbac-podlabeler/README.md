# GKE Workshop LAB-16

## Container-native load balancing via NEG

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

1. Deploy namespace and deployment.  This example app will list all pods running in the same namespace and will try attach a new label to them:
  ```bash
  kubectl apply -f 00-namespace.yaml
  kubectl apply -f 01-pod-labeler.yaml
  ```

2. Inspect pods

  ```bash
  kubectl get pods -n doit-lab-16
  kubectl describe pod ... -n doit-lab-16
  ```


3. Now check the status of the podlabeler pod. Once the container has finished creating, you'll see it error out. Investigate the error by inspecting the pods' events and logs:

  ```bash
  kubectl get pods -n doit-lab-16

  NAME                           READY     STATUS    RESTARTS   AGE
  pod-labeler-6d9757c488-tk6sp   0/1       Error     1          1m

  # Check the pod's logs
  kubectl logs -f pod-labeler-6d9757c488-tk6sp -n doit-lab-16
  
  Attempting to list pods
  labeling pod pod-labeler-c7b4fd44d-mr8qh
  Traceback (most recent call last):
    File "label_pods.py", line 22, in <module>
      api_response = v1.patch_namespaced_pod(name=i.metadata.name, namespace="default", body=body)
    File "build/bdist.linux-x86_64/egg/kubernetes/client/apis/core_v1_api.py", line 15376, in patch_namespaced_pod
    File "build/bdist.linux-x86_64/egg/kubernetes/client/apis/core_v1_api.py", line 15467, in patch_namespaced_pod_with_http_info
    File "build/bdist.linux-x86_64/egg/kubernetes/client/api_client.py", line 321, in call_api
    File "build/bdist.linux-x86_64/egg/kubernetes/client/api_client.py", line 155, in __call_api
    File "build/bdist.linux-x86_64/egg/kubernetes/client/api_client.py", line 380, in request
    File "build/bdist.linux-x86_64/egg/kubernetes/client/rest.py", line 286, in PATCH
    File "build/bdist.linux-x86_64/egg/kubernetes/client/rest.py", line 222, in request
  kubernetes.client.rest.ApiException: (403)
  Reason: Forbidden
  HTTP response headers: HTTPHeaderDict({'Date': 'Fri, 25 May 2018 16:01:40 GMT', 'Audit-Id': '461fa750-57c9-4fea-8717-f1778828417f', 'Content-Length': '385', 'Content-Type': 'application/json', 'X-Content-Type-Options': 'nosniff'})
  HTTP response body: {"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"pods \"pod-labeler-c7b4fd44d-mr8qh\" is forbidden: User \"system:serviceaccount:default:pod-labeler\" cannot patch pods in the namespace \"default\": Unknown user \"system:serviceaccount:default:pod-labeler\"","reason":"Forbidden","details":{"name":"pod-labeler-c7b4fd44d-mr8qh","kind":"pods"},"code":403}
  ```
5. We can see that the PATCH operations is failing. Let's check the RBAC role again:
   ```bash
  kind: Role
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: pod-labeler
    namespace: doit-lab-16
  rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["list"]
    ```

6. Looks like our podlabeler does not have suffucient permissions to PATCH pods and can only list them. Let's fix this and then check the labels on our pods:

```bash
  kubectl apply -f 02-pod-labeler-fix.yaml
  kubectl get pods --show-labels -n doit-lab-16
```

## Application Clean-Up

```bash
kubectl delete -f .
```
