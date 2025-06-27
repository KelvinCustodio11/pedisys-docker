#!/bin/bash

# Parar e remover containers antigos (com volumes)
docker-compose down -v

# Build e up dos containers
docker-compose build && docker-compose up -d

# Obter IDs dos containers
apache_container_id=$(docker-compose ps -q bagisto-php)
db_container_id=$(docker-compose ps -q bagisto-mysql)

# Verificações
if [ -z "$apache_container_id" ]; then
    echo "❌ ERRO: Container PHP (bagisto-php) não encontrado!"
    docker ps --format "table {{.Names}}\t{{.Image}}"
    exit 1
fi

if [ -z "$db_container_id" ]; then
    echo "❌ ERRO: Container MySQL (bagisto-mysql) não encontrado!"
    docker ps --format "table {{.Names}}\t{{.Image}}"
    exit 1
fi

# Esperar conexão com MySQL
echo "⏳ Aguardando conexão com o MySQL..."
while ! docker exec ${db_container_id} mysql --user=root --password=root -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

# Criar bancos
echo "🛠️  Criando banco de dados 'bagisto'..."
docker exec ${db_container_id} mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS bagisto CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "🛠️  Criando banco de dados 'bagisto_testing'..."
docker exec ${db_container_id} mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS bagisto_testing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Clonar o projeto
echo "⬇️  Clonando repositório Bagisto..."
docker exec -i ${apache_container_id} bash -c "cd /var/www/html && git clone https://github.com/bagisto/bagisto"

# Checar se o clone deu certo
docker exec -i ${apache_container_id} bash -c "test -d /var/www/html/bagisto || (echo '❌ Clone falhou' && exit 1)"

# Checkout versão estável
echo "🔄 Alternando para versão v2.3.0..."
docker exec -i ${apache_container_id} bash -c "cd /var/www/html/bagisto && git reset --hard v2.3.0"

# Instalar dependências PHP
echo "📦 Instalando dependências via Composer..."
docker exec -i ${apache_container_id} bash -c "cd /var/www/html/bagisto && composer install"

# Permissões
echo "🔧 Ajustando permissões..."
docker exec -i ${apache_container_id} bash -c "cd /var/www/html/bagisto && mkdir -p storage bootstrap/cache && chmod -R 775 storage bootstrap/cache && chown -R www-data:www-data storage bootstrap/cache"

# Copiar arquivos .env
echo "📁 Copiando arquivos de configuração .env..."
docker cp .configs/.env ${apache_container_id}:/var/www/html/bagisto/.env
docker cp .configs/.env.testing ${apache_container_id}:/var/www/html/bagisto/.env.testing

# Instalar o Bagisto
echo "🚀 Instalando o Bagisto..."
docker exec -i ${apache_container_id} bash -c "cd /var/www/html/bagisto && php artisan bagisto:install --skip-env-check --skip-admin-creation"

echo "✅ Bagisto instalado com sucesso! Acesse: http://localhost:8888"
