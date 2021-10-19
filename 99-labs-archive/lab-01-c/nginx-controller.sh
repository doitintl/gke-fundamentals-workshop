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
# Lab-01-C controller example script
#

kubectl get -n doit-lab-01-c --watch --output-watch-events --no-headers configmap -o=custom-columns=type:type,name:object.metadata.name | \
while read -r next; do
    if [[ $next =~ nginx ]] ; then
        NGINX_CM_APP_NAME=$(echo $next | cut -d' ' -f2)
        NGINX_CM_EVENT=$(echo $next | cut -d' ' -f1)
        case $NGINX_CM_EVENT in
            ADDED|MODIFIED)
                echo "[DBG] change detected for [${NGINX_CM_APP_NAME}]"
                kubectl apply -f - << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: doit-lab-01-c
---
apiVersion: apps/v1
kind: Deployment
metadata: { name: $NGINX_CM_APP_NAME, namespace: doit-lab-01-c, labels: { k8s-app: operator-test, k8s-scope: gke-ws-doit-lab-01-c }  }
spec:
  selector:
    matchLabels: { app: $NGINX_CM_APP_NAME }
  template:
    metadata:
      labels: { app: $NGINX_CM_APP_NAME, k8s-app: operator-test, k8s-scope: gke-ws-doit-lab-01-c }
      annotations: { kubectl.kubernetes.io/restartedAt: $(date) }
    spec:
      containers:
      - image: nginx:1.7.9
        name: $NGINX_CM_APP_NAME
        ports:
        - containerPort: 80
        volumeMounts:
        - { name: data, mountPath: /usr/share/nginx/html }
      volumes:
      - name: data
        configMap:
          name: $NGINX_CM_APP_NAME
---
apiVersion: v1
kind: Service
metadata:
  name: $NGINX_CM_APP_NAME-svc-lb
  labels: { app: $NGINX_CM_APP_NAME, k8s-app: operator-test, k8s-scope: gke-ws-doit-lab-01-c }
spec:
  type: LoadBalancer
  sessionAffinity: None
  externalTrafficPolicy: Cluster
  ports:
  - nodePort: 30099
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: $NGINX_CM_APP_NAME
    k8s-app: operator-test
    k8s-scope: gke-ws-doit-lab-01-c
EOF
              ;;
          DELETED) # *** If the configmap has been DELETED, delete the NGINX deployment for that configmap.
              kubectl delete deploy "$NGINX_CM_APP_NAME"
              ;;
          esac
    else
        continue ;
    fi

done
