class Agenda < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User', optional: true
  belongs_to :unit, optional: true

  has_many :agenda_professionals, dependent: :destroy
  has_many :professionals, through: :agenda_professionals, source: :professional
  has_many :events, dependent: :restrict_with_error

  enum :service_type, {
    anamnese: 0,
    consulta: 1,
    atendimento: 2,
    reuniao: 3,
    outro: 4
  }

  enum :default_visibility, {
    private_visibility: 0,
    restricted: 1,
    public_visibility: 2
  }

  enum :status, {
    draft: 0,
    active: 1,
    archived: 2
  }

  validates :name, presence: true, length: { maximum: 255 }
  validates :service_type, presence: true
  validates :default_visibility, presence: true
  validates :slot_duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :buffer_minutes, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :color_theme, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: 'deve ser uma cor hexadecimal válida' }
  validates :working_hours, presence: true
  validates :name,
            uniqueness: { scope: %i[unit_id service_type],
                          message: 'já existe uma agenda com este nome para esta unidade e tipo de serviço' }

  validate :validate_working_hours_structure
  validate :validate_professionals_present

  before_validation :set_default_working_hours, on: :create
  before_save :set_updated_by

  scope :active, -> { where(status: :active) }
  scope :draft, -> { where(status: :draft) }
  scope :archived, -> { where(status: :archived) }
  scope :by_service_type, ->(type) { where(service_type: type) }
  scope :by_unit, ->(unit_id) { where(unit_id: unit_id) }
  scope :with_professional, lambda { |professional_id|
    joins(:agenda_professionals).where(agenda_professionals: { professional_id: professional_id })
  }

  def can_be_edited?
    draft? || (active? && events.empty?)
  end

  def can_be_deleted?
    events.empty?
  end

  def duplicate!
    new_agenda = dup
    new_agenda.name = "#{name} (Cópia)"
    new_agenda.status = :draft
    new_agenda.created_by = Current.user
    new_agenda.updated_by = Current.user

    if new_agenda.save
      agenda_professionals.each do |ap|
        new_agenda.agenda_professionals.create!(
          professional: ap.professional,
          capacity_per_slot: ap.capacity_per_slot,
          active: ap.active
        )
      end
    end

    new_agenda
  end

  def working_hours_summary
    return 'Não configurado' if working_hours.blank?

    weekdays = working_hours['weekdays'] || []
    return 'Nenhum dia configurado' if weekdays.empty?

    days = weekdays.map do |day|
      day_name = Date::DAYNAMES[day['wday']]
      periods = day['periods']&.map { |p| "#{p['start']}-#{p['end']}" }&.join(', ')
      "#{day_name}: #{periods}"
    end

    days.join(' | ')
  end

  def slot_summary
    "#{slot_duration_minutes}' + #{buffer_minutes}' buffer"
  end

  private

  def validate_working_hours_structure
    return if working_hours.blank?

    unless working_hours.is_a?(Hash)
      errors.add(:working_hours, 'deve ser um objeto JSON válido')
      return
    end

    weekdays = working_hours['weekdays']
    return unless weekdays.present?

    weekdays.each_with_index do |day, index|
      unless day.is_a?(Hash) && day['wday'].present? && day['periods'].present?
        errors.add(:working_hours, "dia #{index + 1} deve ter wday e periods")
        next
      end

      day['periods'].each_with_index do |period, period_index|
        unless period.is_a?(Hash) && period['start'].present? && period['end'].present?
          errors.add(:working_hours, "período #{period_index + 1} do dia #{index + 1} deve ter start e end")
          next
        end

        begin
          start_time = Time.parse(period['start'])
          end_time = Time.parse(period['end'])

          if end_time <= start_time
            errors.add(:working_hours,
                       "período #{period_index + 1} do dia #{index + 1}: horário de fim deve ser maior que o início")
          end
        rescue ArgumentError
          errors.add(:working_hours, "período #{period_index + 1} do dia #{index + 1}: formato de horário inválido")
        end
      end
    end
  end

  def validate_professionals_present
    return unless agenda_professionals.empty? || agenda_professionals.none?(&:active?)

    errors.add(:professionals, 'deve ter pelo menos um profissional ativo')
  end

  def set_default_working_hours
    return if working_hours.present?

    self.working_hours = {
      'slot_duration' => slot_duration_minutes || 50,
      'buffer' => buffer_minutes || 10,
      'weekdays' => [],
      'exceptions' => []
    }
  end

  def set_updated_by
    self.updated_by = Current.user if Current.user
  end
end
