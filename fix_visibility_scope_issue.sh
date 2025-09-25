#!/bin/bash

echo "=== Corrigindo problema visibility_scope no VPS ==="

echo "1. Parando serviços (se aplicável)..."
sudo systemctl stop nginx || true
sudo systemctl stop puma || true

echo "2. Verificando status das migrações..."
RAILS_ENV=production bin/rails db:migrate:status | grep visibility

echo "3. Executando migrações pendentes..."
RAILS_ENV=production bin/rails db:migrate

echo "4. Verificando se a coluna existe no banco..."
RAILS_ENV=production bin/rails console -e "
puts '=== Verificando colunas da tabela events ==='
puts Event.column_names.grep(/visibility/)
puts '=== Verificando se Event.visibility_levels funciona ==='
puts Event.visibility_levels.keys rescue puts 'ERRO: Event.visibility_levels não funciona'
"

echo "5. Limpando todos os caches..."
RAILS_ENV=production bin/rails tmp:clear
rm -f db/schema_cache.yml
rm -f db/queue_schema_cache.yml
RAILS_ENV=production bin/rails db:schema:cache:clear
RAILS_ENV=production bin/rails db:schema:cache:dump

echo "6. Limpando cache do bootsnap..."
rm -rf tmp/cache/bootsnap*

echo "7. Reiniciando aplicação..."
touch tmp/restart.txt

echo "8. Recompilando assets..."
bin/rails assets:precompile RAILS_ENV=production || true

echo "9. Reiniciando serviços..."
sudo systemctl start puma || true
sudo systemctl start nginx || true

echo "10. Testando se o problema foi resolvido..."
RAILS_ENV=production bin/rails console -e "
puts '=== Teste final ==='
event = Event.new(
  title: 'Teste', 
  start_time: Time.current, 
  end_time: Time.current + 1.hour,
  event_type: :personal,
  visibility_level: :personal_private,
  professional_id: Professional.first&.id || 1,
  created_by_id: Professional.first&.id || 1
)
puts 'Event criado com sucesso!' if event.valid?
puts event.errors.full_messages unless event.valid?
"

echo "=== Correção concluída ==="
