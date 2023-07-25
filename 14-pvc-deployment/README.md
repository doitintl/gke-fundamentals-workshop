# GKE Workshop LAB-14

[![Context](https://img.shields.io/badge/GKE%20Fundamentals-1-blue.svg)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Introduction

In the following lab we will create a Redis deployment and a PersistentVolumeClaim, the Redis deployment will use the generated PersistentVolume to store data that will survive pod restarts.
Stateful workloads should utilize [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/), however, this lab demonstrates that any workload can utilize a volume if necessary.

## Deployment

### Run Deployment

```bash
kubectl apply -f .
```

Now we can check that our `PersistentVolumeClaim` is created:

```bash
kubectl get pvc --namespace doit-lab-14
```

And that the PVC created a Persistent Volume (using the [Compute Engine persistent disk CSI Driver](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver)):

```bash
kubectl get pv
```

We'll wait for the Redis pod to come up

```bash
kubectl get po -w --namespace doit-lab-14
```

Once it's ready, let's run a shell inside it

```bash
kubectl -n doit-lab-14 exec -ti deployments/redis -- sh
```

List files within our data volume

```bash
ls -l /data
```

Let's check for the existence of a key in the DB

```bash
redis-cli get lab-14
```

We can see that it's not set (returning `(nil)`). Let's set it

```bash
redis-cli set lab-14 'Hello world!'
```

Exit the pod (Ctrl+D) and delete it. The deployment controller will start a new one

```bash
kubectl delete po -lk8s-app=redis -n doit-lab-14
```

Now let's exec into the newly created pod

```bash
kubectl -n doit-lab-14 exec -ti deployments/redis -- sh
```

And make sure that data was persisted across restarts

```bash
/data # redis-cli get lab-14
"Hello world!"
```

## Application Clean-Up

```bash
kubectl delete -f .
```

## Links

- https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes
- https://redis.io/docs/management/persistence/
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://phoenixnap.com/kb/kubectl-commands-cheat-sheet
