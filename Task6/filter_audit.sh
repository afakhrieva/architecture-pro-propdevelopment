#!/bin/bash
INPUT="audit.log"
OUTPUT="audit-extract.json"

if [ ! -f "$INPUT" ]; then
    echo "Ошибка: файл $INPUT не найден"
    exit 1
fi

echo "Фильтрация подозрительных событий..." >&2

# Очищаем выходной файл
> "$OUTPUT"

# 1. Доступ к secrets (list/get от monitoring)
grep '"verb":"\(list\|get\)"' "$INPUT" | grep '"resource":"secrets"' | grep 'monitoring' >> "$OUTPUT"

# 2. Привилегированный под (create + pods + privileged:true)
grep '"verb":"create"' "$INPUT" | grep '"resource":"pods"' | grep '"privileged":true' >> "$OUTPUT"

# 3. kubectl exec (create + subresource exec)
grep '"verb":"create"' "$INPUT" | grep '"subresource":"exec"' >> "$OUTPUT"

# 4. RoleBinding с cluster-admin (create + rolebindings + cluster-admin)
grep '"verb":"create"' "$INPUT" | grep '"resource":"rolebindings"' | grep 'cluster-admin' >> "$OUTPUT"

# 5. Удаление audit-policy (audit-policy)
grep 'audit-policy' "$INPUT" >> "$OUTPUT"

COUNT=$(wc -l < "$OUTPUT")
echo "Найдено событий: $COUNT" >&2
echo "Результат сохранён в $OUTPUT" >&2