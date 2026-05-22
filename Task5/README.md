# Задание 5. Управление трафиком внутри кластера Kubertnetes

### 0. Запуск minicube
Встроенный CNI не поддерживает сетевые политики, используем calico, например.
```bash
minikube start --cni=calico
```
*Все действия задания 5 (создание подов, сервисов, сетевых политик) выполняются от имени администратора кластера. Если вы используете тот же кластер, что и в задании 4, в котором вы переключались на контекст ограниченного пользователя (```gena-viewer```), нужно переключиться на административный контекст.* 

```bash
kubectl config use-context minikube
```

### 1. Подготовка
Создадим отдельный namespace `propdev-network`
```bash
kubectl create namespace propdev-network
kubectl config set-context --current --namespace=propdev-network
```

### 2. Запуск четырёх сервисов с метками
```bash
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80
```
Проверка
```bash
kubectl get pods --show-labels
kubectl get svc --show-labels
```

### 3. Сетевые политики
[non-admin-api-allow.yaml](non-admin-api-allow.yaml)
```aiignore
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: non-admin-api-allow
spec:
  podSelector:
    matchLabels:
      role: back-end-api
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: front-end
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: non-admin-frontend-allow
spec:
  podSelector:
    matchLabels:
      role: front-end
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: back-end-api
```
[admin-api-allow.yaml](admin-api-allow.yaml)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admin-api-allow
spec:
  podSelector:
    matchLabels:
      role: admin-back-end-api
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: admin-front-end
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admin-frontend-allow
spec:
  podSelector:
    matchLabels:
      role: admin-front-end
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: admin-back-end-api
```
Применяем политики:

```bash
kubectl apply -f non-admin-api-allow.yaml
kubectl apply -f admin-api-allow.yaml
```

### 4. Проверка сетевых политик

#### front-end -> back-end-api Разрешено
Запускаем тестовый под с `role=front-end`
```bash
kubectl run test-front --rm -it --image=alpine --labels role=front-end -- sh
```
Внутри выполняем
```bash
/ # wget -qO- --timeout=2 http://back-end-api-app
```
Получаем HTML-страницу приветствия nginx - доступ разрешён.

#### front-end -> admin-back-end-api Запрещено
В том же поде выполняем
```bash
/ # wget -qO- --timeout=2 http://admin-back-end-api-app
```
Получаем `wget: download timed out` - доступ запрещён. \
Выходим из пода.
```bash
/ # exit
```

#### admin-front-end -> admin-back-end-api Разрешено
Запускаем тестовый под с `role=admin-front-end`
```bash
kubectl run test-front-admin --rm -it --image=alpine --labels role=admin-front-end -- sh
```
Внутри выполняем
```bash
/ # wget -qO- --timeout=2 http://admin-back-end-api-app
```
Получаем HTML-страницу приветствия nginx - доступ разрешён.

#### admin-front-end -> back-end-api Запрещено
В том же поде выполняем
```bash
/ # wget -qO- --timeout=2 http://back-end-api-app
```
Получаем `wget: download timed out` - доступ запрещён. \
Выходим из пода.
```bash
/ # exit
```






