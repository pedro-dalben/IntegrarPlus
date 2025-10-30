# frozen_string_literal: true

module Admin
  class SchoolsController < BaseController
    before_action :set_school, only: %i[show edit update destroy activate deactivate]

    def index
      authorize School, policy_class: Admin::SchoolPolicy

      @schools = School.order(:name)

      @schools = @schools.search_by_name(params[:query]) if params[:query].present?
      @schools = @schools.by_city(params[:city]) if params[:city].present?
      @schools = @schools.by_state(params[:state]) if params[:state].present?
      @schools = @schools.by_type(params[:school_type]) if params[:school_type].present?
      @schools = @schools.by_network(params[:network]) if params[:network].present?
      @schools = @schools.active if params[:status] == 'active'
      @schools = @schools.where(active: false) if params[:status] == 'inactive'
    end

    def show
      authorize @school, policy_class: Admin::SchoolPolicy
    end

    def new
      @school = School.new
      authorize @school, policy_class: Admin::SchoolPolicy
    end

    def edit
      authorize @school, policy_class: Admin::SchoolPolicy
    end

    def create
      @school = School.new(school_params)
      @school.created_by = current_user
      authorize @school, policy_class: Admin::SchoolPolicy

      if @school.save
        redirect_to [:admin, @school], notice: 'Escola cadastrada com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @school, policy_class: Admin::SchoolPolicy
      @school.updated_by = current_user

      if @school.update(school_params)
        redirect_to [:admin, @school], notice: 'Escola atualizada com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @school, policy_class: Admin::SchoolPolicy

      @school.destroy
      redirect_to admin_schools_path, notice: 'Escola removida com sucesso.'
    end

    def activate
      authorize @school, policy_class: Admin::SchoolPolicy
      @school.update(active: true, updated_by: current_user)
      redirect_to [:admin, @school], notice: 'Escola ativada com sucesso.'
    end

    def deactivate
      authorize @school, policy_class: Admin::SchoolPolicy
      @school.update(active: false, updated_by: current_user)
      redirect_to [:admin, @school], notice: 'Escola desativada com sucesso.'
    end

    def search
      query = params[:q]

      if query.blank? || query.length < 3
        render json: { schools: [], message: 'Digite pelo menos 3 caracteres para buscar' }
        return
      end

      schools = School.active
                      .search_by_name(query)
                      .limit(10)
                      .map do |school|
        {
          id: school.id,
          name: school.name,
          code: school.code,
          address: school.full_address,
          city: school.city,
          state: school.state,
          type: school.type_label
        }
      end

      render json: { schools: schools }
    end

    private

    def set_school
      @school = School.find(params[:id])
    end

    def school_params
      params.expect(
        school: %i[name code address neighborhood city state zip_code
                   phone email school_type network active]
      )
    end
  end
end
