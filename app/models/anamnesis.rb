# frozen_string_literal: true

class Anamnesis < ApplicationRecord
  include MeiliSearch::Rails unless Rails.env.test?
  include EducationOptions

  has_paper_trail

  belongs_to :beneficiary, optional: true
  belongs_to :professional, class_name: 'User'
  belongs_to :portal_intake, optional: true
  belongs_to :created_by_professional, class_name: 'User', optional: true
  belongs_to :updated_by_professional, class_name: 'User', optional: true
  has_one :medical_appointment, dependent: :nullify

  SPECIALTIES = [
    { key: 'fono',              label: 'Fonoaudiologia' },
    { key: 'to',                label: 'Terapia Ocupacional' },
    { key: 'psicopedagogia',    label: 'Psicopedagogia' },
    { key: 'psicomotricidade',  label: 'Psicomotricidade' },
    { key: 'psicologia',        label: 'Psicologia' }
  ].freeze

  BIRTH_TYPES = %w[normal cesarea forceps].freeze
  BIRTH_LOCATION_TYPES = %w[domiciliar hospitalar].freeze
  BIRTH_TERMS = %w[pre_termo termo pos_termo].freeze
  ANESTHESIA_TYPES = %w[raquidiana epidural].freeze
  BABY_POSITIONS = %w[cefalico pelvico_pe pelvico_nadega transverso].freeze

  FAMILY_CONDITIONS = [
    { key: 'di', label: 'DI - Deficiência Intelectual' },
    { key: 'da', label: 'DA - Deficiência Auditiva' },
    { key: 'df', label: 'DF - Deficiência Física' },
    { key: 'has', label: 'HAS - Hipertensão Arterial Sistêmica' },
    { key: 'dm', label: 'DM - Diabetes Mellitus' },
    { key: 'epilepsia', label: 'Epilepsia' },
    { key: 'alcoolismo', label: 'Alcoolismo' },
    { key: 'outros', label: 'Outros' }
  ].freeze

  enum :status, {
    pendente: 'pendente',
    em_andamento: 'em_andamento',
    concluida: 'concluida'
  }

  enum :referral_reason, {
    aba: 'aba',
    equipe_multi: 'equipe_multi',
    aba_equipe_multi: 'aba_equipe_multi'
  }

  enum :treatment_location, {
    domiciliar: 'domiciliar',
    clinica: 'clinica',
    domiciliar_clinica: 'domiciliar_clinica',
    domiciliar_escola: 'domiciliar_escola',
    domiciliar_clinica_escola: 'domiciliar_clinica_escola'
  }

  enum :school_period, {
    manha: 'manha',
    tarde: 'tarde',
    integral: 'integral'
  }

  enum :attendance_status, {
    scheduled: 'scheduled',
    attended: 'attended',
    no_show: 'no_show',
    cancelled: 'cancelled',
    rescheduled: 'rescheduled'
  }

  validates :performed_at, presence: true
  validates :status, presence: true
  validates :referral_reason, presence: true
  validates :treatment_location, presence: true
  validates :referral_hours, presence: true,
                             numericality: { in: 5..40, message: 'deve estar entre 5 e 40 horas' }

  validates :school_name, presence: true, if: :attends_school?
  validates :school_period, presence: true, if: :attends_school?

  before_validation :set_default_values

  scope :by_professional, ->(professional) { where(professional: professional) }
  scope :by_beneficiary, ->(beneficiary) { where(beneficiary: beneficiary) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_date_range, ->(start_date, end_date) { where(performed_at: start_date..end_date) }
  scope :today, -> { where(performed_at: Date.current.all_day) }
  scope :this_week, -> { where(performed_at: Date.current.all_week) }
  scope :this_month, -> { where(performed_at: Date.current.all_month) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date, -> { order(performed_at: :desc) }

  unless Rails.env.test?
    meilisearch do
      searchable_attributes %i[beneficiary_name professional_name referral_reason]
      filterable_attributes %i[status performed_at professional_id]
      sortable_attributes %i[created_at updated_at performed_at]

      attribute :beneficiary_name do
        beneficiary&.name || portal_intake&.beneficiary_name || 'Beneficiário não informado'
      end
      attribute :professional_name do
        professional.full_name
      end
      attribute :performed_at
      attribute :status
      attribute :referral_reason
      attribute :created_at
      attribute :updated_at
    end
  end

  def beneficiary_name
    beneficiary&.name || portal_intake&.beneficiary_name || 'Beneficiário não informado'
  end

  def professional_name
    professional.full_name
  end

  def status_badge_class
    case status
    when 'pendente'
      'ta-badge ta-badge-warning'
    when 'em_andamento'
      'ta-badge ta-badge-info'
    when 'concluida'
      'ta-badge ta-badge-success'
    else
      'ta-badge ta-badge-secondary'
    end
  end

  def status_label
    case status
    when 'pendente'
      'Pendente'
    when 'em_andamento'
      'Em Andamento'
    when 'concluida'
      'Concluída'
    else
      status.humanize
    end
  end

  def referral_reason_label
    case referral_reason
    when 'aba'
      'ABA'
    when 'equipe_multi'
      'Equipe Multi'
    when 'aba_equipe_multi'
      'ABA + Equipe Multi'
    else
      referral_reason.humanize
    end
  end

  def treatment_location_label
    case treatment_location
    when 'domiciliar'
      'Domiciliar'
    when 'clinica'
      'Clínica'
    when 'domiciliar_clinica'
      'Domiciliar + Clínica'
    when 'domiciliar_escola'
      'Domiciliar + Escola'
    when 'domiciliar_clinica_escola'
      'Domiciliar + Clínica + Escola'
    else
      treatment_location.humanize
    end
  end

  def birth_type_label
    return nil if birth_type.blank?

    { 'normal' => 'Normal', 'cesarea' => 'Cesárea', 'forceps' => 'Fórceps' }[birth_type]
  end

  def birth_location_type_label
    return nil if birth_location_type.blank?

    { 'domiciliar' => 'Domiciliar', 'hospitalar' => 'Hospitalar' }[birth_location_type]
  end

  def birth_term_label
    return nil if birth_term.blank?

    { 'pre_termo' => 'Pré-termo', 'termo' => 'A termo', 'pos_termo' => 'Pós-termo' }[birth_term]
  end

  def anesthesia_type_label
    return nil if anesthesia_type.blank?

    { 'raquidiana' => 'Raquidiana', 'epidural' => 'Epidural' }[anesthesia_type]
  end

  def baby_position_label
    return nil if baby_position.blank?

    {
      'cefalico' => 'Cefálico',
      'pelvico_pe' => 'Pélvico – pé',
      'pelvico_nadega' => 'Pélvico – nádega',
      'transverso' => 'Transverso'
    }[baby_position]
  end

  def school_period_label
    return nil if school_period.blank?

    { 'manha' => 'Manhã', 'tarde' => 'Tarde', 'integral' => 'Integral' }[school_period]
  end

  def pode_ser_editada?
    pendente? || em_andamento?
  end

  def pode_ser_concluida?
    em_andamento?
  end

  def pode_ser_iniciada?
    pendente?
  end

  def iniciar!(professional)
    return false unless pode_ser_iniciada?

    update!(
      status: 'em_andamento',
      updated_by_professional: professional
    )
  end

  def concluir!(professional)
    return false unless pode_ser_concluida?

    unless beneficiary.present? || portal_intake_has_minimum_data?
      errors.add(:base, I18n.t('admin.anamneses.errors.missing_beneficiary_data'))
      return false
    end

    transaction do
      update!(
        status: 'concluida',
        updated_by_professional: professional
      )

      create_beneficiary_from_portal_intake if portal_intake_id?
    end
  rescue StandardError
    errors.add(:base, I18n.t('admin.anamneses.errors.beneficiary_creation_failed'))
    false
  end

  def portal_intake_has_minimum_data?
    return false if portal_intake.blank?

    cpf = portal_intake.cpf.to_s
    birth = portal_intake.data_nascimento
    cpf.present? && cpf.match?(/\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/) && birth.present?
  end

  def marcar_como_compareceu!(professional)
    update!(
      attendance_status: 'attended',
      attended_at: Time.current,
      updated_by_professional: professional
    )
  end

  def marcar_como_nao_compareceu!(professional, reason = nil)
    update!(
      attendance_status: 'no_show',
      no_show_at: Time.current,
      no_show_reason: reason,
      updated_by_professional: professional
    )
  end

  def cancelar!(professional, reason)
    update!(
      attendance_status: 'cancelled',
      cancelled_at: Time.current,
      cancellation_reason: reason,
      status: 'pendente',
      updated_by_professional: professional
    )
  end

  def reagendar!(professional, new_datetime)
    update!(
      attendance_status: 'rescheduled',
      performed_at: new_datetime,
      status: 'pendente',
      updated_by_professional: professional
    )
  end

  def pode_marcar_comparecimento?
    scheduled? && (pendente? || em_andamento?)
  end

  def pode_reagendar?
    no_show? || cancelled?
  end

  def specialties_array
    return [] if specialties.blank?

    specialties.is_a?(Array) ? specialties : JSON.parse(specialties)
  rescue JSON::ParserError
    []
  end

  def previous_treatments_array
    return [] if previous_treatments.blank?

    previous_treatments.is_a?(Array) ? previous_treatments : JSON.parse(previous_treatments)
  rescue JSON::ParserError
    []
  end

  def external_treatments_array
    return [] if external_treatments.blank?

    external_treatments.is_a?(Array) ? external_treatments : JSON.parse(external_treatments)
  rescue JSON::ParserError
    []
  end

  def preferred_schedule_array
    return [] if preferred_schedule.blank?

    preferred_schedule.is_a?(Array) ? preferred_schedule : JSON.parse(preferred_schedule)
  rescue JSON::ParserError
    []
  end

  def unavailable_schedule_array
    return [] if unavailable_schedule.blank?

    unavailable_schedule.is_a?(Array) ? unavailable_schedule : JSON.parse(unavailable_schedule)
  rescue JSON::ParserError
    []
  end

  def family_composition_array
    return [] if family_composition.blank?

    family_composition.is_a?(Array) ? family_composition : JSON.parse(family_composition)
  rescue JSON::ParserError
    []
  end

  def family_conditions_array
    return [] if family_conditions.blank?

    family_conditions.is_a?(Array) ? family_conditions : JSON.parse(family_conditions)
  rescue JSON::ParserError
    []
  end

  def self.by_professional_today(professional)
    by_professional(professional).today
  end

  def self.by_professional_week(professional)
    by_professional(professional).this_week
  end

  def self.pendentes
    where(status: 'pendente')
  end

  def self.em_andamento
    where(status: 'em_andamento')
  end

  def self.concluidas
    where(status: 'concluida')
  end

  def self.search_by_term(term)
    return all if term.blank?

    joins(:beneficiary, :professional).where(
      'beneficiaries.name ILIKE ? OR users.full_name ILIKE ? OR anamneses.referral_reason ILIKE ?',
      "%#{term}%", "%#{term}%", "%#{term}%"
    )
  end

  private

  def set_default_values
    self.performed_at ||= Time.current
    self.created_by_professional ||= professional
  end

  def create_beneficiary_from_portal_intake
    return unless portal_intake_id? && beneficiary.nil?

    ActiveRecord::Base.transaction do
      beneficiary = Beneficiary.new(
        name: portal_intake.nome || portal_intake.beneficiary_name,
        birth_date: portal_intake.data_nascimento,
        cpf: portal_intake.cpf,
        phone: portal_intake.telefone_responsavel,
        address: portal_intake.endereco,
        responsible_name: portal_intake.responsavel,
        responsible_phone: portal_intake.telefone_responsavel,
        health_plan: portal_intake.plan_name,
        card_code: portal_intake.card_code,
        plan_name: portal_intake.plan_name,
        tipo_convenio: portal_intake.tipo_convenio,
        data_encaminhamento: portal_intake.data_encaminhamento,
        data_recebimento_email: portal_intake.data_recebimento_email,
        external_user_id: portal_intake.operator_id,
        status: 'ativo',
        treatment_start_date: Date.current,
        created_by_professional: professional,
        portal_intake: portal_intake
      )

      portal_intake.portal_intake_referrals.each do |referral|
        next if referral.cid.blank? && referral.encaminhado_para.blank? &&
                referral.medico.blank? && referral.medico_crm.blank? &&
                referral.data_encaminhamento.blank? && referral.descricao.blank?

        beneficiary.beneficiary_referrals.build(
          cid: referral.cid,
          encaminhado_para: referral.encaminhado_para,
          medico: referral.medico,
          medico_crm: referral.medico_crm,
          data_encaminhamento: referral.data_encaminhamento,
          descricao: referral.descricao
        )
      end

      beneficiary.save!
      update!(beneficiary: beneficiary)
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, "Falha ao criar beneficiário: #{e.record.errors.full_messages.to_sentence}")
    false
  end
end
