# frozen_string_literal: true

class AppointmentAttachment < ApplicationRecord
  include FileValidation

  belongs_to :medical_appointment
  belongs_to :uploaded_by, class_name: 'User'
  has_one_attached :file

  enum :attachment_type, {
    document: 'document',
    image: 'image',
    exam: 'exam',
    prescription: 'prescription',
    certificate: 'certificate',
    report: 'report'
  }

  validates :attachment_type, presence: true
  validates :name, presence: true

  scope :by_type, ->(type) { where(attachment_type: type) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_uploader, ->(user) { where(uploaded_by: user) }

  def file_size_mb
    return 0 unless file.attached?

    (file.byte_size / 1.megabyte.to_f).round(2)
  end

  def file_extension
    return nil unless file.attached?

    File.extname(file.filename.to_s).downcase
  end

  def is_image?
    image? || %w[.jpg .jpeg .png .gif .bmp .webp].include?(file_extension)
  end

  def is_document?
    document? || %w[.pdf .doc .docx .txt .rtf].include?(file_extension)
  end

  def is_exam?
    exam? || %w[.pdf .jpg .jpeg .png .dcm].include?(file_extension)
  end

  def can_be_downloaded_by?(user)
    return false unless user
    return true if user.admin?
    return true if medical_appointment.professional == user
    return true if medical_appointment.patient == user

    false
  end

  def can_be_deleted_by?(user)
    return false unless user

    uploaded_by == user || user.admin?
  end

  def type_icon
    case attachment_type
    when 'document' then 'file-text'
    when 'image' then 'image'
    when 'exam' then 'clipboard-check'
    when 'prescription' then 'pill'
    when 'certificate' then 'award'
    when 'report' then 'file-bar-chart'
    else 'file'
    end
  end

  def type_color
    case attachment_type
    when 'document' then 'blue'
    when 'image' then 'green'
    when 'exam' then 'purple'
    when 'prescription' then 'orange'
    when 'certificate' then 'yellow'
    when 'report' then 'red'
    else 'gray'
    end
  end

  def preview_available?
    is_image? || (document? && file_extension == '.pdf')
  end

  def download_url
    Rails.application.routes.url_helpers.rails_blob_path(file, disposition: 'attachment')
  end

  def preview_url
    Rails.application.routes.url_helpers.rails_blob_path(file, disposition: 'inline')
  end
end
