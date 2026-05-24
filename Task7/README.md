# Задание 7. Аудит и обеспечение соответствия политике безопасности контейнеров (PSP / PodSecurity / OPA Gatekee

## Что сделано
1. Создан namespace `audit-zone` с уровнем PodSecurity `restricted`.
2. Подготовлены небезопасные манифесты (привилегированный под, hostPath, root-пользователь).
3. Исправленные безопасные манифесты (без нарушений).
4. Установлен OPA Gatekeeper и созданы:
    - Шаблоны ограничений:
        - `PrivilegedContainer` (запрет privileged)
        - `HostPath` (запрет hostPath)
        - `RunAsNonRoot` (требование runAsNonRoot)
    - Ограничения, применяемые к namespace `audit-zone`.
5. Написаны скрипты проверки:
    - `verify-admission.sh` – проверяет блокировку небезопасных подов и пропуск безопасных.
    - `validate-security.sh` – проверяет работу Gatekeeper и PodSecurity.

## Как проверить
```bash
cd Task7
kubectl apply -f 01-create-namespace.yaml

# Установить Gatekeeper (если нет)
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml

# Применить шаблоны и ограничения
kubectl apply -f gatekeeper/constraint-templates/
kubectl apply -f gatekeeper/constraints/

# Запустить проверки
sh ./verify/verify-admission.sh
sh ./verify/validate-security.sh
```

