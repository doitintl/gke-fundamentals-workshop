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
# Lab-02 b/c Provisioning Script
#

read -p "provisioning of lab-02-a/lab-02-b (y/n) ? " -n 1 -r; echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# ensure lab-1 (elasticsearch single-node) was cleaned up
killall kubectl &>/dev/null
kubectl delete -f ../lab-01-a/ &>/dev/null

# apply lab-2-b/lab-2-c (elasticsearch statefulSet && kibana-dashboard)

kubectl apply -f ../lab-02-b/ && \
kubectl apply -f ../lab-02-c/

DASHBOARD_URL="http://localhost:8001/api/v1/namespaces/doit-lab-02-b/services/https:kubernetes-dashboard:/proxy/#/workloads?namespace=default"
ADMIN_TOKEN=$(kubectl -n doit-lab-02-b get secret $(kubectl -n doit-lab-02-b get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}")
KIBANA_URL="http://localhost:8001/api/v1/namespaces/doit-lab-02-bc/services/kibana/proxy/app/kibana#/dev_tools/console?_g=()"

nohup kubectl proxy &

printf "%s\n" "Use the following token to log in as admin-user to your dashboard:" "$DASHBOARD_URL" "-----" "$ADMIN_TOKEN" "-----"
printf "%s\n" "When Elasticsearch has finished starting up you can access Kibana here:" "$KIBANA_URL"
