require 'csv'
require 'find'

namespace :documents do
  desc "Importar documentos do CSV e arquivos das pastas"
  task import_from_csv: :environment do
    # Configurar arquivo de log
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    log_path = Rails.root.join('storage', 'importador', "import_log_#{timestamp}.txt")

    def log_message(message, log_file = nil)
      puts message
      if log_file
        log_file.puts "[#{Time.current.strftime('%Y-%m-%d %H:%M:%S')}] #{message.gsub(/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]/, '')}"
      end
    end

    log_file = File.open(log_path, 'w')
    log_file.puts "RELATÓRIO DE IMPORTAÇÃO DE DOCUMENTOS"
    log_file.puts "=" * 60
    log_file.puts "Data/Hora: #{Time.current.strftime('%d/%m/%Y às %H:%M:%S')}"
    log_file.puts "=" * 60
    log_file.puts

    log_message("🚀 INICIANDO IMPORTAÇÃO DE DOCUMENTOS", log_file)
    log_message("="*60, log_file)

    # Configurações
    csv_path = Rails.root.join('storage', 'importador', 'csv.csv')
    base_path = Rails.root.join('storage', 'importador')

    # Contadores
    imported_count = 0
    skipped_count = 0
    error_count = 0

    # Relatórios
    imported_docs = []
    skipped_docs = []
    error_docs = []
    missing_files = []

    # Buscar autor padrão
    author = Professional.first
    unless author
      log_message("❌ ERRO: Nenhum profissional encontrado. Crie um profissional primeiro.", log_file)
      log_file.close
      exit 1
    end

    log_message("📋 Autor padrão: #{author.full_name}", log_file)
    log_message("📁 Diretório base: #{base_path}", log_file)
    log_message("📄 Arquivo de log: #{log_path}", log_file)
    log_message("", log_file)

    # Ler CSV
    unless File.exist?(csv_path)
      log_message("❌ ERRO: Arquivo CSV não encontrado em #{csv_path}", log_file)
      log_file.close
      exit 1
    end

    # Mapeamento de categorias do CSV para o sistema
    category_mapping = {
      'Técnica' => 'tecnica',
      'Recursos Humanos' => 'recursos_humanos',
      'Administrativa' => 'administrativa',
      '' => 'geral',
      nil => 'geral'
    }

    # Mapeamento de tipos baseado no prefixo do ID
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
    def find_files_for_document(base_path, doc_id, doc_name)
      found_files = []

      # Buscar em toda a estrutura de arquivos
      Find.find(base_path) do |path|
        next unless File.file?(path)
        next if path.include?('csv.csv')

        filename = File.basename(path)

        # Buscar por ID exato no início do nome do arquivo
        if filename.upcase.start_with?(doc_id.upcase)
          found_files << {
            path: path,
            filename: filename,
            mtime: File.mtime(path)
          }
        else
          # Para POPs com padrão POP0010 -> POP010, remover um zero
          if doc_id.match(/^POP0(\d{3})$/i)
            alternative_id = "POP#{$1}"
            if filename.upcase.start_with?(alternative_id.upcase)
              found_files << {
                path: path,
                filename: filename,
                mtime: File.mtime(path)
              }
            end
          end
        end
      end

      # Se não encontrou nada, tentar busca mais ampla
      if found_files.empty?
        Find.find(base_path) do |path|
          next unless File.file?(path)
          next if path.include?('csv.csv')

          filename = File.basename(path)

          # Buscar por ID do documento no nome do arquivo (busca mais ampla)
          if filename.upcase.include?(doc_id.upcase)
            found_files << {
              path: path,
              filename: filename,
              mtime: File.mtime(path)
            }
          end
        end
      end

      # Retornar o arquivo mais recente se houver múltiplos
      found_files.sort_by { |f| f[:mtime] }.last
    end

    # Função para determinar tipo baseado no ID
    def determine_document_type(doc_id, type_mapping)
      prefix = doc_id.match(/^([A-Z]+)/i)&.captures&.first&.upcase
      type_mapping[prefix] || 'outros'
    end

    # Função para determinar content type
    def get_content_type(file_path)
      extension = File.extname(file_path).downcase
      case extension
      when '.pdf'
        'application/pdf'
      when '.docx'
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      when '.doc'
        'application/msword'
      when '.xlsx'
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      when '.xls'
        'application/vnd.ms-excel'
      when '.ppt'
        'application/vnd.ms-powerpoint'
      when '.pptx'
        'application/vnd.openxmlformats-officedocument.presentationml.presentation'
      when '.jpg', '.jpeg'
        'image/jpeg'
      when '.png'
        'image/png'
      else
        'application/octet-stream'
      end
    end

    # Processar CSV
    CSV.foreach(csv_path, headers: true, encoding: 'UTF-8') do |row|
      doc_id = row['ID do Documento']&.strip
      doc_name = row['Nome do Documento']&.strip
      csv_category = row['Categoria']&.strip
      status = row['Status']&.strip

      # Pular linhas vazias ou inválidas
      next if doc_id.blank? || doc_name.blank?
      next if doc_id.length < 3 # IDs muito curtos provavelmente são headers

      log_message("📄 Processando: #{doc_id} - #{doc_name}", log_file)

      begin
        # Determinar tipo e categoria
        document_type = determine_document_type(doc_id, type_mapping)
        category = category_mapping[csv_category] || 'geral'

        # Verificar se o tipo é válido
        unless Document.document_types.key?(document_type)
          log_message("   ⚠️  Tipo '#{document_type}' não reconhecido, usando 'outros'", log_file)
          document_type = 'outros'
        end

        # Verificar se a categoria é válida
        unless Document.categories.key?(category)
          log_message("   ⚠️  Categoria '#{category}' não reconhecida, usando 'geral'", log_file)
          category = 'geral'
        end

        # Procurar arquivo
        file_info = find_files_for_document(base_path, doc_id, doc_name)

        if file_info.nil?
          log_message("   ❌ Arquivo não encontrado", log_file)
          missing_files << {
            id: doc_id,
            name: doc_name,
            type: document_type,
            category: category
          }
          skipped_count += 1
          next
        end

        log_message("   📁 Arquivo encontrado: #{file_info[:filename]}", log_file)
        log_message("   📅 Modificado em: #{file_info[:mtime]}", log_file)

        # Verificar se documento já existe
        existing_doc = Document.find_by(title: doc_name)
        if existing_doc
          log_message("   ⚠️  Documento já existe, pulando...", log_file)
          skipped_docs << {
            id: doc_id,
            name: doc_name,
            reason: 'Documento já existe',
            existing_id: existing_doc.id
          }
          skipped_count += 1
          next
        end

        # Criar documento
        document = Document.create!(
          title: doc_name,
          document_type: document_type,
          category: category,
          author: author,
          status: status == 'Finalizado' ? :liberado : :aguardando_revisao,
          current_version: "1.0"
        )

        # Fazer upload do arquivo
        file_path = file_info[:path]
        File.open(file_path, 'rb') do |file|
          # Criar um objeto que simula um upload
          uploaded_file = ActionDispatch::Http::UploadedFile.new(
            tempfile: file,
            filename: File.basename(file_path),
            type: get_content_type(file_path)
          )

          document.create_new_version(uploaded_file, author, 'Versão importada do sistema legado')
        end

        log_message("   ✅ Importado com sucesso! ID: #{document.id}", log_file)

        imported_docs << {
          id: doc_id,
          name: doc_name,
          document_id: document.id,
          type: document_type,
          category: category,
          file_path: file_info[:path]
        }
        imported_count += 1

      rescue => e
        log_message("   ❌ ERRO: #{e.message}", log_file)
        error_docs << {
          id: doc_id,
          name: doc_name,
          error: e.message
        }
        error_count += 1
      end

      log_message("", log_file)
    end

    # Relatório final
    log_message("="*60, log_file)
    log_message("📊 RELATÓRIO FINAL DA IMPORTAÇÃO", log_file)
    log_message("="*60, log_file)
    log_message("✅ Documentos importados: #{imported_count}", log_file)
    log_message("⚠️  Documentos pulados: #{skipped_count}", log_file)
    log_message("❌ Erros: #{error_count}", log_file)
    log_message("📁 Arquivos não encontrados: #{missing_files.count}", log_file)
    log_message("", log_file)

    if imported_docs.any?
      log_message("✅ DOCUMENTOS IMPORTADOS COM SUCESSO:", log_file)
      log_message("-" * 50, log_file)
      imported_docs.each do |doc|
        log_message("• #{doc[:id]} - #{doc[:name]}", log_file)
        log_message("  Tipo: #{doc[:type].humanize} | Categoria: #{doc[:category].humanize}", log_file)
        log_message("  ID no sistema: #{doc[:document_id]}", log_file)
        log_message("  Arquivo: #{File.basename(doc[:file_path])}", log_file)
        log_message("", log_file)
      end
    end

    if skipped_docs.any?
      log_message("⚠️  DOCUMENTOS PULADOS:", log_file)
      log_message("-" * 50, log_file)
      skipped_docs.each do |doc|
        log_message("• #{doc[:id]} - #{doc[:name]}", log_file)
        log_message("  Motivo: #{doc[:reason]}", log_file)
        log_message("  ID existente: #{doc[:existing_id]}", log_file) if doc[:existing_id]
        log_message("", log_file)
      end
    end

    if missing_files.any?
      log_message("📁 ARQUIVOS NÃO ENCONTRADOS:", log_file)
      log_message("-" * 50, log_file)
      missing_files.each do |doc|
        log_message("• #{doc[:id]} - #{doc[:name]}", log_file)
        log_message("  Tipo esperado: #{doc[:type].humanize}", log_file)
        log_message("  Categoria: #{doc[:category].humanize}", log_file)
        log_message("", log_file)
      end
    end

    if error_docs.any?
      log_message("❌ ERROS DURANTE A IMPORTAÇÃO:", log_file)
      log_message("-" * 50, log_file)
      error_docs.each do |doc|
        log_message("• #{doc[:id]} - #{doc[:name]}", log_file)
        log_message("  Erro: #{doc[:error]}", log_file)
        log_message("", log_file)
      end
    end

    # Finalizar log
    log_message("🎉 IMPORTAÇÃO CONCLUÍDA!", log_file)
    log_message("", log_file)
    log_message("=" * 60, log_file)
    log_message("Arquivo de log salvo em: #{log_path}", log_file)
    log_file.close

    puts "📄 Log detalhado salvo em: #{log_path}"
  end

  desc "Listar arquivos disponíveis para importação"
  task list_import_files: :environment do
    base_path = Rails.root.join('storage', 'importador')

    puts "📁 ARQUIVOS DISPONÍVEIS PARA IMPORTAÇÃO"
    puts "="*60

    file_count = 0

    Find.find(base_path) do |path|
      next unless File.file?(path)
      next if path.include?('csv.csv')

      relative_path = path.sub("#{base_path}/", '')
      puts "• #{relative_path}"
      file_count += 1
    end

    puts
    puts "📊 Total de arquivos encontrados: #{file_count}"
  end

  desc "Verificar mapeamento de tipos e categorias do CSV"
  task check_csv_mapping: :environment do
    csv_path = Rails.root.join('storage', 'importador', 'csv.csv')

    puts "🔍 VERIFICAÇÃO DE MAPEAMENTO DO CSV"
    puts "="*60

    # Contadores
    types_found = Hash.new(0)
    categories_found = Hash.new(0)
    unmapped_types = []

    # Mapeamentos
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

    category_mapping = {
      'Técnica' => 'tecnica',
      'Recursos Humanos' => 'recursos_humanos',
      'Administrativa' => 'administrativa',
      '' => 'geral',
      nil => 'geral'
    }

    CSV.foreach(csv_path, headers: true, encoding: 'UTF-8') do |row|
      doc_id = row['ID do Documento']&.strip
      csv_category = row['Categoria']&.strip

      next if doc_id.blank? || doc_id.length < 3

      # Analisar tipo
      prefix = doc_id.match(/^([A-Z]+)/i)&.captures&.first&.upcase
      if prefix
        if type_mapping[prefix]
          types_found[type_mapping[prefix]] += 1
        else
          unmapped_types << prefix unless unmapped_types.include?(prefix)
        end
      end

      # Analisar categoria
      mapped_category = category_mapping[csv_category] || 'geral'
      categories_found[mapped_category] += 1
    end

    puts "📋 TIPOS DE DOCUMENTOS ENCONTRADOS:"
    puts "-" * 40
    types_found.each do |type, count|
      puts "• #{type.humanize}: #{count} documento(s)"
    end

    puts
    puts "📂 CATEGORIAS ENCONTRADAS:"
    puts "-" * 40
    categories_found.each do |category, count|
      puts "• #{category.humanize}: #{count} documento(s)"
    end

    if unmapped_types.any?
      puts
      puts "⚠️  PREFIXOS NÃO MAPEADOS:"
      puts "-" * 40
      unmapped_types.each do |prefix|
        puts "• #{prefix} (será mapeado como 'outros')"
      end
    end

    puts
    puts "📊 RESUMO:"
    puts "Total de tipos mapeados: #{types_found.count}"
    puts "Total de categorias: #{categories_found.count}"
    puts "Prefixos não mapeados: #{unmapped_types.count}"
  end
end
