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

# get hostname
USERNAME="$(whoami)"

printf "%s\n" "[INIT] compute/zone" ;
gcloud config set compute/zone europe-west1-b ;

printf "%s\n" "[INIT] workshop cluster" ;
gcloud container clusters create workshop-$USERNAME \
--machine-type n1-standard-4 \
--scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform" \
--node-locations europe-west1-b,europe-west1-c,europe-west1-d \
--release-channel stable \
--region europe-west1 \
--image-type "ubuntu" \
--disk-type "pd-ssd" \
--disk-size "120" \
--num-nodes "3" \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--network "default" \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS \
--labels k8s-scope=kubernetes-workshop-doit,k8s-cluster=primary,environment=workshop ;

printf "%s\n" "[TEST] access to kubernetes API via kubectl" ;
kubectl get all --all-namespaces && \
kubectl cluster-info ;
