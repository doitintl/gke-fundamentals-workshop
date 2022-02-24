# GKE Workshop LAB-15

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

1. Run deployment
  ```bash
  kubectl apply -f . 
  ```

2. Check current ingress state (external IP)

  _this step can take up to 3 Minutes_

  ```bash
  kubectl get ingress -n doit-lab-15 --watch
  ```

## Cluster Application Check / Playground

1. You can check the state of Pods at any time with the following kubectl command:
  ```bash
  kubectl get pods -n doit-lab-15
  ```

2. You can check your ingress target service with the following kubectl command:
  ```bash
  kubectl get service -n doit-lab-15
  ```

3. You can get some more detailed information about your ingress resource by the following kubectl command:
  ```bash
  kubectl describe ingress neg-demo-ing -n doit-lab-15
  ```

4. As soon as your ingress resource and the corresponding loadBalancer is provisioned (3-4 minutes):

4.1 You can check the benchmark of your web-application using apache-bench command as shown below:
  ```bash
  ab -n 20 http://<external-ip-of-your-ingress-load-balancer>/
  ```

4.2 You can simulate some traffic to your ingress facing loadBalancer by the following ab-command:
  ```bash
  ab -n 500 -c 25 http://<external-ip-of-your-ingress-load-balancer>/
  ```

4.3 Or just visit the application by hitting your load-balancers external-IP:
  ```bash
    -> http://<external-ip-of-your-ingress-load-balancer>/
  ```
5. Verify ingress functionality

```bash
# scale up the deployment to two replicas
kubectl scale deployment neg-demo-app -n doit-lab-15 --replicas 2
# wait a minute or two for it to complete, and verify that you have two replicas running:
kubectl get deployment neg-demo-app -n doit-lab-15
# get your ingress' public IP:
kubectl describe ingress neg-demo-ing -n doit-lab-15
```

Then verify funtionality and count distinct responses by running:
```bash
# un this command to send 100 requests to your load balancer and count distinct responses:
INGRESS_IP="$(kubectl get ingress -n doit-lab-15 neg-demo-ing -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
for i in $(seq 1 100); do \
  curl --connect-timeout 1 -s $INGRESS_IP && echo; \
done  | sort | uniq -c
```

The result should look similar to this:
```bash
44 neg-demo-app-7f7dfd7bc6-dcn95
56 neg-demo-app-7f7dfd7bc6-jrmzf
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
- https://github.com/kubernetes/dashboard/blob/master/docs/user/installation.md
- https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet

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