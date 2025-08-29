class OrganogramMember < ApplicationRecord
  belongs_to :organogram

  validates :name, presence: true, length: { maximum: 100 }
  validates :external_id, uniqueness: { scope: :organogram_id }, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, length: { maximum: 20 }, allow_blank: true
  validates :role_title, length: { maximum: 100 }, allow_blank: true
  validates :department, length: { maximum: 100 }, allow_blank: true

  before_validation :set_defaults, on: :create
  before_validation :normalize_data

  scope :by_department, ->(dept) { where(department: dept) }
  scope :ordered, -> { order(:name) }

  def full_contact_info
    info = []
    info << email if email.present?
    info << phone if phone.present?
    info.join(' • ')
  end

  def display_title
    [role_title, department].compact.join(' - ')
  end

  def to_node_data
    {
      id: external_id || id.to_s,
      text: name,
      title: role_title,
      data: {
        department: department,
        email: email,
        phone: phone
      }.compact.merge(meta || {})
    }
  end

  private

  def set_defaults
    self.meta ||= {}
    self.external_id ||= SecureRandom.uuid if external_id.blank?
  end

  def normalize_data
    self.email = email&.downcase&.strip
    self.phone = phone&.gsub(/\D/, '') if phone.present?
    self.name = name&.strip&.titleize
    self.role_title = role_title&.strip&.titleize
    self.department = department&.strip&.titleize
  end
end
