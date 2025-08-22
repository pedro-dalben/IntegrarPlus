class Document < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_many :document_versions, dependent: :destroy
  has_many :document_permissions, dependent: :destroy
  has_one_attached :file

  enum :document_type, {
    relatorio: 0,
    laudo: 1,
    contrato: 2,
    outros: 3
  }

  enum :status, {
    aguardando_revisao: 0,
    aguardando_correcoes: 1,
    aguardando_liberacao: 2,
    liberado: 3
  }

  validates :title, presence: true, length: { maximum: 150 }
  validates :document_type, presence: true
  validates :current_version, presence: true
  validates :status, presence: true

  before_validation :set_defaults, on: :create

  def latest_version
    document_versions.order(:version_number).last
  end

  def user_can_access?(user, required_level = :visualizar)
    return true if user == author
    return true if user.admin?

    permission = find_user_permission(user)
    return false unless permission

    required_level_index = self.class.access_levels[required_level.to_s]
    permission_level_index = self.class.access_levels[permission.access_level]
    
    permission_level_index >= required_level_index
  end

  def user_can_view?(user)
    user_can_access?(user, :visualizar)
  end

  def user_can_comment?(user)
    user_can_access?(user, :comentar)
  end

  def user_can_edit?(user)
    user_can_access?(user, :editar)
  end

  def find_user_permission(user)
    document_permissions.for_user_and_groups(user).order(:access_level).last
  end

  def grant_permission(user_or_group, access_level)
    if user_or_group.is_a?(User)
      document_permissions.find_or_initialize_by(user: user_or_group).tap do |permission|
        permission.access_level = access_level
        permission.save!
      end
    elsif user_or_group.is_a?(Group)
      document_permissions.find_or_initialize_by(group: user_or_group).tap do |permission|
        permission.access_level = access_level
        permission.save!
      end
    end
  end

  def revoke_permission(user_or_group)
    if user_or_group.is_a?(User)
      document_permissions.where(user: user_or_group).destroy_all
    elsif user_or_group.is_a?(Group)
      document_permissions.where(group: user_or_group).destroy_all
    end
  end

  def create_new_version(file, user, notes = nil)
    next_version = calculate_next_version
    version = document_versions.create!(
      version_number: next_version,
      file_path: generate_file_path(next_version, file),
      created_by: user,
      notes: notes
    )

    save_file_to_storage(file, version.file_path)
    update!(current_version: next_version)
    version
  end

  private

  def set_defaults
    self.status ||= :aguardando_revisao
    self.current_version ||= '1.0'
  end

  def calculate_next_version
    if document_versions.empty?
      '1.0'
    else
      latest = document_versions.order(:version_number).last.version_number
      major, minor = latest.split('.').map(&:to_i)
      "#{major}.#{minor + 1}"
    end
  end

  def generate_file_path(version, file)
    extension = File.extname(file.original_filename)
    "documents/#{id}/versions/#{version}#{extension}"
  end

  def save_file_to_storage(file, file_path)
    full_path = Rails.root.join('storage', file_path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.binwrite(full_path, file.read)
  end
end
