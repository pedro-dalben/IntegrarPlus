namespace :documents do
  desc 'Criar documentos de exemplo com os novos tipos'
  task create_samples: :environment do
    puts 'Criando documentos de exemplo...'

    # Buscar um profissional para ser o autor (primeiro disponível)
    author = Professional.first
    unless author
      puts '❌ Erro: Nenhum profissional encontrado. Crie um profissional primeiro.'
      exit 1
    end

    # Definir os tipos de documentos com suas descrições e categorias
    document_types_info = {
      cartilha: {
        title: 'Cartilha de Procedimentos',
        description: 'Cartilha com orientações e procedimentos padrão',
        category: :tecnica
      },
      anexo: {
        title: 'Anexo - Documentação Complementar',
        description: 'Anexo com informações complementares ao documento principal',
        category: :geral
      },
      documento: {
        title: 'Documento Técnico',
        description: 'Documento técnico com especificações detalhadas',
        category: :tecnica
      },
      formulario: {
        title: 'Formulário de Avaliação',
        description: 'Formulário para coleta de dados e avaliações',
        category: :administrativa
      },
      manual: {
        title: 'Manual de Operações',
        description: 'Manual com instruções detalhadas de operação',
        category: :tecnica
      },
      pgrs: {
        title: 'Programa de Gerenciamento de Resíduos de Serviço de Saúde',
        description: 'Programa completo para gerenciamento de resíduos hospitalares',
        category: :tecnica
      },
      planilha: {
        title: 'Planilha de Controle',
        description: 'Planilha para controle e acompanhamento de processos',
        category: :administrativa
      },
      pop: {
        title: 'Procedimento Operacional Padrão',
        description: 'POP com instruções detalhadas para execução de procedimentos',
        category: :tecnica
      },
      requisicao: {
        title: 'Requisição de Materiais',
        description: 'Documento para solicitação de materiais e equipamentos',
        category: :administrativa
      },
      regimento_interno: {
        title: 'Regimento Interno',
        description: 'Regimento interno com normas e diretrizes organizacionais',
        category: :administrativa
      },
      termo: {
        title: 'Termo de Responsabilidade',
        description: 'Termo com definições de responsabilidades e compromissos',
        category: :recursos_humanos
      }
    }

    created_count = 0
    errors = []

    document_types_info.each do |type, info|
      document = Document.create!(
        title: info[:title],
        document_type: type,
        category: info[:category],
        author: author,
        status: :aguardando_revisao,
        current_version: '1.0'
      )

      puts "✅ Criado: #{document.title} (#{type})"
      created_count += 1
    rescue StandardError => e
      error_msg = "❌ Erro ao criar #{info[:title]} (#{type}): #{e.message}"
      puts error_msg
      errors << error_msg
    end

    puts "\n" + ('=' * 50)
    puts '📊 RESUMO:'
    puts "Documentos criados: #{created_count}"
    puts "Erros: #{errors.count}"

    if errors.any?
      puts "\n❌ ERROS ENCONTRADOS:"
      errors.each { |error| puts "  - #{error}" }
    end

    puts "\n✨ Processo concluído!"
  end

  desc 'Listar todos os tipos de documentos disponíveis'
  task list_types: :environment do
    puts '📋 TIPOS DE DOCUMENTOS DISPONÍVEIS:'
    puts '=' * 50

    Document.document_types.each do |key, value|
      puts "#{value.to_s.rjust(2)} - #{key.humanize}"
    end

    puts "\n📊 Total: #{Document.document_types.count} tipos"
  end

  desc 'Listar todas as categorias disponíveis'
  task list_categories: :environment do
    puts '📂 CATEGORIAS DE DOCUMENTOS DISPONÍVEIS:'
    puts '=' * 50

    Document.categories.each do |key, value|
      puts "#{value.to_s.rjust(2)} - #{key.humanize}"
    end

    puts "\n📊 Total: #{Document.categories.count} categorias"
  end

  desc 'Criar documento específico'
  task :create, %i[type title category] => :environment do |_t, args|
    unless args[:type] && args[:title]
      puts '❌ Uso: rake documents:create[tipo,titulo,categoria]'
      puts "Exemplo: rake documents:create[cartilha,'Cartilha de Segurança',tecnica]"
      puts "Categorias: #{Document.categories.keys.join(', ')}"
      exit 1
    end

    type = args[:type].to_sym
    title = args[:title]
    category = args[:category]&.to_sym || :geral

    unless Document.document_types.key?(type.to_s)
      puts "❌ Tipo '#{type}' não é válido."
      puts "Tipos disponíveis: #{Document.document_types.keys.join(', ')}"
      exit 1
    end

    unless Document.categories.key?(category.to_s)
      puts "❌ Categoria '#{category}' não é válida."
      puts "Categorias disponíveis: #{Document.categories.keys.join(', ')}"
      exit 1
    end

    author = Professional.first
    unless author
      puts '❌ Erro: Nenhum profissional encontrado. Crie um profissional primeiro.'
      exit 1
    end

    begin
      document = Document.create!(
        title: title,
        document_type: type,
        category: category,
        author: author,
        status: :aguardando_revisao,
        current_version: '1.0'
      )

      puts '✅ Documento criado com sucesso!'
      puts "   ID: #{document.id}"
      puts "   Título: #{document.title}"
      puts "   Tipo: #{document.document_type.humanize}"
      puts "   Categoria: #{document.category.humanize}"
      puts "   Autor: #{document.author.full_name}"
      puts "   Status: #{document.status.humanize}"
    rescue StandardError => e
      puts "❌ Erro ao criar documento: #{e.message}"
      exit 1
    end
  end

  desc 'Estatísticas dos documentos por tipo'
  task stats: :environment do
    puts '📊 ESTATÍSTICAS DOS DOCUMENTOS POR TIPO:'
    puts '=' * 50

    Document.document_types.each do |key, value|
      count = Document.where(document_type: value).count
      puts "#{key.humanize.ljust(30)} #{count.to_s.rjust(3)} documento(s)"
    end

    puts '-' * 50
    puts 'TOTAL:'.ljust(30) + " #{Document.count.to_s.rjust(3)} documento(s)"

    puts "\n📂 ESTATÍSTICAS DOS DOCUMENTOS POR CATEGORIA:"
    puts '=' * 50

    Document.categories.each do |key, value|
      count = Document.where(category: value).count
      puts "#{key.humanize.ljust(30)} #{count.to_s.rjust(3)} documento(s)"
    end

    puts '-' * 50
    puts 'TOTAL:'.ljust(30) + " #{Document.count.to_s.rjust(3)} documento(s)"
  end

  desc 'Estatísticas dos documentos por categoria'
  task stats_by_category: :environment do
    puts '📂 ESTATÍSTICAS DOS DOCUMENTOS POR CATEGORIA:'
    puts '=' * 50

    Document.categories.each do |key, value|
      count = Document.where(category: value).count
      puts "#{key.humanize.ljust(30)} #{count.to_s.rjust(3)} documento(s)"

      next unless count > 0

      puts '   Tipos nesta categoria:'
      Document.where(category: value).includes(:author).each do |doc|
        type_name = doc.document_type
        puts "     - #{type_name.humanize}: #{doc.title}"
      end
      puts
    end

    puts '-' * 50
    puts 'TOTAL:'.ljust(30) + " #{Document.count.to_s.rjust(3)} documento(s)"
  end
end
