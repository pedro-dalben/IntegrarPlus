class AppointmentNote < ApplicationRecord
  belongs_to :medical_appointment
  belongs_to :created_by, class_name: 'User'

  enum :note_type, {
    general: 'general',
    symptoms: 'symptoms',
    diagnosis: 'diagnosis',
    treatment: 'treatment',
    prescription: 'prescription',
    observations: 'observations',
    conclusion: 'conclusion',
    referral: 'referral',
    return: 'return'
  }

  validates :note_type, presence: true
  validates :content, presence: true
  validates :created_by, presence: true

  scope :by_type, ->(type) { where(note_type: type) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_creator, ->(user) { where(created_by: user) }

  def formatted_content
    case note_type
    when 'symptoms'
      format_symptoms
    when 'diagnosis'
      format_diagnosis
    when 'treatment'
      format_treatment
    when 'prescription'
      format_prescription
    when 'conclusion'
      format_conclusion
    else
      content
    end
  end

  def type_icon
    case note_type
    when 'general' then 'file-text'
    when 'symptoms' then 'alert-circle'
    when 'diagnosis' then 'search'
    when 'treatment' then 'heart'
    when 'prescription' then 'pill'
    when 'observations' then 'eye'
    when 'conclusion' then 'check-circle'
    when 'referral' then 'arrow-right'
    when 'return' then 'calendar'
    else 'file'
    end
  end

  def type_color
    case note_type
    when 'general' then 'blue'
    when 'symptoms' then 'red'
    when 'diagnosis' then 'purple'
    when 'treatment' then 'green'
    when 'prescription' then 'orange'
    when 'observations' then 'yellow'
    when 'conclusion' then 'green'
    when 'referral' then 'blue'
    when 'return' then 'purple'
    else 'gray'
    end
  end

  def can_be_edited_by?(user)
    return false unless user
    created_by == user || user.admin?
  end

  def can_be_deleted_by?(user)
    return false unless user
    created_by == user || user.admin?
  end

  private

  def format_symptoms
    "Sintomas: #{content}"
  end

  def format_diagnosis
    "Diagnóstico: #{content}"
  end

  def format_treatment
    "Tratamento: #{content}"
  end

  def format_prescription
    "Prescrição: #{content}"
  end

  def format_conclusion
    "Conclusão: #{content}"
  end
end
