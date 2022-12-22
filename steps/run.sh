#!/usr/bin/env bash
set -eu

CLIENTS=$(kubectl get pods -l app=iperf3-client -o name -n iperf3 | cut -d'/' -f2)

for POD in ${CLIENTS}; do
    until $(kubectl get pod ${POD} -n iperf3 -o jsonpath='{.status.containerStatuses[0].ready}'); do
        echo "Waiting for ${POD} to start..."
        sleep 5
    done
    HOST=$(kubectl get pod ${POD} -n iperf3 -o jsonpath='{.status.hostIP}')
    kubectl exec -it ${POD} -n iperf3 -- iperf3 -c iperf3-server -T "Client on ${HOST}" $@
    echo
done
