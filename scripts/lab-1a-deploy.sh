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
# Lab-01-A Provisioning Script
#

read -p "auto-provisioning of lab-01-a (y/n) ? " -n 1 -r; echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

kubectl apply -f ../lab-01-a/

NAMESPACE_WS_LAB="doit-lab-01-a"
DASHBOARD_URL="http://localhost:8001/api/v1/namespaces/${NAMESPACE_WS_LAB}/services/https:kubernetes-dashboard:/proxy/"
DASHBOARD_TOKEN=$(kubectl -n ${NAMESPACE_WS_LAB} get secret $(kubectl -n ${NAMESPACE_WS_LAB} get sa/kubernetes-dashboard -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}")
DASHBOARD_ADMIN_TOKEN=$(kubectl -n ${NAMESPACE_WS_LAB} get secret $(kubectl -n ${NAMESPACE_WS_LAB} get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}")

printf "%s\n" "Use the following token to log in as admin-user to your dashboard:" "${DASHBOARD_URL}" "-----" "${DASHBOARD_ADMIN_TOKEN}" "-----"
printf "%s\n" "Use the following token to log in as kubernetes-dashboard user to your dashboard:" "${DASHBOARD_URL}" "-----" "${DASHBOARD_ADMIN_TOKEN}" "-----"

nohup kubectl proxy &
