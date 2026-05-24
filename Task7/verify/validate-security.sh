#!/bin/bash
echo "=== Дополнительная проверка политик ==="
NAMESPACE="audit-zone"
echo "Метка namespace:"
kubectl get ns "$NAMESPACE" -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}'
echo ""

echo "Gatekeeper constraints:"
kubectl get constraints --no-headers 2>/dev/null || echo "Нет constraints"