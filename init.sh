#!/bin/bash

set -e

echo "[+] Обновление системы и установка зависимостей..."
sudo apt update
sudo apt install -y ca-certificates curl gnupg

echo "[+] Создание директории для ключей..."
sudo install -m 0755 -d /etc/apt/keyrings

echo "[+] Скачивание и установка GPG-ключа Docker..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "[+] Определение кодового имени дистрибутива..."
. /etc/os-release
CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

if [ -z "$CODENAME" ]; then
  echo "[-] Не удалось определить CODENAME. Прерывание."
  exit 1
fi

echo "[+] Добавление репозитория Docker в sources.list..."
echo "Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $CODENAME
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null

echo "[+] Обновление списка пакетов..."
sudo apt update

echo "[+] Установка Docker и сопутствующих компонентов..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[+] Добавление текущего пользователя в группу docker (опционально)..."
if groups | grep -q '\bdocker\b'; then
  echo "[+] Пользователь уже в группе docker."
else
  sudo usermod -aG docker "$USER"
  echo "[!] Чтобы использовать Docker без sudo, перезайдите в систему или выполните: newgrp docker"
fi

echo "[+] Установка завершена! Проверьте: docker --version"
