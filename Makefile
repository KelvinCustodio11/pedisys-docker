# Sobe os containers
up:
	docker-compose up -d

# Derruba os containers e remove volumes
down:
	docker-compose down -v

# Reconstrói os containers
build:
	docker-compose build

# Executa o script de setup completo
setup:
	sh setup.sh

# Acessa o bash do container PHP
bash:
	docker exec -it $$(docker-compose ps -q bagisto-php) bash

# Mostra logs do container PHP
logs:
	docker-compose logs -f bagisto-php

# Roda as migrations
migrate:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan migrate"

# Instala dependências com composer
composer-install:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && composer install"

# Roda o artisan serve (opcional, se quiser testar fora do nginx)
artisan-serve:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan serve --host=0.0.0.0 --port=8000"

# Limpa o cache do Laravel
cache-clear:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan cache:clear"

# Limpa o cache de configuração do Laravel
config-cache-clear:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan config:clear"

# Limpa o cache de rotas do Laravel
route-cache-clear:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan route:clear"

# Limpa o cache de views do Laravel
view-cache-clear:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan view:clear"

# Limpa o cache de eventos do Laravel
event-cache-clear:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan event:clear"

# Cria pedido de teste via Tinker
create-order:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$orderRepo = app(\\"Webkul\\\\Sales\\\\Repositories\\\\OrderRepository\\"); \
	\$customer = Webkul\\Customer\\Models\\Customer::first(); \
	\$cart = Webkul\\Checkout\\Facades\\Cart::create(\$customer->id); \
	\$product = Webkul\\Product\\Models\\Product::first(); \
	Cart::addProduct(\$product->id, [\\"quantity\\" => 1]); \
	Cart::collectTotals(); \
	\$order = Cart::save(); \
	echo \\"Pedido criado com ID: {\$order->id} e total: {\$order->grand_total} \\";'"

# Cria um usuário de teste via Tinker
create-user:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$user = new Webkul\\User\\Models\\Admin; \
	\$user->name = \\"Test User\\"; \
	\$user->email = \\"test@example.com\\"; \
	\$user->password = bcrypt(\\"password\\"); \
	\$user->save(); \
	echo \\"Usuário criado com ID: {\$user->id} e email: {\$user->email} \\";'"
# Cria um produto de teste via Tinker
create-product:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$product = new Webkul\\Product\\Models\\Product; \
	\$product->name = \\"Test Product\\"; \
	\$product->sku = \\"test-product\\"; \
	\$product->price = 100; \
	\$product->type = \\"simple\\"; \
	\$product->save(); \
	echo \\"Produto criado com ID: {\$product->id} e SKU: {\$product->sku} \\";'"
# Cria uma categoria de teste via Tinker
create-category:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$category = new Webkul\\Category\\Models\\Category; \
	\$category->name = \\"Test Category\\"; \
	\$category->slug = \\"test-category\\"; \
	\$category->save(); \
	echo \\"Categoria criada com ID: {\$category->id} e slug: {\$category->slug} \\";'"
# Cria um atributo de teste via Tinker
create-attribute:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$attribute = new Webkul\\Attribute\\Models\\Attribute; \
	\$attribute->name = \\"Test Attribute\\"; \
	\$attribute->code = \\"test_attribute\\"; \
	\$attribute->type = \\"text\\"; \
	\$attribute->save(); \
	echo \\"Atributo criado com ID: {\$attribute->id} e código: {\$attribute->code} \\";'"
# Cria uma opção de atributo de teste via Tinker
create-attribute-option:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$option = new Webkul\\Attribute\\Models\\AttributeOption; \
	\$option->attribute_id = 1; \
	\$option->label = \\"Test Option\\"; \
	\$option->value = \\"test_option\\"; \
	\$option->save(); \
	echo \\"Opção de atributo criada com ID: {\$option->id} e label: {\$option->label} \\";'"
# Cria um endereço de teste via Tinker
create-address:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$address = new Webkul\\Customer\\Models\\Address; \
	\$address->customer_id = 1; \
	\$address->first_name = \\"Test\\"; \
	\$address->last_name = \\"User\\"; \
	\$address->address1 = \\"123 Test St\\"; \
	\$address->city = \\"Test City\\"; \
	\$address->country = \\"US\\"; \
	\$address->postcode = \\"12345\\"; \
	\$address->save(); \
	echo \\"Endereço criado com ID: {\$address->id} e nome: {\$address->first_name} {\$address->last_name} \\";'"
# Cria um carrinho de compras de teste via Tinker
create-cart:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$cart = new Webkul\\Checkout\\Models\\Cart; \
	\$cart->customer_id = 1; \
	\$cart->save(); \
	echo \\"Carrinho criado com ID: {\$cart->id} \\";'"
# Cria um pedido de teste via Tinker
create-order-tinker:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$order = new Webkul\\Sales\\Models\\Order; \
	\$order->customer_id = 1; \
	\$order->status = \\"pending\\"; \
	\$order->grand_total = 100; \
	\$order->save(); \
	echo \\"Pedido criado com ID: {\$order->id} e total: {\$order->grand_total} \\";'"
# Cria um produto de teste via Tinker
create-product-tinker:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$product = new Webkul\\Product\\Models\\Product; \
	\$product->name = \\"Test Product\\"; \
	\$product->sku = \\"test-product\\"; \
	\$product->price = 100; \
	\$product->type = \\"simple\\"; \
	\$product->save(); \
	echo \\"Produto criado com ID: {\$product->id} e SKU: {\$product->sku} \\";'"
# Cria uma categoria de teste via Tinker
create-category-tinker:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$category = new Webkul\\Category\\Models\\Category; \
	\$category->name = \\"Test Category\\"; \
	\$category->slug = \\"test-category\\"; \
	\$category->save(); \
	echo \\"Categoria criada com ID: {\$category->id} e slug: {\$category->slug} \\";'"
# Cria um atributo de teste via Tinker
create-attribute-tinker:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$attribute = new Webkul\\Attribute\\Models\\Attribute; \
	\$attribute->name = \\"Test Attribute\\"; \
	\$attribute->code = \\"test_attribute\\"; \
	\$attribute->type = \\"text\\"; \
	\$attribute->save(); \
	echo \\"Atributo criado com ID: {\$attribute->id} e código: {\$attribute->code} \\";'"		
# Cria uma opção de atributo de teste via Tinker
create-attribute-option-tinker:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$option = new Webkul\\Attribute\\Models\\AttributeOption; \
	\$option->attribute_id = 1; \
	\$option->label = \\"Test Option\\"; \
	\$option->value = \\"test_option\\"; \
	\$option->save(); \
	echo \\"Opção de atributo criada com ID: {\$option->id} e label: {\$option->label} \\";'"
# Cria um endereço de teste via Tinker
create-address-tinker:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$address = new Webkul\\Customer\\Models\\Address; \
	\$address->customer_id = 1; \
	\$address->first_name = \\"Test\\"; \
	\$address->last_name = \\"User\\"; \
	\$address->address1 = \\"123 Test St\\"; \
	\$address->city = \\"Test City\\"; \
	\$address->country = \\"US\\"; \
	\$address->postcode = \\"12345\\"; \
	\$address->save(); \
	echo \\"Endereço criado com ID: {\$address->id} e nome: {\$address->first_name} {\$address->last_name} \\";'"
# Cria um carrinho de compras de teste via Tinker
create-cart-tinker:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$cart = new Webkul\\Checkout\\Models\\Cart; \
	\$cart->customer_id = 1; \
	\$cart->save(); \
	echo \\"Carrinho criado com ID: {\$cart->id} \\";'"

create-order-full:
	docker exec -i $$(docker-compose ps -q bagisto-php) bash -c "cd /var/www/html/bagisto && php artisan tinker --execute '\
	\$customer = Webkul\\Customer\\Models\\Customer::first(); \
	\$product = Webkul\\Product\\Models\\Product::first(); \
	\
	\$cart = Webkul\\Checkout\\Facades\\Cart::create(\$customer->id); \
	Webkul\\Checkout\\Facades\\Cart::addProduct(\$product->id, [\"quantity\" => 1]); \
	\
	\$address = [ \
	    \"first_name\" => \$customer->first_name, \
	    \"last_name\" => \$customer->last_name, \
	    \"email\" => \$customer->email, \
	    \"address1\" => [\"Rua Exemplo 123\"], \
	    \"city\" => \"São Paulo\", \
	    \"state\" => \"SP\", \
	    \"country\" => \"BR\", \
	    \"postcode\" => \"01000-000\", \
	    \"phone\" => \"11999999999\", \
	    \"use_for_shipping\" => true \
	]; \
	Webkul\\Checkout\\Facades\\Cart::setBillingAddress(\$address); \
	Webkul\\Checkout\\Facades\\Cart::setShippingAddress(\$address); \
	\
	Webkul\\Checkout\\Facades\\Cart::collectTotals(); \
	Webkul\\Checkout\\Facades\\Cart::save(); \
	Webkul\\Checkout\\Facades\\Cart::setShippingMethod(\"flatrate_flatrate\"); \
	Webkul\\Checkout\\Facades\\Cart::setPaymentMethod(\"cashondelivery\"); \
	\
	\$order = Webkul\\Checkout\\Facades\\Cart::createOrder(); \
	echo \"Pedido criado com ID: {\$order->id} | Total: {\$order->grand_total}\";'"
