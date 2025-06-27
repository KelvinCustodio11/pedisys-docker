#!/bin/bash

set -e

# Derruba qualquer resquício anterior
docker-compose down -v

# Sobe os containers
docker-compose build && docker-compose up -d

# Espera o banco estar pronto
echo "⏳ Esperando o MySQL ficar disponível..."
db_container_id=$(docker-compose ps -q bagisto-mysql)
until docker exec "$db_container_id" mysql --user=root --password=root -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

# Criação dos bancos
echo "📦 Criando banco de dados bagisto e bagisto_testing..."
docker exec "$db_container_id" mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS bagisto CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
docker exec "$db_container_id" mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS bagisto_testing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Instala o Bagisto ou faz pull se já existir
echo "🔄 Verificando se o Bagisto já está instalado..."
php_container_id=$(docker-compose ps -q bagisto-php)
echo "⬇️ Clonando o Bagisto..."
## docker exec "$php_container_id" git clone https://github.com/bagisto/bagisto /var/www/html/bagisto
docker exec -i "$php_container_id" bash -c "if [ -d /var/www/html/bagisto/.git ]; then cd /var/www/html/bagisto && git pull; else git clone https://github.com/bagisto/bagisto /var/www/html/bagisto; fi"

echo "📌 Fixando versão v2.3.0..."
docker exec -i "$php_container_id" bash -c "cd /var/www/html/bagisto && git reset --hard v2.3.0"

echo "📦 Instalando dependências..."
docker exec -i "$php_container_id" bash -c "cd /var/www/html/bagisto && composer install"

# Permissões
echo "🔧 Ajustando permissões..."
docker exec -i "$php_container_id" bash -c "cd /var/www/html/bagisto && mkdir -p storage bootstrap/cache && chmod -R 775 storage bootstrap/cache && chown -R www-data:www-data storage bootstrap/cache"

# Envs
echo "📄 Copiando arquivos .env..."
docker cp .configs/.env "$php_container_id":/var/www/html/bagisto/.env
docker cp .configs/.env.testing "$php_container_id":/var/www/html/bagisto/.env.testing

# Instalação final
echo "🚀 Rodando instalação do Bagisto..."
docker exec -i "$php_container_id" bash -c "cd /var/www/html/bagisto && php artisan bagisto:install --skip-env-check --skip-admin-creation"

echo "✅ Bagisto instalado com sucesso! Acesse: http://localhost:8888"
