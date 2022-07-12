# GKE Workshop LAB-16

## RBAC for in-cluster clients

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Deployment

1. Deploy namespace and deployment. This example app will list all pods running in the same namespace and will try attach a new label to them:

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
