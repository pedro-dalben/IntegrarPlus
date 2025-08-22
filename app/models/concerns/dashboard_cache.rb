# frozen_string_literal: true

module DashboardCache
  extend ActiveSupport::Concern

  included do
    after_save :clear_dashboard_cache
    after_destroy :clear_dashboard_cache
  end

  private

  def clear_dashboard_cache
    Rails.cache.delete('dashboard_metrics')
  end
end
