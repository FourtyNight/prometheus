#!/bin/bash

# Переменные
NODE_EXPORTER_VERSION="1.5.0"
NODE_EXPORTER_USER="node_exporter"
NODE_EXPORTER_GROUP="node_exporter"
NODE_EXPORTER_BIN="/usr/local/bin/node_exporter"
NODE_EXPORTER_SERVICE_FILE="/etc/systemd/system/node-exporter.service"

# Функция для загрузки и установки node-exporter
install_node_exporter() {
    echo "Загрузка Node Exporter версии $NODE_EXPORTER_VERSION..."
    wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz

    echo "Распаковка Node Exporter..."
    tar -xvf /tmp/node_exporter.tar.gz -C /tmp

    echo "Установка Node Exporter..."
    sudo cp /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter $NODE_EXPORTER_BIN
    sudo chown $NODE_EXPORTER_USER:$NODE_EXPORTER_GROUP $NODE_EXPORTER_BIN
    sudo chmod +x $NODE_EXPORTER_BIN

    # Удаление временных файлов
    rm -rf /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64
    rm /tmp/node_exporter.tar.gz
}

# Функция для создания пользователя и группы node_exporter
create_user_and_group() {
    if ! id -u $NODE_EXPORTER_USER >/dev/null 2>&1; then
        echo "Создание пользователя и группы $NODE_EXPORTER_USER..."
        sudo useradd -M -r -s /bin/false $NODE_EXPORTER_USER
    fi
}

# Функция для создания файла службы systemd
create_service_file() {
    echo "Создание файла службы systemd для Node Exporter..."
    sudo tee $NODE_EXPORTER_SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$NODE_EXPORTER_USER
Group=$NODE_EXPORTER_GROUP
Type=simple
ExecStart=$NODE_EXPORTER_BIN

[Install]
WantedBy=multi-user.target
EOF

    echo "Перезагрузка демона systemd..."
    sudo systemctl daemon-reload

    echo "Запуск и включение службы Node Exporter..."
    sudo systemctl start node-exporter
    sudo systemctl enable node-exporter
}

# Основная функция
main() {
    echo "Установка и настройка Node Exporter на Debian 12..."
    create_user_and_group
    install_node_exporter
    create_service_file

    echo "Проверка статуса службы Node Exporter..."
    sudo systemctl status node-exporter
}

# Запуск основной функции
main
