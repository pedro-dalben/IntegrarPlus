class News < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :author, presence: true

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(published_at: :desc) }

  def published?
    published && published_at.present? && published_at <= Time.current
  end

  def excerpt(length = 150)
    content.length > length ? "#{content[0, length]}..." : content
  end
end
