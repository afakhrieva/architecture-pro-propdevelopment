#!/bin/bash
# Создаёт сертификаты для пользователей и добавляет их в kubeconfig.

set -e

# Каталог для ключей
mkdir -p .certs

# CA Minikube
CA_CERT="$HOME/.minikube/ca.crt"
CA_KEY="$HOME/.minikube/ca.key"

if [[ ! -f "$CA_CERT" || ! -f "$CA_KEY" ]]; then
    echo "Ошибка: не найден CA Minikube. Проверьте, что Minikube запущен."
    exit 1
fi

# Функция создания пользователя
create_user() {
    local USER=$1
    local GROUP=$2

    echo "Создаю пользователя $USER (группа $GROUP)"

    # Приватный ключ
    openssl genrsa -out .certs/${USER}.key 2048

    # CSR (запрос на подпись)
    openssl req -new -key .certs/${USER}.key -out .certs/${USER}.csr -subj "/CN=$USER/O=$GROUP"

    # Подписываем сертификат CA Minikube
    openssl x509 -req -in .certs/${USER}.csr -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out .certs/${USER}.crt -days 365

    # Добавляем учётную запись в kubeconfig (создаём новый контекст)
    kubectl config set-credentials ${USER} --client-certificate=.certs/${USER}.crt --client-key=.certs/${USER}.key --embed-certs=true

    # Создаём контекст
    kubectl config set-context ${USER}-context --cluster=minikube --namespace=default --user=${USER}
}

# Создаём трёх пользователей с разными группами
create_user "lena-auditor" "security-auditors"
create_user "vasya-devops" "cluster-devops"
create_user "gena-viewer" "viewers"

echo "Пользователи созданы."