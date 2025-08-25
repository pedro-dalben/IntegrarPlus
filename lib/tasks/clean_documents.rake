# frozen_string_literal: true

namespace :documents do
  desc 'Apagar todos os documentos do sistema'
  task clean_all: :environment do
    puts '🗑️  INICIANDO LIMPEZA DE TODOS OS DOCUMENTOS'
    puts '=' * 60

    # Contar documentos antes
    total_documents = Document.count
    total_versions = DocumentVersion.count

    puts "📊 Documentos encontrados: #{total_documents}"
    puts "📊 Versões encontradas: #{total_versions}"
    puts

    if total_documents.zero?
      puts '✅ Nenhum documento encontrado para apagar.'
      return
    end

    puts '⚠️  ATENÇÃO: Esta operação irá apagar TODOS os documentos e suas versões!'
    puts '⚠️  Esta ação é IRREVERSÍVEL!'
    puts

    # Em ambiente de desenvolvimento, prosseguir automaticamente
    # Em produção, seria necessário confirmação manual
    if Rails.env.development?
      puts '🔄 Prosseguindo com a limpeza (ambiente de desenvolvimento)...'
    else
      puts '❌ Operação cancelada (não é ambiente de desenvolvimento)'
      return
    end

    begin
      # Apagar versões primeiro (devido às foreign keys)
      puts '🗑️  Apagando versões de documentos...'
      DocumentVersion.destroy_all

      # Apagar documentos
      puts '🗑️  Apagando documentos...'
      Document.destroy_all

      # Verificar se foi tudo apagado
      remaining_documents = Document.count
      remaining_versions = DocumentVersion.count

      puts
      puts '✅ LIMPEZA CONCLUÍDA!'
      puts "📊 Documentos restantes: #{remaining_documents}"
      puts "📊 Versões restantes: #{remaining_versions}"

      if remaining_documents.zero? && remaining_versions.zero?
        puts '🎉 Todos os documentos foram apagados com sucesso!'
      else
        puts '⚠️  Alguns documentos podem não ter sido apagados.'
      end
    rescue StandardError => e
      puts "❌ ERRO durante a limpeza: #{e.message}"
      puts "Detalhes: #{e.backtrace.first}"
    end
  end

  desc 'Apagar todos os documentos e fazer importação limpa'
  task clean_and_import: :environment do
    puts '🔄 LIMPEZA E IMPORTAÇÃO COMPLETA'
    puts '=' * 60

    # Executar limpeza
    Rake::Task['documents:clean_all'].invoke

    puts
    puts '⏳ Aguardando 2 segundos...'
    sleep 2

    # Executar importação
    puts
    puts '🚀 INICIANDO IMPORTAÇÃO APÓS LIMPEZA'
    puts '=' * 60

    Rake::Task['documents:import_from_csv'].invoke
  end
end
