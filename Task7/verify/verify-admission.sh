#!/bin/bash
NAMESPACE="audit-zone"

echo "=== Проверка блокировки небезопасных подов ==="

for manifest in insecure-manifests/*.yaml; do
    echo "Применение $manifest ... "
    output=$(kubectl apply -f "$manifest" 2>&1)
    if echo "$output" | grep -q "Forbidden"; then
        echo "Заблокировано (ожидаемо)"
    else
        echo "Пропущено (ошибка!)"
    fi
done

echo "=== Проверка безопасности ==="
for manifest in secure-manifests/*.yaml; do
    echo "Применение $manifest ... "
    kubectl apply -f "$manifest" 2>&1
    if [ $? -eq 0 ]; then
        echo "Принято"
    else
        echo "Отклонено (ошибка!)"
    fi
done

# Очистка
kubectl delete -f secure-manifests/ --ignore-not-found=true