# Задание 4. Защита доступа к кластеру Kubernetes

| Роль                             | Права роли                                                                                                                                                                                                                                                                                                           | Группы пользователей                                                     |
|----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `security-auditor` (ClusterRole) | <ul><li>Просмотр (`get/list/watch`) секретов (Secrets) во всех неймспейсах</li><li>Просмотр (`get/list/watch`) конфигурационных карт (ConfigMaps)</li> <li>Просмотр (`get/list/watch`) подов, сервисов, деплойментов, узлов (Nodes)</li> <li>Просмотр (`get/list/watch`) событий и логов подов</li> </ul>            | Специалист по информационной безопасности, внутренние и внешние аудиторы |
| `cluster-devops` (ClusterRole)   | <ul><li>Создание, обновление, удаление деплойментов, сервисов, ингрессов, конфигурационных карт</li><li>Просмотр и изменение большинства стандартных ресурсов (поды, сервисы, репликасеты, statefulsets, jobs)</li><li>Без доступа к секретам</li><li>Без прав на изменение ClusterRole/ClusterRoleBinding</li></ul> | Инженеры по эксплуатации                                                 |
| `viewer` (ClusterRole)           | <ul><li>Только просмотр подов, сервисов, деплойментов, конфигурационных карт, узлов</li><li>Без доступа к секретам</li></ul>                                                                                                                                                                                         | Менеджеры, бизнес-аналитики, руководители проектов                       |

### 0. Запуск minikube
```bash
minikube start --cni=calico
```
`--cni=calico` - для задания 5

### 1. Создать пользователей и контексты
```bash
sh ./create-users.sh
```
Будут созданы три пользователя:
- `lena-auditor` (группа `security-auditors`)
- `vasya-devops` (группа `cluster-devops`)
- `gena-viewer` (группа `viewers`)

Также появятся соответствующие контексты в kubeconfig. Проверить: `kubectl config get-contexts`

### 2. Создать ClusterRole
```bash
sh ./create-roles.sh
```

### 3. Связать группы пользователей с ролями
```bash
sh ./bind-roles.sh
```

### 4. Проверка
```bash
# Аудитор (должен видеть секреты, не может создавать ресурсы)
kubectl config use-context lena-auditor-context
kubectl get secrets -A                            # успешно
kubectl create deployment test --image=nginx      # ошибка (нет прав)

# DevOps (создаёт ресурсы, но не видит секреты)
kubectl config use-context vasya-devops-context
kubectl create deployment test --image=nginx      # успешно
kubectl get secrets                               # ошибка (доступ запрещён)

# Зритель (только просмотр, без секретов и создания)
kubectl config use-context gena-viewer-context
kubectl get pods                                  # успешно
kubectl create deployment test2 --image=nginx     # ошибка
kubectl get secrets                               # ошибка
```