# frozen_string_literal: true

class Professional < ApplicationRecord
  include DashboardCache
  include MeiliSearch::Rails unless Rails.env.test?
  include AddressableConcern
  include BrazilianDocumentValidation

  belongs_to :contract_type, optional: true
  has_one :user, dependent: :destroy

  has_many :professional_groups, dependent: :destroy
  has_many :groups, through: :professional_groups

  has_many :professional_specialities, dependent: :destroy
  has_many :specialities, through: :professional_specialities
  has_many :professional_specializations, dependent: :destroy
  has_many :specializations, through: :professional_specializations

  has_many :documents, foreign_key: :author_professional_id, dependent: :destroy
  has_many :document_versions, foreign_key: :created_by_professional_id, dependent: :destroy
  has_many :document_responsibles, dependent: :destroy
  has_many :document_tasks, foreign_key: :created_by_professional_id, dependent: :destroy
  has_many :assigned_tasks, class_name: 'DocumentTask', foreign_key: :assigned_to_professional_id, dependent: :destroy
  has_many :completed_tasks, class_name: 'DocumentTask', foreign_key: :completed_by_professional_id, dependent: :destroy
  has_many :document_status_logs, dependent: :destroy
  has_many :document_releases, foreign_key: :released_by_professional_id, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :professional_availabilities, dependent: :destroy
  has_many :availability_exceptions, dependent: :destroy
  has_many :medical_appointments, dependent: :destroy

  # Nested attributes for form handling
  accepts_nested_attributes_for :groups, allow_destroy: true
  accepts_nested_attributes_for :specialities, allow_destroy: true
  accepts_nested_attributes_for :specializations, allow_destroy: true

  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :cpf, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :workload_minutes, numericality: { greater_than_or_equal_to: 0 }
  validates :phone, format: { with: /\A\d{10,11}\z/, message: 'deve ter 10 ou 11 dígitos' }, allow_blank: true

  validate :contract_type_consistency
  validate :specialization_consistency
  validate :email_not_used_by_other_user

  before_validation :normalize_phone, if: -> { phone.present? }

  after_create :create_user_for_authentication, if: :active?

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

  # Métodos de permissões de grupos (fonte única)
  def permit?(permission_key)
    return true if admin?

    groups.any? { |group| group.has_permission?(permission_key) }
  end

  def admin?
    groups.any?(&:admin?)
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

    begin
      hours, minutes = hhmm.to_s.split(':').map(&:to_i)
      hours ||= 0
      minutes ||= 0

      hours = 99 if hours > 99

      minutes = 59 if minutes > 59

      self.workload_minutes = (hours * 60) + minutes
    rescue StandardError => e
      Rails.logger.error "Erro ao processar workload_hhmm '#{hhmm}': #{e.message}"
      self.workload_minutes = 0
    end
  end

  unless Rails.env.test?
    meilisearch do
      searchable_attributes %i[full_name email cpf phone]
      filterable_attributes %i[active created_at updated_at]
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
  end

  def create_user_for_authentication!
    return user if user.present?

    new_user = nil
    new_invite = nil

    ActiveRecord::Base.transaction do
      temp_password = SecureRandom.hex(12)
      new_user = User.create!(
        email: email,
        password: temp_password,
        password_confirmation: temp_password,
        professional: self
      )

      Rails.logger.info "Usuário de autenticação criado para profissional #{id}: #{email}"

      new_invite = Invite.create!(user: new_user)
      Rails.logger.info "Convite criado para usuário #{new_user.email}: #{new_invite.token}"
    end

    InviteMailer.invite_email(new_invite).deliver_later if new_invite
    Rails.logger.info "Email de convite agendado para envio: #{new_user.email}"

    new_user
  rescue StandardError => e
    Rails.logger.error "Erro ao criar usuário para profissional #{id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  private

  def normalize_phone
    self.phone = phone.to_s.gsub(/\D/, '') if phone.present?
  end

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

    Rails.logger.info 'Validando consistência de especializações...'
    Rails.logger.info "Especialidades selecionadas: #{speciality_ids.inspect}"
    Rails.logger.info "Especializações selecionadas: #{specialization_ids.inspect}"

    specializations.each do |specialization|
      Rails.logger.info "Verificando especialização: #{specialization.name} (ID: #{specialization.id})"

      # Verificar se a especialização tem alguma especialidade em comum com as selecionadas
      specialization_speciality_ids = specialization.specialities.pluck(:id)
      Rails.logger.info "Especialidades da especialização #{specialization.name}: #{specialization_speciality_ids.inspect}"

      common_specialities = speciality_ids & specialization_speciality_ids
      Rails.logger.info "Especialidades em comum: #{common_specialities.inspect}"

      next unless common_specialities.empty?

      error_msg = "especialização '#{specialization.name}' não pertence a nenhuma especialidade selecionada"
      Rails.logger.warn "Erro de validação: #{error_msg}"
      errors.add(:specializations, error_msg)
    end

    Rails.logger.info 'Validação de especializações concluída'
  end

  def email_not_used_by_other_user
    return if email.blank? || !email_changed?

    existing_user = User.where(email: email).where.not(professional: self).first
    return if existing_user.blank?

    errors.add(:email, 'já está sendo usado por outro usuário')
  end

  def user_status
    return 'Sem usuário' unless user
    return 'Pendente' if user.pending_invite?
    return 'Confirmado' if user.confirmed_invite?

    'Ativo'
  end

  def name
    full_name
  end

  def has_coordinates?
    coordinates.present?
  end

  def tem_endereco_completo?
    complete_address?
  end

  def tem_coordenadas?
    has_coordinates?
  end

  def create_user_for_authentication
    return if user.present?

    create_user_for_authentication!
  end
end
