#!/bin/bash

echo "=== CORREÇÃO RÁPIDA DO PROBLEMA VISIBILITY_SCOPE ==="

echo "1. Verificando se estamos no diretório correto..."
if [ ! -f "config/database.yml" ]; then
    echo "❌ Não estamos no diretório correto do Rails"
    exit 1
fi
echo "✅ Diretório correto"

echo "2. Executando migração..."
RAILS_ENV=production bin/rails db:migrate

echo "3. Limpando caches..."
RAILS_ENV=production bin/rails tmp:clear
rm -f db/schema_cache.yml
rm -f db/queue_schema_cache.yml
RAILS_ENV=production bin/rails db:schema:cache:clear

echo "4. Verificando colunas da tabela events..."
RAILS_ENV=production bin/rails runner "
puts '=== VERIFICANDO COLUNAS ==='
puts Event.column_names.grep(/visibility/)
puts '=== TESTANDO ENUM ==='
puts Event.visibility_levels.keys rescue puts 'ERRO no enum'
"

echo "5. Reiniciando aplicação..."
touch tmp/restart.txt

echo "6. Testando criação de Event..."
RAILS_ENV=production bin/rails runner "
begin
  professional = Professional.first
  if professional
    event = Event.new(
      title: 'Teste',
      start_time: Time.current,
      end_time: 1.hour.from_now,
      event_type: :personal,
      visibility_level: :personal_private,
      professional: professional,
      created_by: professional
    )
    if event.valid?
      puts '✅ Event pode ser criado - PROBLEMA RESOLVIDO!'
    else
      puts '❌ Event inválido:'
      puts event.errors.full_messages
    end
  else
    puts 'ℹ️  Nenhum Professional encontrado para teste'
  end
rescue => e
  puts '❌ Erro ao criar Event:'
  puts e.message
end
"

echo "=== CORREÇÃO CONCLUÍDA ==="
