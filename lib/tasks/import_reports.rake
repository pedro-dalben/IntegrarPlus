# frozen_string_literal: true

require 'csv'
require 'find'

namespace :documents do
  desc 'Relatório detalhado da última importação'
  task import_report: :environment do
    puts '📊 RELATÓRIO DETALHADO DA IMPORTAÇÃO'
    puts '=' * 60

    # Configurações
    csv_path = Rails.root.join('storage/importador/csv.csv')
    base_path = Rails.root.join('storage/importador')

    # Contadores
    found_files = []
    missing_files = []
    existing_docs = []

    # Mapeamentos
    category_mapping = {
      'Técnica' => 'tecnica',
      'Recursos Humanos' => 'recursos_humanos',
      'Administrativa' => 'administrativa',
      '' => 'geral',
      nil => 'geral'
    }

    type_mapping = {
      'TER' => 'termo',
      'FORM' => 'formulario',
      'DOC' => 'documento',
      'POP' => 'pop',
      'PGRS' => 'pgrs',
      'RI' => 'regimento_interno',
      'MAN' => 'manual',
      'PLAN' => 'planilha',
      'ANEX' => 'anexo',
      'COM' => 'documento',
      'FCH' => 'formulario',
      'CART' => 'cartilha',
      'REQ' => 'requisicao'
    }

    # Função para encontrar arquivos
    def find_files_for_document(base_path, doc_id, _doc_name)
      found_files = []

      Find.find(base_path) do |path|
        next unless File.file?(path)
        next if path.include?('csv.csv')

        filename = File.basename(path)

        # Buscar por ID do documento no nome do arquivo
        next unless filename.upcase.include?(doc_id.upcase)

        found_files << {
          path: path,
          filename: filename,
          mtime: File.mtime(path)
        }
      end

      # Retornar o arquivo mais recente se houver múltiplos
      found_files.max_by { |f| f[:mtime] }
    end

    # Função para determinar tipo baseado no ID
    def determine_document_type(doc_id, type_mapping)
      prefix = doc_id.match(/^([A-Z]+)/i)&.captures&.first&.upcase
      type_mapping[prefix] || 'outros'
    end

    # Processar CSV
    CSV.foreach(csv_path, headers: true, encoding: 'UTF-8') do |row|
      doc_id = row['ID do Documento']&.strip
      doc_name = row['Nome do Documento']&.strip
      csv_category = row['Categoria']&.strip
      row['Status']&.strip

      # Pular linhas vazias ou inválidas
      next if doc_id.blank? || doc_name.blank?
      next if doc_id.length < 3

      # Determinar tipo e categoria
      document_type = determine_document_type(doc_id, type_mapping)
      category = category_mapping[csv_category] || 'geral'

      # Verificar se documento já existe
      existing_doc = Document.find_by(title: doc_name)

      # Procurar arquivo
      file_info = find_files_for_document(base_path, doc_id, doc_name)

      if existing_doc
        existing_docs << {
          id: doc_id,
          name: doc_name,
          document_id: existing_doc.id,
          type: document_type,
          category: category,
          has_file: !file_info.nil?,
          file_path: file_info&.dig(:path)
        }
      elsif file_info.nil?
        missing_files << {
          id: doc_id,
          name: doc_name,
          type: document_type,
          category: category
        }
      else
        found_files << {
          id: doc_id,
          name: doc_name,
          type: document_type,
          category: category,
          file_path: file_info[:path],
          file_name: file_info[:filename],
          file_date: file_info[:mtime]
        }
      end
    end

    # Relatórios
    puts '📈 RESUMO GERAL:'
    puts '-' * 40
    puts "✅ Documentos com arquivos encontrados: #{found_files.count}"
    puts "📄 Documentos já existentes no sistema: #{existing_docs.count}"
    puts "❌ Arquivos não encontrados: #{missing_files.count}"
    puts "📊 Total de documentos no CSV: #{found_files.count + existing_docs.count + missing_files.count}"
    puts

    if existing_docs.any?
      puts '📄 DOCUMENTOS JÁ EXISTENTES NO SISTEMA:'
      puts '-' * 50
      existing_docs.each do |doc|
        puts "• #{doc[:id]} - #{doc[:name]}"
        puts "  ID no sistema: #{doc[:document_id]}"
        puts "  Tipo: #{doc[:type].humanize} | Categoria: #{doc[:category].humanize}"
        puts "  Arquivo disponível: #{doc[:has_file] ? '✅ Sim' : '❌ Não'}"
        puts "  Caminho: #{doc[:file_path]}" if doc[:has_file]
        puts
      end
    end

    if missing_files.any?
      puts '❌ ARQUIVOS NÃO ENCONTRADOS:'
      puts '-' * 50
      missing_files.each do |doc|
        puts "• #{doc[:id]} - #{doc[:name]}"
        puts "  Tipo esperado: #{doc[:type].humanize}"
        puts "  Categoria: #{doc[:category].humanize}"
        puts
      end
    end

    if found_files.any?
      puts '✅ ARQUIVOS DISPONÍVEIS PARA IMPORTAÇÃO:'
      puts '-' * 50
      found_files.each do |doc|
        puts "• #{doc[:id]} - #{doc[:name]}"
        puts "  Tipo: #{doc[:type].humanize} | Categoria: #{doc[:category].humanize}"
        puts "  Arquivo: #{doc[:file_name]}"
        puts "  Modificado em: #{doc[:file_date]}"
        puts
      end
    end

    puts '🎯 PRÓXIMOS PASSOS:'
    puts '-' * 40
    if missing_files.any?
      puts "1. Verificar se os #{missing_files.count} arquivos não encontrados estão em outras pastas"
      puts '2. Confirmar se esses documentos realmente existem'
    end

    if existing_docs.any?
      puts "3. Os #{existing_docs.count} documentos já existentes foram pulados para evitar duplicatas"
      puts '4. Se quiser reimportar, delete os documentos existentes primeiro'
    end

    if found_files.any?
      puts "5. #{found_files.count} novos documentos podem ser importados executando:"
      puts '   rake documents:import_from_csv'
    end
  end

  desc 'Verificar arquivos específicos por ID'
  task :check_file, [:doc_id] => :environment do |_t, args|
    unless args[:doc_id]
      puts '❌ Uso: rake documents:check_file[DOC_ID]'
      puts 'Exemplo: rake documents:check_file[POP001]'
      exit 1
    end

    doc_id = args[:doc_id].upcase
    base_path = Rails.root.join('storage/importador')

    puts "🔍 PROCURANDO ARQUIVOS PARA: #{doc_id}"
    puts '=' * 50

    found_files = []

    Find.find(base_path) do |path|
      next unless File.file?(path)
      next if path.include?('csv.csv')

      filename = File.basename(path)

      next unless filename.upcase.include?(doc_id)

      found_files << {
        path: path,
        filename: filename,
        mtime: File.mtime(path),
        size: File.size(path)
      }
    end

    if found_files.any?
      puts '✅ ARQUIVOS ENCONTRADOS:'
      puts '-' * 30
      found_files.sort_by { |f| f[:mtime] }.each_with_index do |file, index|
        puts "#{index + 1}. #{file[:filename]}"
        puts "   Caminho: #{file[:path]}"
        puts "   Modificado: #{file[:mtime]}"
        puts "   Tamanho: #{(file[:size] / 1024.0).round(2)} KB"
        puts
      end

      if found_files.many?
        latest = found_files.max_by { |f| f[:mtime] }
        puts '🎯 ARQUIVO MAIS RECENTE (será usado na importação):'
        puts "   #{latest[:filename]}"
        puts "   #{latest[:mtime]}"
      end
    else
      puts "❌ Nenhum arquivo encontrado para #{doc_id}"
      puts
      puts '💡 DICAS:'
      puts '- Verifique se o ID está correto'
      puts '- O arquivo pode estar em uma subpasta não verificada'
      puts '- O nome do arquivo pode não conter o ID exato'
    end
  end

  desc 'Listar documentos duplicados no sistema'
  task check_duplicates: :environment do
    puts '🔍 VERIFICANDO DOCUMENTOS DUPLICADOS'
    puts '=' * 50

    duplicates = Document.group(:title).having('COUNT(*) > 1').count

    if duplicates.any?
      puts '⚠️  DOCUMENTOS DUPLICADOS ENCONTRADOS:'
      puts '-' * 40

      duplicates.each do |title, count|
        puts "📄 #{title} (#{count} ocorrências)"
        docs = Document.where(title: title).order(:created_at)
        docs.each_with_index do |doc, index|
          puts "   #{index + 1}. ID: #{doc.id} | Criado: #{doc.created_at.strftime('%d/%m/%Y %H:%M')}"
          puts "      Tipo: #{doc.document_type.humanize} | Categoria: #{doc.category.humanize}"
        end
        puts
      end

      puts '💡 Para remover duplicatas, você pode:'
      puts '1. Manter apenas o documento mais recente'
      puts '2. Verificar se são realmente duplicatas ou versões diferentes'
    else
      puts '✅ Nenhum documento duplicado encontrado!'
    end
  end
end
