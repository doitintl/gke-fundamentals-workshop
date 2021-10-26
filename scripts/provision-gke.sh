#!/bin/bash -eu
#
# Copyright 2021 DoiT International.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# GCLOUD SDK && GKE Cluster Init Script
#

printf "%s\n" "[INIT] workshop cluster" ;
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
printf "%s\n" "[INIT] test access new cluster using k8s API via kubectl" ; \
kubectl get all --all-namespaces && kubectl cluster-info && \
printf "\n%s\n\n" "[INIT] workshop cluster finally initialized and available by ID -> [ workshop-${UNIQUE_CLUSTER_KEY} ] <-" ;
