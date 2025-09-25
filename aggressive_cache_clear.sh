#!/bin/bash

echo "=== LIMPEZA AGRESSIVA DE CACHE PARA VISIBILITY_SCOPE ==="

echo "1. Parando todos os serviços..."
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl stop puma 2>/dev/null || true
sudo systemctl stop sidekiq 2>/dev/null || true

echo "2. Executando migrações..."
RAILS_ENV=production bin/rails db:migrate

echo "3. Limpeza AGRESSIVA de todos os caches..."
# Limpar cache do Rails
RAILS_ENV=production bin/rails tmp:clear

# Remover TODOS os arquivos de cache
rm -rf tmp/cache/*
rm -rf tmp/pids/*
rm -rf tmp/sockets/*

# Remover caches específicos do schema
rm -f db/schema_cache.yml
rm -f db/queue_schema_cache.yml
rm -f db/structure.sql

# Limpar cache do bootsnap
rm -rf tmp/cache/bootsnap*

# Limpar cache do bundler
bundle exec rails tmp:clear

echo "4. Regenerando schema cache..."
RAILS_ENV=production bin/rails db:schema:cache:clear
RAILS_ENV=production bin/rails db:schema:cache:dump

echo "5. Verificando se a coluna existe no banco real..."
RAILS_ENV=production bin/rails runner "
puts '=== VERIFICAÇÃO DO BANCO REAL ==='
begin
  # Verificar colunas diretamente no banco
  columns = ActiveRecord::Base.connection.columns('events').map(&:name)
  visibility_cols = columns.select { |col| col.include?('visibility') }
  puts \"Colunas de visibility no banco: #{visibility_cols}\"
  
  if visibility_cols.include?('visibility_scope')
    puts '❌ PROBLEMA: Coluna visibility_scope ainda existe no banco!'
  elsif visibility_cols.include?('visibility_level')
    puts '✅ Coluna visibility_level existe no banco'
  else
    puts '❌ PROBLEMA: Nenhuma coluna de visibility encontrada!'
  end
  
  # Testar enum
  puts \"Event.visibility_levels: #{Event.visibility_levels.keys}\"
  
rescue => e
  puts \"❌ Erro: #{e.message}\"
end
"

echo "6. Limpando cache do sistema..."
# Limpar cache do sistema se possível
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1 || true

echo "7. Reiniciando aplicação..."
touch tmp/restart.txt

echo "8. Recompilando assets..."
RAILS_ENV=production bin/rails assets:precompile

echo "9. Reiniciando serviços..."
sudo systemctl start puma
sudo systemctl start nginx

echo "10. Teste final..."
RAILS_ENV=production bin/rails runner "
puts '=== TESTE FINAL ==='
begin
  professional = Professional.first
  if professional
    event = Event.new(
      title: 'Teste Final',
      start_time: Time.current,
      end_time: 1.hour.from_now,
      event_type: :personal,
      visibility_level: :personal_private,
      professional: professional,
      created_by: professional
    )
    
    if event.valid?
      puts '✅ SUCESSO: Event pode ser criado - PROBLEMA RESOLVIDO!'
    else
      puts '❌ Event ainda inválido:'
      event.errors.full_messages.each { |msg| puts \"  - #{msg}\" }
    end
  else
    puts 'ℹ️  Nenhum Professional encontrado para teste'
  end
rescue => e
  puts \"❌ ERRO no teste final: #{e.message}\"
  puts \"Stack: #{e.backtrace.first(3).join('\n')}\"
end
"

echo "=== LIMPEZA AGRESSIVA CONCLUÍDA ==="
