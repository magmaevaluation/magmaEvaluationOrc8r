#!/usr/bin/env bash

ORC_POD=$(kubectl get pod -l app.kubernetes.io/component=orchestrator -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it ${ORC_POD} -- envdir /var/opt/magma/envdir /var/opt/magma/bin/accessc \
  add-existing -admin -cert /var/opt/magma/certs/admin_operator.pem admin_operator

NMS_POD=$(kubectl get pod -l app.kubernetes.io/component=magmalte -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it ${NMS_POD} -- yarn setAdminPassword master admin admin
kubectl exec -it ${NMS_POD} -- yarn setAdminPassword magma-test admin admin
