#!/usr/bin/env ruby

puts '=== DIAGNÓSTICO SIMPLES DO PROBLEMA VISIBILITY_SCOPE ==='

# Verificar se estamos no diretório correto
puts "Diretório atual: #{Dir.pwd}"

# Verificar se o arquivo de configuração do banco existe
database_config = File.join(Dir.pwd, 'config', 'database.yml')
if File.exist?(database_config)
  puts '✅ Arquivo database.yml encontrado'
else
  puts '❌ Arquivo database.yml não encontrado'
  exit 1
end

# Verificar se o schema existe
schema_file = File.join(Dir.pwd, 'db', 'schema.rb')
if File.exist?(schema_file)
  puts '✅ Arquivo schema.rb encontrado'

  # Verificar se a coluna visibility_level existe no schema
  schema_content = File.read(schema_file)
  if schema_content.include?('visibility_level')
    puts '✅ Coluna visibility_level encontrada no schema.rb'
  else
    puts '❌ Coluna visibility_level NÃO encontrada no schema.rb'
  end

  if schema_content.include?('visibility_scope')
    puts '❌ PROBLEMA: Coluna visibility_scope ainda existe no schema.rb'
  else
    puts '✅ Coluna visibility_scope não encontrada no schema.rb (correto)'
  end
else
  puts '❌ Arquivo schema.rb não encontrado'
end

# Verificar migrações
migrations_dir = File.join(Dir.pwd, 'db', 'migrate')
if Dir.exist?(migrations_dir)
  puts '✅ Diretório de migrações encontrado'

  # Procurar por migrações relacionadas a visibility
  migration_files = Dir.glob(File.join(migrations_dir, '*visibility*'))
  puts "Migrações relacionadas a visibility: #{migration_files.length}"

  migration_files.each do |file|
    puts "  - #{File.basename(file)}"
  end
else
  puts '❌ Diretório de migrações não encontrado'
end

# Verificar se há arquivos de cache
cache_files = [
  'db/schema_cache.yml',
  'db/queue_schema_cache.yml',
  'tmp/cache'
]

cache_files.each do |cache_file|
  cache_path = File.join(Dir.pwd, cache_file)
  if File.exist?(cache_path) || Dir.exist?(cache_path)
    puts "✅ Cache encontrado: #{cache_file}"
  else
    puts "ℹ️  Cache não encontrado: #{cache_file}"
  end
end

puts "\n=== RECOMENDAÇÕES ==="
puts '1. Execute: RAILS_ENV=production bin/rails db:migrate'
puts '2. Execute: RAILS_ENV=production bin/rails db:schema:cache:clear'
puts '3. Execute: RAILS_ENV=production bin/rails tmp:clear'
puts '4. Execute: touch tmp/restart.txt'

puts "\n=== DIAGNÓSTICO SIMPLES CONCLUÍDO ==="
