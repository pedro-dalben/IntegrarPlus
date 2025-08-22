# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    before_action :authenticate_user!

    def index
      # Calcular métricas com cache para melhor performance
      @metrics = Rails.cache.fetch('dashboard_metrics', expires_in: 5.minutes) do
        calculate_metrics
      end

      # Métricas em tempo real (sem cache)
      @recent_activity = recent_activity_data
    end

    private

    def calculate_metrics
      {
        total_professionals: Professional.count,
        active_professionals: Professional.where(active: true).count,
        inactive_professionals: Professional.where(active: false).count,
        total_specialities: Speciality.count,
        total_specializations: Specialization.count,
        total_contract_types: ContractType.count,
        total_groups: Group.count,
        total_users: User.count,
        professionals_created_this_month: Professional.where(created_at: Time.current.all_month).count,
        users_created_this_month: User.where(created_at: Time.current.all_month).count
      }
    end

    def recent_activity_data
      {
        last_professional_created: Professional.joins(:user).order(:created_at).last,
        last_user_created: User.order(:created_at).last,
        recent_professionals: Professional.joins(:user).order(created_at: :desc).limit(5),
        recent_users: User.order(created_at: :desc).limit(5)
      }
    end
  end
end
