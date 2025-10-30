# frozen_string_literal: true

class MedicalAppointment < ApplicationRecord
  belongs_to :agenda
  belongs_to :professional, class_name: 'Professional'
  belongs_to :patient, class_name: 'User', optional: true
  belongs_to :event, optional: true
  belongs_to :anamnesis, optional: true
  has_many :appointment_notes, dependent: :destroy
  has_many :appointment_attachments, dependent: :destroy

  enum :appointment_type, {
    initial_consultation: 'initial_consultation',
    return_consultation: 'return_consultation',
    emergency_consultation: 'emergency_consultation',
    procedure: 'procedure',
    exam: 'exam',
    therapy: 'therapy',
    evaluation: 'evaluation'
  }

  enum :status, {
    scheduled: 'scheduled',
    confirmed: 'confirmed',
    in_progress: 'in_progress',
    completed: 'completed',
    cancelled: 'cancelled',
    no_show: 'no_show',
    rescheduled: 'rescheduled'
  }

  enum :priority, {
    low: 'low',
    normal: 'normal',
    high: 'high',
    urgent: 'urgent'
  }

  validates :appointment_type, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :scheduled_at, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }

  scope :today, -> { where(scheduled_at: Date.current.all_day) }
  scope :this_week, -> { where(scheduled_at: Date.current.all_week) }
  scope :this_month, -> { where(scheduled_at: Date.current.all_month) }
  scope :by_professional, ->(professional) { where(professional: professional) }
  scope :by_type, ->(type) { where(appointment_type: type) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }

  def self.occupation_rate(professional, date_range)
    total_slots = professional.agenda_professionals.joins(:agenda)
                              .where(agendas: { status: 'active' })
                              .sum(:capacity_per_slot)

    occupied_slots = where(professional: professional, scheduled_at: date_range)
                     .where.not(status: %w[cancelled no_show])
                     .count

    return 0 if total_slots.zero?

    (occupied_slots.to_f / total_slots * 100).round(2)
  end

  def self.completion_rate(professional, date_range)
    total_appointments = where(professional: professional, scheduled_at: date_range)
                         .where.not(status: 'cancelled')

    completed_appointments = total_appointments.where(status: 'completed')

    return 0 if total_appointments.empty?

    (completed_appointments.count.to_f / total_appointments.count * 100).round(2)
  end

  def self.no_show_rate(professional, date_range)
    total_appointments = where(professional: professional, scheduled_at: date_range)
                         .where.not(status: 'cancelled')

    no_show_appointments = total_appointments.where(status: 'no_show')

    return 0 if total_appointments.empty?

    (no_show_appointments.count.to_f / total_appointments.count * 100).round(2)
  end

  def self.average_duration(professional, date_range)
    completed_appointments = where(professional: professional, scheduled_at: date_range, status: 'completed')

    return 0 if completed_appointments.empty?

    completed_appointments.average(:duration_minutes).round(2)
  end

  def can_be_cancelled?
    scheduled_at > Time.current && !completed?
  end

  def can_be_rescheduled?
    scheduled_at > Time.current && !completed?
  end

  def can_be_edited?
    !completed? && !cancelled?
  end

  def is_urgent?
    urgent? || emergency_consultation?
  end

  def is_emergency?
    emergency_consultation? || urgent?
  end

  def duration_hours
    (duration_minutes / 60.0).round(2)
  end

  def time_until_appointment
    return nil if scheduled_at < Time.current

    ((scheduled_at - Time.current) / 1.hour).round(2)
  end

  def is_today?
    scheduled_at.to_date == Date.current
  end

  def is_this_week?
    scheduled_at.to_date.between?(Date.current.beginning_of_week, Date.current.end_of_week)
  end

  def is_this_month?
    scheduled_at.to_date.between?(Date.current.beginning_of_month, Date.current.end_of_month)
  end

  def status_color
    case status
    when 'scheduled' then 'blue'
    when 'confirmed' then 'green'
    when 'in_progress' then 'yellow'
    when 'completed' then 'green'
    when 'cancelled' then 'red'
    when 'no_show' then 'red'
    when 'rescheduled' then 'orange'
    else 'gray'
    end
  end

  def priority_color
    case priority
    when 'low' then 'green'
    when 'normal' then 'blue'
    when 'high' then 'orange'
    when 'urgent' then 'red'
    else 'gray'
    end
  end

  def type_icon
    case appointment_type
    when 'initial_consultation' then 'user-plus'
    when 'return_consultation' then 'user-check'
    when 'emergency_consultation' then 'alert-triangle'
    when 'procedure' then 'scissors'
    when 'exam' then 'clipboard-check'
    when 'therapy' then 'heart'
    when 'evaluation' then 'search'
    else 'calendar'
    end
  end

  def type_color
    case appointment_type
    when 'initial_consultation' then 'blue'
    when 'return_consultation' then 'green'
    when 'emergency_consultation' then 'red'
    when 'procedure' then 'purple'
    when 'exam' then 'yellow'
    when 'therapy' then 'pink'
    when 'evaluation' then 'indigo'
    else 'gray'
    end
  end

  STATUS_LABELS = {
    'scheduled' => 'Agendado',
    'confirmed' => 'Confirmado',
    'in_progress' => 'Em andamento',
    'completed' => 'Concluído',
    'cancelled' => 'Cancelado',
    'no_show' => 'Não compareceu',
    'rescheduled' => 'Reagendado'
  }.freeze

  PRIORITY_LABELS = {
    'low' => 'Baixa',
    'normal' => 'Normal',
    'high' => 'Alta',
    'urgent' => 'Urgente'
  }.freeze

  TYPE_LABELS = {
    'initial_consultation' => 'Consulta inicial',
    'return_consultation' => 'Retorno',
    'emergency_consultation' => 'Emergência',
    'procedure' => 'Procedimento',
    'exam' => 'Exame',
    'therapy' => 'Terapia',
    'evaluation' => 'Avaliação'
  }.freeze

  def display_status
    STATUS_LABELS[status] || status.to_s.humanize
  end

  def display_priority
    PRIORITY_LABELS[priority] || priority.to_s.humanize
  end

  def display_appointment_type
    TYPE_LABELS[appointment_type] || appointment_type.to_s.humanize
  end

  def send_notifications
    notification_methods = {
      'scheduled' => :send_initial_notifications,
      'confirmed' => :send_confirmation_notifications,
      'cancelled' => :send_cancellation_notifications,
      'rescheduled' => :send_reschedule_notifications,
      'completed' => :send_completion_notifications,
      'no_show' => :send_no_show_notifications
    }

    method_name = notification_methods[status]
    send(method_name) if method_name
  end

  private

  def send_initial_notifications
    MedicalAppointmentMailer.appointment_scheduled(self).deliver_later
    MedicalAppointmentMailer.professional_notification(self).deliver_later
  end

  def send_confirmation_notifications
    MedicalAppointmentMailer.appointment_confirmed(self).deliver_later
    MedicalAppointmentMailer.professional_confirmation(self).deliver_later
  end

  def send_cancellation_notifications
    MedicalAppointmentMailer.appointment_cancelled(self).deliver_later
    MedicalAppointmentMailer.professional_cancellation(self).deliver_later
  end

  def send_reschedule_notifications
    MedicalAppointmentMailer.appointment_rescheduled(self).deliver_later
    MedicalAppointmentMailer.professional_reschedule(self).deliver_later
  end

  def send_completion_notifications
    MedicalAppointmentMailer.appointment_completed(self).deliver_later
  end

  def send_no_show_notifications
    MedicalAppointmentMailer.appointment_no_show(self).deliver_later
    MedicalAppointmentMailer.professional_no_show(self).deliver_later
  end
end
