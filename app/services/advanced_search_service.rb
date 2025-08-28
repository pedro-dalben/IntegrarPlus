# frozen_string_literal: true

class AdvancedSearchService
  def initialize(model_class = Document)
    @model_class = model_class
  end

  def search(query, filters = {}, options = {})
    return [] if query.blank?

    Rails.logger.info "AdvancedSearchService: Searching for '#{query}' in #{@model_class.name}"

    begin
      # Busca simples usando MeiliSearch
      search_options = build_search_options(filters, options)
      results = @model_class.search(query, search_options)

      Rails.logger.info "AdvancedSearchService: Found #{results.length} results"
      results
    rescue StandardError => e
      Rails.logger.error "AdvancedSearchService error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Fallback para busca local
      perform_local_search(query, filters)
    end
  end

  private

  def build_search_options(filters, options)
    search_options = {
      limit: options[:limit] || 1000,
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
        if value.is_a?(String) && value.start_with?('!')
          # Filtro de exclusão
          status_value = value[1..-1]
          filter_parts << "status != #{@model_class.statuses[status_value]}" if @model_class.statuses[status_value]
        else
          filter_parts << "status = #{value}"
        end
      when :document_type
        filter_parts << "document_type = #{value}"
      when :category
        filter_parts << "category = #{value}"
      when :author_professional_id
        filter_parts << "author_professional_id = #{value}"
      when :active
        filter_parts << "active = #{value}"
      when :is_admin
        filter_parts << "is_admin = #{value}"
      when :contract_type_id
        filter_parts << "contract_type_id = #{value}"
      when :speciality_id
        filter_parts << "speciality_id = #{value}"
      end
    end

    filter_parts.join(' AND ')
  end

  def perform_local_search(query, filters)
    Rails.logger.info "AdvancedSearchService: Performing local search fallback"

    # Busca local simples
    base_query = @model_class.all

    # Aplicar filtros
    filters.each do |key, value|
      case key
      when :status
        if value.is_a?(String) && value.start_with?('!')
          status_value = value[1..-1]
          base_query = base_query.where.not(status: status_value)
        else
          base_query = base_query.where(status: value)
        end
      when :active
        base_query = base_query.where(active: value)
      when :is_admin
        base_query = base_query.where(is_admin: value)
      when :contract_type_id
        base_query = base_query.where(contract_type_id: value)
      when :author_professional_id
        base_query = base_query.where(author_professional_id: value)
      end
    end

        # Busca por texto baseada no modelo
    normalized_query = query.downcase.strip

    case @model_class.name
    when 'Professional'
      base_query.where(
        'LOWER(full_name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(company_name) LIKE ? OR LOWER(council_code) LIKE ?',
        "%#{normalized_query}%",
        "%#{normalized_query}%",
        "%#{normalized_query}%",
        "%#{normalized_query}%"
      )
    when 'Document'
      base_query.where(
        'LOWER(title) LIKE ? OR LOWER(description) LIKE ?',
        "%#{normalized_query}%",
        "%#{normalized_query}%"
      )
    when 'Group'
      base_query.where(
        'LOWER(name) LIKE ? OR LOWER(description) LIKE ?',
        "%#{normalized_query}%",
        "%#{normalized_query}%"
      )
    when 'Speciality'
      base_query.where(
        'LOWER(name) LIKE ? OR LOWER(specialty) LIKE ?',
        "%#{normalized_query}%",
        "%#{normalized_query}%"
      )
    when 'Specialization'
      base_query.where(
        'LOWER(name) LIKE ?',
        "%#{normalized_query}%"
      )
    when 'ContractType'
      base_query.where(
        'LOWER(name) LIKE ?',
        "%#{normalized_query}%"
      )
    else
      # Fallback genérico
      base_query.where(
        'LOWER(name) LIKE ? OR LOWER(title) LIKE ?',
        "%#{normalized_query}%",
        "%#{normalized_query}%"
      )
    end
  end
end
