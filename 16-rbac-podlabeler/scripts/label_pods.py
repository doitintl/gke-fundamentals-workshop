#!/usr/bin/python


"""
This is script uses the kubernetes client to access the Kubernetes API.

The script periodically requests a list of all pods in the doit-lab-16 workspace.
It then iterates over each pod and applies an "updated" label with the
current timestamp.
"""

import time
from kubernetes import client, config


def run_labeler():
    """
    Runs an infinite loop that periodically applies an "updated=timestamp"
    label to pods in the namespace
    """

    # Load the in-cluster configuration so we are subject to RBAC rules
    # configured for this service account.
    config.load_incluster_config()

    v1 = client.CoreV1Api()
    while True:
        print("Attempting to list pods")

        # Retrieve all pods in the namespace and iter over each.
        ret = v1.list_namespaced_pod("doit-lab-16", watch=False)
        for i in ret.items:
            print("labeling pod %s" % i.metadata.name)

            # Defines which part of the pod resource we want to update
            body = {
                "metadata": {
                    "labels": {"updated": str(time.time())}
                }
            }

            # Update the pod by "patching" the partial resource definition
            v1.patch_namespaced_pod(name=i.metadata.name,
                                    namespace="doit-lab-16", body=body)

        # Wait before polling the API again
        time.sleep(20)


if __name__ == "__main__":
    run_labeler()