class School < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  validates :name, presence: true, length: { minimum: 3 }
  validates :city, presence: true
  validates :state, presence: true, length: { is: 2 }
  validates :code, uniqueness: true, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :school_type, inclusion: { in: %w[municipal estadual particular federal], allow_blank: true }
  validates :network, inclusion: { in: %w[publica privada], allow_blank: true }

  scope :active, -> { where(active: true) }
  scope :by_city, ->(city) { where(city: city) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_type, ->(type) { where(school_type: type) }
  scope :by_network, ->(network) { where(network: network) }
  scope :search_by_name, ->(query) { where('LOWER(name) LIKE ?', "%#{query.downcase}%") }

  before_validation :normalize_state

  def full_address
    parts = []
    parts << address if address.present?
    parts << neighborhood if neighborhood.present?
    parts << "#{city} - #{state}" if city.present? && state.present?
    parts.join(', ')
  end

  def type_label
    return '' if school_type.blank?

    I18n.t("activerecord.attributes.school.school_types.#{school_type}", default: school_type.humanize)
  end

  def network_label
    return '' if network.blank?

    I18n.t("activerecord.attributes.school.networks.#{network}", default: network.humanize)
  end

  private

  def normalize_state
    self.state = state.upcase if state.present?
  end
end
