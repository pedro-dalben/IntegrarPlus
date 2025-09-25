#!/usr/bin/env ruby

puts '=== DIAGNÓSTICO DO PROBLEMA VISIBILITY_SCOPE ==='

# Verificar se estamos no diretório correto
puts "Diretório atual: #{Dir.pwd}"

# Definir ambiente de produção
ENV['RAILS_ENV'] = 'production'

# Verificar se o Rails pode ser carregado
begin
  require_relative 'config/environment'
  puts '✅ Rails carregado com sucesso (ambiente: production)'
rescue StandardError => e
  puts "❌ Erro ao carregar Rails: #{e.message}"
  exit 1
end

# Verificar colunas da tabela events
puts "\n=== VERIFICANDO COLUNAS DA TABELA EVENTS ==="
begin
  columns = Event.column_names
  visibility_columns = columns.grep(/visibility/)
  puts "Colunas relacionadas a visibility: #{visibility_columns}"

  if visibility_columns.include?('visibility_scope')
    puts '❌ PROBLEMA: Coluna visibility_scope ainda existe!'
  elsif visibility_columns.include?('visibility_level')
    puts '✅ Coluna visibility_level existe'
  else
    puts '❌ PROBLEMA: Nenhuma coluna de visibility encontrada!'
  end
rescue StandardError => e
  puts "❌ Erro ao verificar colunas: #{e.message}"
end

# Verificar enum do modelo
puts "\n=== VERIFICANDO ENUM DO MODELO EVENT ==="
begin
  puts "Event.visibility_levels: #{Event.visibility_levels}"
  puts '✅ Enum visibility_levels funciona'
rescue StandardError => e
  puts "❌ Erro no enum: #{e.message}"
end

# Verificar se podemos criar um Event
puts "\n=== TESTANDO CRIAÇÃO DE EVENT ==="
begin
  professional = Professional.first
  if professional
    event = Event.new(
      title: 'Teste Diagnóstico',
      start_time: Time.current,
      end_time: 1.hour.from_now,
      event_type: :personal,
      visibility_level: :personal_private,
      professional: professional,
      created_by: professional
    )

    if event.valid?
      puts '✅ Event pode ser criado (não foi salvo)'
    else
      puts "❌ Event inválido: #{event.errors.full_messages}"
    end
  else
    puts '❌ Nenhum Professional encontrado para teste'
  end
rescue StandardError => e
  puts "❌ Erro ao criar Event: #{e.message}"
  puts "Stack trace: #{e.backtrace.first(5)}"
end

# Verificar migrações
puts "\n=== VERIFICANDO MIGRAÇÕES ==="
begin
  pending = ActiveRecord::Base.connection.migration_context.needs_migration?
  if pending
    puts '❌ Há migrações pendentes!'
  else
    puts '✅ Todas as migrações foram executadas'
  end
rescue StandardError => e
  puts "❌ Erro ao verificar migrações: #{e.message}"
end

# Verificar schema atual
puts "\n=== VERIFICANDO SCHEMA DO BANCO ==="
begin
  schema = ActiveRecord::Base.connection.schema_cache.columns(:events)
  visibility_cols = schema.select { |col| col.name.include?('visibility') }
  puts 'Colunas de visibility no schema cache:'
  visibility_cols.each do |col|
    puts "  - #{col.name} (#{col.type})"
  end
rescue StandardError => e
  puts "❌ Erro ao verificar schema: #{e.message}"
end

# Verificar se há queries com visibility_scope
puts "\n=== PROCURANDO REFERÊNCIAS A VISIBILITY_SCOPE ==="
begin
  # Verificar logs recentes
  log_file = Rails.root.join('log/production.log')
  if File.exist?(log_file)
    recent_logs = begin
      `tail -100 #{log_file} | grep -i visibility_scope`
    rescue StandardError
      ''
    end
    if recent_logs.empty?
      puts '✅ Nenhuma referência a visibility_scope nos logs recentes'
    else
      puts '❌ Encontradas referências nos logs:'
      puts recent_logs
    end
  else
    puts 'ℹ️  Arquivo de log de produção não encontrado'
  end
rescue StandardError => e
  puts "❌ Erro ao verificar logs: #{e.message}"
end

puts "\n=== DIAGNÓSTICO CONCLUÍDO ==="
