# frozen_string_literal: true

# Modelo para templates de agenda
class AgendaTemplate < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  has_many :agendas, dependent: :nullify

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :template_data, presence: true
  validates :category, presence: true

  enum :category, {
    consulta_medica: 0,
    anamnese: 1,
    atendimento_psicologico: 2,
    reabilitacao: 3,
    reuniao_equipe: 4,
    treinamento: 5,
    outro: 6
  }

  enum :visibility, {
    private_template: 0,
    unit_template: 1,
    global_template: 2
  }

  scope :by_category, ->(category) { where(category: category) }
  scope :visible_for_user, ->(user) {
    where(visibility: [:unit_template, :global_template])
      .or(where(created_by: user, visibility: :private_template))
  }
  scope :popular, -> { order(usage_count: :desc) }
  scope :recent, -> { order(created_at: :desc) }

  def apply_to_agenda(agenda)
    template_data.each do |key, value|
      next unless agenda.respond_to?("#{key}=")

      agenda.send("#{key}=", value)
    end

    increment_usage_count
  end

  def create_agenda_from_template(user, custom_attributes = {})
    agenda = Agenda.new(template_data.merge(custom_attributes))
    agenda.created_by = user
    agenda.updated_by = user
    agenda.status = :draft

    if agenda.save
      increment_usage_count
      agenda
    else
      nil
    end
  end

  def self.create_from_agenda(agenda, template_name = nil)
    template_name ||= "Template baseado em #{agenda.name}"

    create!(
      name: template_name,
      description: "Template criado a partir da agenda '#{agenda.name}'",
      category: map_service_type_to_category(agenda.service_type),
      template_data: extract_template_data(agenda),
      created_by: agenda.created_by,
      visibility: :private_template
    )
  end

  def preview_data
    {
      name: template_data['name'] || 'Nome da Agenda',
      service_type: template_data['service_type'] || 'consulta',
      slot_duration: template_data['slot_duration_minutes'] || 50,
      buffer_minutes: template_data['buffer_minutes'] || 10,
      working_hours: template_data['working_hours'] || default_working_hours,
      color_theme: template_data['color_theme'] || '#3B82F6'
    }
  end

  def usage_count
    read_attribute(:usage_count) || 0
  end

  def can_be_used_by?(user)
    case visibility
    when 'private_template'
      created_by == user
    when 'unit_template'
      user.unit_id == created_by.unit_id
    when 'global_template'
      true
    else
      false
    end
  end

  def duplicate_for_user(user)
    new_template = dup
    new_template.name = "#{name} (Cópia)"
    new_template.created_by = user
    new_template.visibility = :private_template
    new_template.usage_count = 0
    new_template.save
  end

  private

  def increment_usage_count
    increment!(:usage_count)
  end

  def self.map_service_type_to_category(service_type)
    case service_type
    when 'consulta'
      :consulta_medica
    when 'anamnese'
      :anamnese
    when 'atendimento'
      :atendimento_psicologico
    when 'reuniao'
      :reuniao_equipe
    else
      :outro
    end
  end

  def self.extract_template_data(agenda)
    {
      'service_type' => agenda.service_type,
      'default_visibility' => agenda.default_visibility,
      'slot_duration_minutes' => agenda.slot_duration_minutes,
      'buffer_minutes' => agenda.buffer_minutes,
      'working_hours' => agenda.working_hours,
      'color_theme' => agenda.color_theme,
      'notes' => agenda.notes
    }
  end

  def default_working_hours
    self.class.default_working_hours
  end

  def self.default_working_hours
    {
      'slot_duration' => 50,
      'buffer' => 10,
      'weekdays' => generate_default_weekdays,
      'exceptions' => []
    }
  end

  def self.generate_default_weekdays
    (1..5).map do |wday|
      {
        'wday' => wday,
        'periods' => [
          { 'start' => '08:00', 'end' => '12:00' },
          { 'start' => '14:00', 'end' => '18:00' }
        ]
      }
    end
  end
end
