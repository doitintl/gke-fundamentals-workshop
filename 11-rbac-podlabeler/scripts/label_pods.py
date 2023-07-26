#!/usr/bin/python


"""
This script uses the kubernetes client to access the Kubernetes API.

The script periodically requests a list of all pods in the given namespace,
it then iterates over each pod and applies an "updated" label with the
current timestamp.
"""

import time
import argparse
from kubernetes import client, config


def parse_args():
    parser = argparse.ArgumentParser(description="Kubernetes Pod Labeler")
    parser.add_argument("namespace", help="Namespace name to operate in")
    return parser.parse_args()


def run_labeler(namespace):
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
        ret = v1.list_namespaced_pod(namespace, watch=False)
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
                                    namespace=namespace, body=body)

        # Wait before polling the API again
        time.sleep(20)


if __name__ == "__main__":
    args = parse_args()
    run_labeler(args.namespace)
