#!/bin/bash

# Добавление необходимых пакетов
apk add --no-cache --update make npm jq perl

# Установка зависимостей npm
npm install --save-dev quicktype prettier

# Изменение прав на выполнение для другого скрипта (если необходимо)
chmod +x generate_configs.sh

# Выполнение команды make
make all
