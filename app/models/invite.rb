class Invite < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create
  before_validation :set_expires_at, on: :create

  scope :pending, -> { where(confirmed_at: nil).where('expires_at > ?', Time.current) }
  scope :expired, -> { where(confirmed_at: nil).where('expires_at <= ?', Time.current) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def expired?
    expires_at <= Time.current
  end

  def confirmed?
    confirmed_at.present?
  end

  def pending?
    !expired? && !confirmed?
  end

  def max_attempts_reached?
    attempts_count >= 5
  end

  def increment_attempts!
    increment!(:attempts_count)
  end

  def confirm!
    update!(confirmed_at: Time.current)
  end

  def invite_url
    Rails.application.routes.url_helpers.accept_invite_url(token: token, host: 'localhost:3000')
  end

  private

  def generate_token
    self.token = SecureRandom.hex(16) if token.blank?
  end

  def set_expires_at
    self.expires_at = 7.days.from_now if expires_at.blank?
  end
end
