# frozen_string_literal: true

class Document < ApplicationRecord
  include MeiliSearch::Rails

  belongs_to :author, class_name: 'Professional', foreign_key: 'author_professional_id'
  has_many :document_versions, dependent: :destroy
  has_many :document_permissions, dependent: :destroy
  has_many :document_tasks, dependent: :destroy
  has_many :document_status_logs, dependent: :destroy
  has_many :document_responsibles, dependent: :destroy
  has_many :document_releases, dependent: :destroy
  has_one_attached :file

  meilisearch do
    searchable_attributes %i[title description author_name responsible_name document_type_name category_name
                             status_name]
    filterable_attributes %i[document_type status category author_professional_id]
    sortable_attributes %i[created_at updated_at title]

    attribute :author_name do
      author&.full_name
    end

    attribute :responsible_name do
      current_responsible&.full_name
    end

    attribute :document_type_name do
      document_type.humanize
    end

    attribute :category_name do
      category.humanize
    end

    attribute :status_name do
      status.humanize
    end

    attribute :searchable_title do
      title
    end

    attribute :searchable_description do
      description
    end

    attribute :status do
      status_before_type_cast
    end

    attribute :document_type do
      document_type_before_type_cast
    end

    attribute :category do
      category_before_type_cast
    end
  end

  enum :document_type, {
    relatorio: 0,
    laudo: 1,
    contrato: 2,
    outros: 3,
    cartilha: 4,
    anexo: 5,
    documento: 6,
    formulario: 7,
    manual: 8,
    pgrs: 9,
    planilha: 10,
    pop: 11,
    requisicao: 12,
    regimento_interno: 13,
    termo: 14
  }

  enum :status, {
    aguardando_revisao: 0,
    aguardando_correcoes: 1,
    aguardando_liberacao: 2,
    liberado: 3
  }

  enum :category, {
    geral: 0,
    tecnica: 1,
    recursos_humanos: 2,
    administrativa: 3
  }

  validates :title, presence: true, length: { maximum: 150 }
  validates :document_type, presence: true
  validates :current_version, presence: true
  validates :status, presence: true
  validates :category, presence: true

  before_validation :set_defaults, on: :create

  def self.access_levels
    DocumentPermission.access_levels
  end

  def latest_version
    document_versions.order(:version_number).last
  end

  def user_can_access?(user, required_level = :visualizar)
    return true if user&.professional == author
    return true if user&.admin?

    permission = find_user_permission(user)
    return false unless permission

    required_level_index = self.class.access_levels[required_level.to_s]
    permission_level_index = self.class.access_levels[permission.access_level]

    permission_level_index >= required_level_index
  end

  def user_can_view?(user)
    user_can_access?(user, :visualizar)
  end

  def user_can_comment?(user)
    user_can_access?(user, :comentar)
  end

  def user_can_edit?(user)
    user_can_access?(user, :editar)
  end

  def find_user_permission(user)
    document_permissions.for_user_and_groups(user).order(:access_level).last
  end

  def grant_permission(user_or_group, access_level)
    raise ArgumentError, 'Usuário ou grupo deve ser especificado' if user_or_group.nil?
    raise ArgumentError, 'Nível de acesso deve ser especificado' if access_level.nil?

    if user_or_group.is_a?(User)
      document_permissions.find_or_initialize_by(user: user_or_group).tap do |permission|
        permission.access_level = access_level
        permission.save!
      end
    elsif user_or_group.is_a?(Group)
      document_permissions.find_or_initialize_by(group: user_or_group).tap do |permission|
        permission.access_level = access_level
        permission.save!
      end
    else
      raise ArgumentError, 'Tipo inválido. Deve ser User ou Group'
    end
  end

  def revoke_permission(user_or_group)
    if user_or_group.is_a?(User)
      document_permissions.where(user: user_or_group).destroy_all
    elsif user_or_group.is_a?(Group)
      document_permissions.where(group: user_or_group).destroy_all
    end
  end

  def create_new_version(file, professional, notes = nil)
    next_version = calculate_next_version
    version = document_versions.create!(
      version_number: next_version,
      file_path: generate_file_path(next_version, file),
      created_by: professional,
      notes: notes
    )

    save_file_to_storage(file, version.file_path)
    update!(current_version: next_version)
    version
  rescue StandardError => e
    Rails.logger.error "Erro ao criar versão: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end

  def update_status!(new_status, professional, notes = nil)
    old_status = status
    return if old_status == new_status

    update!(status: new_status)

    document_status_logs.create!(
      old_status: old_status,
      new_status: new_status,
      professional: professional,
      notes: notes
    )
  end

  def can_transition_to?(target_status)
    case status
    when 'aguardando_revisao'
      %w[aguardando_correcoes aguardando_liberacao].include?(target_status)
    when 'aguardando_correcoes'
      %w[aguardando_revisao].include?(target_status)
    when 'aguardando_liberacao'
      %w[liberado aguardando_revisao].include?(target_status)
    when 'liberado'
      %w[aguardando_revisao].include?(target_status)
    else
      false
    end
  end

  def available_status_transitions
    case status
    when 'aguardando_revisao'
      %w[aguardando_correcoes aguardando_liberacao]
    when 'aguardando_correcoes'
      %w[aguardando_revisao]
    when 'aguardando_liberacao'
      %w[liberado aguardando_revisao]
    when 'liberado'
      %w[aguardando_revisao]
    else
      []
    end
  end

  def status_color
    case status
    when 'aguardando_revisao'
      'text-yellow-600 bg-yellow-50 border-yellow-200'
    when 'aguardando_correcoes'
      'text-red-600 bg-red-50 border-red-200'
    when 'aguardando_liberacao'
      'text-orange-600 bg-orange-50 border-orange-200'
    when 'liberado'
      'text-green-600 bg-green-50 border-green-200'
    end
  end

  def status_icon
    case status
    when 'aguardando_revisao'
      '🔍'
    when 'aguardando_correcoes'
      '⚠️'
    when 'aguardando_liberacao'
      '⏳'
    when 'liberado'
      '✅'
    end
  end

  def category_color
    case category
    when 'geral'
      'text-blue-600 bg-blue-50 border-blue-200'
    when 'tecnica'
      'text-purple-600 bg-purple-50 border-purple-200'
    when 'recursos_humanos'
      'text-green-600 bg-green-50 border-green-200'
    when 'administrativa'
      'text-orange-600 bg-orange-50 border-orange-200'
    end
  end

  def category_icon
    case category
    when 'geral'
      '📄'
    when 'tecnica'
      '⚙️'
    when 'recursos_humanos'
      '👥'
    when 'administrativa'
      '📊'
    end
  end

  def assign_responsible(professional, status = 'active')
    document_responsibles.create!(
      professional: professional,
      status: status
    )
  end

  def current_responsible
    document_responsibles.for_status(status).first&.professional
  end

  def assign_responsible(professional, status = nil)
    target_status = status || self.status

    document_responsibles.find_or_initialize_by(status: target_status).tap do |responsible|
      responsible.professional = professional
      responsible.save!
    end
  end

  def latest_release
    document_releases.ordered.first
  end

  def can_be_released?
    status == 'aguardando_liberacao'
  end

  def release_document!(user)
    return false unless can_be_released?

    ActiveRecord::Base.transaction do
      # Criar release
      release = document_releases.create!(
        version: latest_version,
        released_by: user,
        released_at: Time.current
      )

      # Copiar arquivo para pasta released
      copy_file_to_released_folder(release)

      # Atualizar status para liberado
      update_status!('liberado', user.professional, 'Documento liberado como versão final')

      # Atualizar versão liberada
      update!(released_version: latest_version.version_number)

      release
    end
  rescue StandardError => e
    Rails.logger.error "Erro ao liberar documento #{id}: #{e.message}"
    false
  end

  private

  def set_defaults
    self.status ||= :aguardando_revisao
    self.current_version ||= '1.0'
    self.category ||= :geral
  end

  def calculate_next_version
    if document_versions.empty?
      '1.0'
    else
      latest = document_versions.order(:version_number).last.version_number
      major, minor = latest.split('.').map(&:to_i)
      "#{major}.#{minor + 1}"
    end
  end

  def generate_file_path(version, file)
    extension = File.extname(file.original_filename)
    "documents/#{id}/versions/#{version}#{extension}"
  end

  def save_file_to_storage(file, file_path)
    full_path = Rails.root.join('storage', file_path)
    FileUtils.mkdir_p(File.dirname(full_path))

    if file.respond_to?(:tempfile)
      FileUtils.cp(file.tempfile.path, full_path)
    else
      File.binwrite(full_path, file.read)
    end
  end

  def remove_responsible(status = nil)
    target_status = status || self.status
    document_responsibles.for_status(target_status).destroy_all
  end

  def responsible_for_status(status)
    document_responsibles.for_status(status).first&.professional
  end

  def copy_file_to_released_folder(release)
    source_path = Rails.root.join('storage', latest_version.file_path)
    target_path = Rails.root.join(release.released_version_path)

    FileUtils.mkdir_p(File.dirname(target_path))
    FileUtils.cp(source_path, target_path)
  end

  def next_release_version
    if latest_release
      major, _minor = latest_release.version_number.split('.').map(&:to_i)
      "#{major + 1}.0"
    else
      '1.0'
    end
  end

  # Métodos para normalização de texto e busca fonética
  def normalize_text(text)
    return '' if text.blank?

    text.to_s
        .downcase
        .strip
        .gsub(/[^\p{L}\p{N}\s]/, ' ')
        .gsub(/\s+/, ' ')
        .strip
  end

  def normalize_special_chars(text)
    return '' if text.blank?

    text.to_s
        .downcase
        .strip
        .gsub(/[àáâãäå]/, 'a')
        .gsub(/[èéêë]/, 'e')
        .gsub(/[ìíîï]/, 'i')
        .gsub(/[òóôõö]/, 'o')
        .gsub(/[ùúûü]/, 'u')
        .gsub(/[ç]/, 'c')
        .gsub(/[ñ]/, 'n')
        .gsub(/[^\p{L}\p{N}\s]/, ' ')
        .gsub(/\s+/, ' ')
        .strip
  end

  def generate_phonetic(text)
    return '' if text.blank?

    require 'text'
    Text::Metaphone.metaphone(normalize_special_chars(text))
  rescue LoadError, StandardError
    # Fallback se a gem text não estiver disponível
    normalize_special_chars(text)
  end

  # Método para busca avançada com múltiplas estratégias
  def self.advanced_search(query, filters = {})
    return [] if query.blank?

    # Normalizar query
    normalized_query = normalize_search_query(query)

    # Buscar com diferentes estratégias
    results = []

    # 1. Busca exata
    exact_results = search(normalized_query, filters)
    results.concat(exact_results)

    # 2. Busca fonética
    phonetic_query = generate_phonetic_query(normalized_query)
    if phonetic_query != normalized_query
      phonetic_results = search(phonetic_query, filters)
      results.concat(phonetic_results)
    end

    # 3. Busca com caracteres especiais normalizados
    special_chars_query = normalize_special_chars_query(normalized_query)
    if special_chars_query != normalized_query
      special_results = search(special_chars_query, filters)
      results.concat(special_results)
    end

    # 4. Busca por palavras parciais
    partial_results = search_partial_words(normalized_query, filters)
    results.concat(partial_results)

    # Remover duplicatas e ordenar por relevância
    results.uniq(&:id).sort_by { |doc| calculate_relevance_score(doc, normalized_query) }.reverse
  end

  def self.normalize_search_query(query)
    query.to_s
         .downcase
         .strip
         .gsub(/\s+/, ' ')
  end

  def self.generate_phonetic_query(query)
    require 'text'
    words = query.split(' ')
    phonetic_words = words.map { |word| Text::Metaphone.metaphone(word) }
    phonetic_words.join(' ')
  rescue LoadError, StandardError
    query
  end

  def self.normalize_special_chars_query(query)
    query.gsub(/[àáâãäå]/, 'a')
         .gsub(/[èéêë]/, 'e')
         .gsub(/[ìíîï]/, 'i')
         .gsub(/[òóôõö]/, 'o')
         .gsub(/[ùúûü]/, 'u')
         .gsub(/[ç]/, 'c')
         .gsub(/[ñ]/, 'n')
  end

  def self.search_partial_words(query, filters)
    words = query.split(' ')
    return [] if words.empty?

    # Buscar por cada palavra individualmente
    partial_results = []
    words.each do |word|
      next if word.length < 3

      partial_query = "#{word}*"
      results = search(partial_query, filters)
      partial_results.concat(results)
    end

    partial_results
  end

  def self.calculate_relevance_score(document, query)
    score = 0
    query_words = query.split(' ')

    # Pontuação baseada na posição dos termos
    query_words.each do |word|
      # Título tem peso maior
      if document.title&.downcase&.include?(word)
        score += 10
      end

      # Descrição tem peso médio
      if document.description&.downcase&.include?(word)
        score += 5
      end

      # Autor tem peso menor
      if document.author&.full_name&.downcase&.include?(word)
        score += 3
      end
    end

    # Bônus para correspondência exata
    if document.title&.downcase == query
      score += 50
    end

    score
  end
end
