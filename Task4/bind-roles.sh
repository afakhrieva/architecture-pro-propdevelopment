#!/bin/bash
kubectl apply -f bindings/security-auditor-binding.yaml
kubectl apply -f bindings/cluster-devops-binding.yaml
kubectl apply -f bindings/viewer-binding.yaml
echo "Созданы привязки ClusterRole к группам пользователей"