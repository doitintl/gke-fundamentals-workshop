# GKE Workshop LAB-11

## RBAC for in-cluster clients

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Deployment

1. Deploy namespace, RBAC and deployment. This example app will list all pods running in the same namespace and will try attach a new label to them:

```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-rbac.yaml
kubectl apply -f 02-deployment.yaml
```

2. Inspect pods

```bash
kubectl get pods -n doit-lab-11
kubectl describe pod ... -n doit-lab-11
```

3. Now check the status of the podlabeler pod. Once the container has finished creating, you'll see it error out. Investigate the error by inspecting the pods' events and logs:

```bash
$ kubectl get pods -n doit-lab-11

NAME                          READY   STATUS   RESTARTS      AGE
pod-labeler-595b57b64-4j7r7   0/1     Error    3 (32s ago)   47s

# Check the pod's logs
$ kubectl logs -f pod-labeler-595b57b64-4j7r7 -n doit-lab-11

Attempting to list pods
labeling pod pod-labeler-595b57b64-4j7r7
Traceback (most recent call last):
  File "/usr/src/app/./label_pods.py", line 59, in <module>
    run_labeler(args.namespace)
  File "/usr/src/app/./label_pods.py", line 50, in run_labeler
    v1.patch_namespaced_pod(name=i.metadata.name,
  File "/usr/local/lib/python3.11/site-packages/kubernetes/client/api/core_v1_api.py", line 19872, in patch_namespaced_pod
    return self.patch_namespaced_pod_with_http_info(name, namespace, body, **kwargs)  # noqa: E501
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/kubernetes/client/api/core_v1_api.py", line 19987, in patch_namespaced_pod_with_http_info
    return self.api_client.call_api(
           ^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/kubernetes/client/api_client.py", line 348, in call_api
    return self.__call_api(resource_path, method,
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/kubernetes/client/api_client.py", line 180, in __call_api
    response_data = self.request(
                    ^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/kubernetes/client/api_client.py", line 407, in request
    return self.rest_client.PATCH(url,
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/kubernetes/client/rest.py", line 296, in PATCH
    return self.request("PATCH", url,
           ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/local/lib/python3.11/site-packages/kubernetes/client/rest.py", line 235, in request
    raise ApiException(http_resp=r)
kubernetes.client.exceptions.ApiException: (403)
Reason: Forbidden
HTTP response headers: HTTPHeaderDict({'Audit-Id': 'b22f55a8-df72-4bfd-bc50-bad8557cdac5', 'Cache-Control': 'no-cache, private', 'Content-Type': 'application/json', 'X-Content-Type-Options': 'nosniff', 'X-Kubernetes-Pf-Flowschema-Uid': 'd56108f2-a8f8-44c0-a56e-3071c68ac1f8', 'X-Kubernetes-Pf-Prioritylevel-Uid': '6f700103-9e74-4418-b035-81039f0dc04b', 'Date': 'Tue, 25 Jul 2023 14:31:21 GMT', 'Content-Length': '364'})
HTTP response body: {"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"pods \"pod-labeler-595b57b64-4j7r7\" is forbidden: User \"system:serviceaccount:doit-lab-11:pod-labeler\" cannot patch resource \"pods\" in API group \"\" in the namespace \"doit-lab-11\"","reason":"Forbidden","details":{"name":"pod-labeler-595b57b64-4j7r7","kind":"pods"},"code":403}
```

5. We can see that the PATCH operations is failing. Let's check the RBAC role again:

```bash
  kind: Role
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: pod-labeler
    namespace: doit-lab-11
  rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["list"]
```

6. Looks like our podlabeler does not have sufficient permissions to PATCH pods and can only list them. Let's fix this, replace the pod and then check the labels on our pods:

```bash
kubectl auth reconcile -f 03-rbac-fixed.yaml

kubectl delete pod --selector app=pod-labeler -n doit-lab-11

kubectl get pods --show-labels -n doit-lab-11 -w
```

## Application Clean-Up

```bash
kubectl delete ns doit-lab-11
```
