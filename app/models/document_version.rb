class DocumentVersion < ApplicationRecord
  belongs_to :document
  belongs_to :created_by, class_name: 'User'
  has_many :version_comments, dependent: :destroy

  validates :version_number, presence: true
  validates :file_path, presence: true
  validates :version_number, uniqueness: { scope: :document_id }

  def file_exists?
    File.exist?(Rails.root.join('storage', file_path))
  end

  def file_size
    return 0 unless file_exists?

    File.size(Rails.root.join('storage', file_path))
  end

  def file_extension
    File.extname(file_path).downcase
  end
end
