# frozen_string_literal: true

class Professional < ApplicationRecord
  include DashboardCache
  include MeiliSearch::Rails

  # Removido Devise - o Professional não precisa de autenticação
  # A autenticação é feita através do User associado

  belongs_to :contract_type, optional: true
  belongs_to :user, optional: true

  has_many :groups, through: :user
  has_many :professional_specialities, dependent: :destroy
  has_many :specialities, through: :professional_specialities
  has_many :professional_specializations, dependent: :destroy
  has_many :specializations, through: :professional_specializations

  # Document associations
  has_many :documents, foreign_key: :author_professional_id, dependent: :destroy
  has_many :document_versions, foreign_key: :created_by_professional_id, dependent: :destroy
  has_many :document_responsibles, dependent: :destroy
  has_many :document_tasks, foreign_key: :created_by_professional_id, dependent: :destroy
  has_many :assigned_tasks, class_name: 'DocumentTask', foreign_key: :assigned_to_professional_id, dependent: :destroy
  has_many :completed_tasks, class_name: 'DocumentTask', foreign_key: :completed_by_professional_id, dependent: :destroy
  has_many :document_status_logs, dependent: :destroy
  has_many :document_releases, foreign_key: :released_by_professional_id, dependent: :destroy

  validates :full_name, presence: true
  validates :cpf, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  # validates :phone, phone: true, allow_blank: true
  # validates :cnpj, cnpj: true, allow_blank: true
  validates :workload_minutes, numericality: { greater_than_or_equal_to: 0 }
  # validates :birth_date, date: { after: Date.new(1900, 1, 1), before_or_equal_to: Date.current }, allow_blank: true

  validate :contract_type_consistency
  validate :specialization_consistency
  validate :email_not_used_by_other_user

  after_create :create_user_if_needed
  # Callbacks para sincronizar dados com User
  after_update :sync_user_data, if: :should_sync_user_data?

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:full_name) }

  # System permissions for document management
  SYSTEM_PERMISSIONS = {
    can_access_documents: 0,      # Pode acessar área de documentos
    can_create_documents: 1,      # Pode criar novos documentos
    can_view_released: 2,         # Pode ver documentos liberados
    can_manage_permissions: 3,    # Pode gerenciar permissões de outros
    can_assign_responsibles: 4,   # Pode atribuir responsáveis
    can_release_documents: 5      # Pode liberar documentos
  }.freeze

  # Permission verification methods
  def can_access_documents?
    system_permissions.include?(SYSTEM_PERMISSIONS[:can_access_documents])
  end

  def can_create_documents?
    system_permissions.include?(SYSTEM_PERMISSIONS[:can_create_documents])
  end

  def can_view_released?
    system_permissions.include?(SYSTEM_PERMISSIONS[:can_view_released])
  end

  def can_manage_permissions?
    system_permissions.include?(SYSTEM_PERMISSIONS[:can_manage_permissions])
  end

  def can_assign_responsibles?
    system_permissions.include?(SYSTEM_PERMISSIONS[:can_assign_responsibles])
  end

  def can_release_documents?
    system_permissions.include?(SYSTEM_PERMISSIONS[:can_release_documents])
  end

  def has_any_document_permission?
    system_permissions.any?
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :not_approved
  end

  def workload_hours
    return 0 if workload_minutes.nil?

    (workload_minutes / 60.0).round(2)
  end

  def workload_hours=(hours)
    self.workload_minutes = (hours.to_f * 60).round
  end

  def workload_hhmm
    return '00:00' if workload_minutes.nil?

    hours = workload_minutes / 60
    minutes = workload_minutes % 60
    format('%02d:%02d', hours, minutes)
  end

  def workload_hhmm=(hhmm)
    return if hhmm.blank?

    hours, minutes = hhmm.split(':').map(&:to_i)
    self.workload_minutes = (hours * 60) + minutes
  end

  meilisearch do
    searchable_attributes %i[full_name email cpf phone]
    filterable_attributes %i[active confirmed_at]
    sortable_attributes %i[created_at updated_at full_name]

    attribute :full_name
    attribute :email
    attribute :cpf
    attribute :phone
    attribute :active
    attribute :created_at
    attribute :updated_at

    attribute :status do
      if active?
        user&.confirmed_invite? ? 'Ativo e Confirmado' : 'Ativo e Pendente'
      else
        'Inativo'
      end
    end

    attribute :groups_names do
      groups.pluck(:name).join(', ')
    end
  end

  private

  def contract_type_consistency
    return unless contract_type

    if contract_type.requires_company? && company_name.blank?
      errors.add(:company_name, 'é obrigatório para este tipo de contratação')
    end

    return unless contract_type.requires_cnpj? && cnpj.blank?

    errors.add(:cnpj, 'é obrigatório para este tipo de contratação')
  end

  def specialization_consistency
    return unless specializations.any?

    specializations.each do |specialization|
      next if specialization.speciality.in?(specialities)

      errors.add(:specializations,
                 "especialização '#{specialization.name}' não pertence a nenhuma especialidade selecionada")
    end
  end

  def email_not_used_by_other_user
    return if email.blank?
    return unless email_changed?

    # Verificar se existe outro usuário com este email (exceto o usuário associado a este profissional)
    existing_user = User.where(email: email).where.not(id: user_id).first

    return unless existing_user.present?

    errors.add(:email, 'já está sendo usado por outro usuário')
  end

  def ensure_user_exists!
    create_user! unless user.present?
  end

  def user_status
    return 'Sem usuário' unless user
    return 'Pendente' if user.pending_invite?
    return 'Confirmado' if user.confirmed_invite?

    'Ativo'
  end

  def create_user!
    return user if user.present?

    new_user = User.create!(
      name: full_name,
      email: email,
      password: SecureRandom.hex(8)
    )

    update!(user: new_user)
    new_user
  end

  def name
    full_name
  end

  # Métodos para sincronização com User
  def should_sync_user_data?
    user.present? && (saved_change_to_full_name? || saved_change_to_email?)
  end

  def sync_user_data
    return unless user.present?

    user_updates = {}

    # Sincronizar nome se mudou
    user_updates[:name] = full_name if saved_change_to_full_name?

    # Sincronizar email se mudou
    user_updates[:email] = email if saved_change_to_email?

    return unless user_updates.any?

    user.update!(user_updates)
    Rails.logger.info "Dados do usuário sincronizados para profissional #{id}: #{user_updates}"
  end

  def create_user_if_needed
    return if user.present?
    return unless active? # Só criar usuário se o profissional estiver ativo

    create_user_automatically
  end

  def create_user_automatically
    new_user = User.create!(
      name: full_name,
      email: email,
      password: SecureRandom.hex(12),
      password_confirmation: SecureRandom.hex(12)
    )

    update_column(:user_id, new_user.id) # Usar update_column para evitar callbacks infinitos

    Rails.logger.info "Usuário criado automaticamente para profissional #{id}: #{email}"
    new_user
  rescue StandardError => e
    Rails.logger.error "Erro ao criar usuário automaticamente para profissional #{id}: #{e.message}"
    nil
  end
end
