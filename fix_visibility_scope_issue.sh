#!/bin/bash

echo "=== Corrigindo problema visibility_scope no VPS ==="

echo "1. Verificando status das migrações..."
rails db:migrate:status | grep visibility

echo "2. Executando migrações pendentes..."
rails db:migrate

echo "3. Limpando caches..."
rails tmp:clear
rm -f db/schema_cache.yml
rails db:schema:cache:clear
rails db:schema:cache:dump

echo "4. Limpando cache do bootsnap..."
rm -rf tmp/cache/bootsnap*

echo "5. Verificando se a coluna foi renomeada..."
rails console -e "puts Event.column_names.grep(/visibility/)"

echo "=== Correção concluída ==="
