#!/bin/bash
kubectl apply -f roles/security-auditor.yaml
kubectl apply -f roles/cluster-devops.yaml
kubectl apply -f roles/viewer.yaml
echo "Роли созданы"