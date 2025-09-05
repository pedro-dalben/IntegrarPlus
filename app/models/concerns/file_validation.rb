module FileValidation
  extend ActiveSupport::Concern

  included do
    validate :file_attached
    validate :file_size_limit
    validate :file_type_allowed
  end

  private

  def file_attached
    errors.add(:file, 'deve ser anexado') unless file.attached?
  end

  def file_size_limit
    return unless file.attached?

    max_size = file_size_limits[attachment_type.to_s] || 10.megabytes

    if file.byte_size > max_size
      errors.add(:file, "tamanho máximo permitido: #{max_size / 1.megabyte}MB")
    end
  end

  def file_type_allowed
    return unless file.attached?

    allowed_extensions = allowed_file_types[attachment_type.to_s] || %w[.pdf .jpg .jpeg .png .doc .docx .txt]

    unless allowed_extensions.include?(file_extension)
      errors.add(:file, "tipo de arquivo não permitido para #{attachment_type}")
    end
  end

  def file_size_limits
    {
      'image' => 10.megabytes,
      'document' => 25.megabytes,
      'exam' => 50.megabytes,
      'prescription' => 10.megabytes,
      'certificate' => 10.megabytes,
      'report' => 25.megabytes
    }
  end

  def allowed_file_types
    {
      'image' => %w[.jpg .jpeg .png .gif .bmp .webp],
      'document' => %w[.pdf .doc .docx .txt .rtf],
      'exam' => %w[.pdf .jpg .jpeg .png .dcm .tiff],
      'prescription' => %w[.pdf .jpg .jpeg .png],
      'certificate' => %w[.pdf .jpg .jpeg .png],
      'report' => %w[.pdf .doc .docx .xls .xlsx]
    }
  end
end
