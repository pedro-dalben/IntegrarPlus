# frozen_string_literal: true

class DocumentRelease < ApplicationRecord
  belongs_to :document
  belongs_to :version, class_name: 'DocumentVersion'
  belongs_to :released_by, class_name: 'User'

  validates :released_at, presence: true

  scope :ordered, -> { order(released_at: :desc) }

  delegate :version_number, to: :version

  def released_version_path
    File.join('storage', 'documents', document.id.to_s, 'released',
              "v#{version_number}#{File.extname(version.file_path)}")
  end

  def released_file_exists?
    Rails.root.join(released_version_path).exist?
  end
end
