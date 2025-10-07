# frozen_string_literal: true

module Ui
  class AnamnesesFiltersComponent < ViewComponent::Base
    def initialize(current_user:, params: {})
      @current_user = current_user
      @params = params
      @professionals = load_professionals
    end

    private

    attr_reader :current_user, :params, :professionals

    def load_professionals
      if current_user.permit?('anamneses.view_all')
        User.professionals.order(:full_name)
      else
        [current_user.professional].compact
      end
    end

    def status_options
      [
        ['Todas', ''],
        ['Pendentes', 'pendente'],
        ['Em Andamento', 'em_andamento'],
        ['Concluídas', 'concluida']
      ]
    end

    def referral_reason_options
      [
        ['Todos', ''],
        ['ABA', 'aba'],
        ['Equipe Multi', 'equipe_multi'],
        ['ABA + Equipe Multi', 'aba_equipe_multi']
      ]
    end

    def treatment_location_options
      [
        ['Todos', ''],
        ['Domiciliar', 'domiciliar'],
        ['Clínica', 'clinica'],
        ['Domiciliar + Clínica', 'domiciliar_clinica'],
        ['Domiciliar + Escola', 'domiciliar_escola'],
        ['Domiciliar + Clínica + Escola', 'domiciliar_clinica_escola']
      ]
    end

    def period_options
      [
        ['Todos os períodos', ''],
        ['Hoje', 'today'],
        ['Esta semana', 'this_week'],
        ['Este mês', 'this_month'],
        ['Últimos 7 dias', 'last_7_days'],
        ['Últimos 30 dias', 'last_30_days']
      ]
    end

    def has_active_filters?
      params[:status].present? ||
        params[:professional_id].present? ||
        params[:referral_reason].present? ||
        params[:treatment_location].present? ||
        params[:period].present? ||
        params[:start_date].present? ||
        params[:end_date].present? ||
        params[:include_concluidas] == 'true'
    end

    def filter_count
      count = 0
      count += 1 if params[:status].present?
      count += 1 if params[:professional_id].present?
      count += 1 if params[:referral_reason].present?
      count += 1 if params[:treatment_location].present?
      count += 1 if params[:period].present?
      count += 1 if params[:start_date].present?
      count += 1 if params[:end_date].present?
      count += 1 if params[:include_concluidas] == 'true'
      count
    end
  end
end
