# frozen_string_literal: true

class AdvancedSearchService
  def initialize(model_class = Document)
    @model_class = model_class
  end

  def search(query, filters = {}, options = {})
    return [] if query.blank?

    normalized_query = normalize_query(query)
    search_strategies = build_search_strategies(normalized_query)
    
    results = []
    search_strategies.each do |strategy|
      strategy_results = execute_search_strategy(strategy, filters, options)
      results.concat(strategy_results)
    end

    # Remover duplicatas e ordenar por relevância
    unique_results = remove_duplicates(results)
    sort_by_relevance(unique_results, normalized_query)
  end

  private

  def normalize_query(query)
    query.to_s
         .downcase
         .strip
         .gsub(/\s+/, ' ')
         .gsub(/[^\p{L}\p{N}\s]/, ' ')
  end

  def build_search_strategies(query)
    strategies = []

    # Estratégia 1: Busca exata
    strategies << { type: :exact, query: query }

    # Estratégia 2: Busca fonética
    phonetic_query = generate_phonetic_query(query)
    if phonetic_query != query
      strategies << { type: :phonetic, query: phonetic_query }
    end

    # Estratégia 3: Busca com caracteres especiais normalizados
    normalized_query = normalize_special_chars(query)
    if normalized_query != query
      strategies << { type: :normalized, query: normalized_query }
    end

    # Estratégia 4: Busca por palavras parciais
    partial_queries = generate_partial_queries(query)
    partial_queries.each do |partial_query|
      strategies << { type: :partial, query: partial_query }
    end

    # Estratégia 5: Busca fuzzy (aproximada)
    strategies << { type: :fuzzy, query: query }

    strategies
  end

  def execute_search_strategy(strategy, filters, options)
    case strategy[:type]
    when :exact
      execute_exact_search(strategy[:query], filters, options)
    when :phonetic
      execute_phonetic_search(strategy[:query], filters, options)
    when :normalized
      execute_normalized_search(strategy[:query], filters, options)
    when :partial
      execute_partial_search(strategy[:query], filters, options)
    when :fuzzy
      execute_fuzzy_search(strategy[:query], filters, options)
    else
      []
    end
  rescue StandardError => e
    Rails.logger.error "Erro na estratégia de busca #{strategy[:type]}: #{e.message}"
    []
  end

  def execute_exact_search(query, filters, options)
    @model_class.search(query, build_search_options(filters, options))
  end

  def execute_phonetic_search(query, filters, options)
    # Busca usando atributos fonéticos
    search_options = build_search_options(filters, options)
    search_options[:attributesToSearchOn] = %w[phonetic_title phonetic_description phonetic_author_name]
    
    @model_class.search(query, search_options)
  end

  def execute_normalized_search(query, filters, options)
    # Busca usando atributos normalizados
    search_options = build_search_options(filters, options)
    search_options[:attributesToSearchOn] = %w[normalized_title normalized_description]
    
    @model_class.search(query, search_options)
  end

  def execute_partial_search(query, filters, options)
    # Busca com wildcard
    wildcard_query = "#{query}*"
    @model_class.search(wildcard_query, build_search_options(filters, options))
  end

  def execute_fuzzy_search(query, filters, options)
    # Busca com tolerância a erros de digitação
    search_options = build_search_options(filters, options)
    search_options[:typoTolerance] = {
      enabled: true,
      minWordSizeForTypos: {
        oneTypo: 4,
        twoTypos: 8
      }
    }
    
    @model_class.search(query, search_options)
  end

  def build_search_options(filters, options)
    search_options = {
      limit: options[:limit] || 100,
      offset: options[:offset] || 0
    }

    # Adicionar filtros se fornecidos
    if filters.any?
      search_options[:filter] = build_filter_string(filters)
    end

    # Adicionar ordenação se fornecida
    if options[:sort]
      search_options[:sort] = options[:sort]
    end

    search_options
  end

  def build_filter_string(filters)
    filter_parts = []
    
    filters.each do |key, value|
      case key
      when :status
        filter_parts << "status = #{value}"
      when :document_type
        filter_parts << "document_type = #{value}"
      when :category
        filter_parts << "category = #{value}"
      when :author_professional_id
        filter_parts << "author_professional_id = #{value}"
      when :date_range
        if value[:start_date]
          filter_parts << "created_at >= #{value[:start_date].to_i}"
        end
        if value[:end_date]
          filter_parts << "created_at <= #{value[:end_date].to_i}"
        end
      end
    end

    filter_parts.join(' AND ')
  end

  def generate_phonetic_query(query)
    require 'text'
    words = query.split(' ')
    phonetic_words = words.map { |word| Text::Metaphone.metaphone(word) }
    phonetic_words.join(' ')
  rescue LoadError, StandardError
    query
  end

  def normalize_special_chars(query)
    query.gsub(/[àáâãäå]/, 'a')
         .gsub(/[èéêë]/, 'e')
         .gsub(/[ìíîï]/, 'i')
         .gsub(/[òóôõö]/, 'o')
         .gsub(/[ùúûü]/, 'u')
         .gsub(/[ç]/, 'c')
         .gsub(/[ñ]/, 'n')
  end

  def generate_partial_queries(query)
    words = query.split(' ')
    partial_queries = []
    
    words.each do |word|
      next if word.length < 3
      partial_queries << "#{word}*"
    end
    
    partial_queries
  end

  def remove_duplicates(results)
    results.uniq(&:id)
  end

  def sort_by_relevance(results, query)
    results.sort_by { |result| calculate_relevance_score(result, query) }.reverse
  end

  def calculate_relevance_score(result, query)
    score = 0
    query_words = query.split(' ')
    
    query_words.each do |word|
      # Título tem peso maior
      if result.title&.downcase&.include?(word)
        score += 10
      end
      
      # Descrição tem peso médio
      if result.description&.downcase&.include?(word)
        score += 5
      end
      
      # Autor tem peso menor
      if result.author&.full_name&.downcase&.include?(word)
        score += 3
      end
      
      # Bônus para correspondência exata no título
      if result.title&.downcase == word
        score += 20
      end
      
      # Bônus para correspondência exata na query completa
      if result.title&.downcase == query
        score += 50
      end
    end
    
    # Bônus para documentos mais recentes
    score += (result.created_at.to_i / 86400) * 0.1
    
    score
  end
end
