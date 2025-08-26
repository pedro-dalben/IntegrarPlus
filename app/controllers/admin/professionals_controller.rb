# frozen_string_literal: true

require 'ostruct'

module Admin
  class ProfessionalsController < BaseController
    before_action :set_professional, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        @pagy, @professionals = pagy_meilisearch(Professional, query: params[:query], limit: 10)
      else
        @pagy, @professionals = pagy(Professional.all, limit: 10)
      end

      return unless request.xhr?

      render partial: 'table', locals: { professionals: @professionals, pagy: @pagy }, layout: false
    end

    def show; end

    def new
      @professional = Professional.new
      load_form_data
    end

    def edit
      load_form_data
    end

    def create
      @professional = Professional.new(professional_params)

      if @professional.save
        # Criar usuário automaticamente
        create_user_for_professional(@professional)

        redirect_to admin_professional_path(@professional), notice: 'Profissional criado com sucesso.'
      else
        load_form_data
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @professional.update(professional_params)
        # Criar usuário se não existir
        create_user_for_professional(@professional)

        redirect_to admin_professional_path(@professional), notice: 'Profissional atualizado com sucesso.'
      else
        load_form_data
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @professional.destroy
      redirect_to admin_professionals_path, notice: 'Profissional excluído com sucesso.'
    end

    def create_user
      if @professional.user.present?
        redirect_to admin_professional_path(@professional), alert: 'Este profissional já possui um usuário.'
        return
      end

      create_user_for_professional(@professional)
      redirect_to admin_professional_path(@professional), notice: 'Usuário criado com sucesso para o profissional.'
    rescue StandardError => e
      redirect_to admin_professional_path(@professional), alert: "Erro ao criar usuário: #{e.message}"
    end

    private

    def set_professional
      @professional = Professional.find(params[:id])
    end

    def professional_params
      params.require(:professional).permit(
        :full_name, :birth_date, :cpf, :phone, :email, :active,
        :contract_type_id, :hired_on, :workload_hhmm, :workload_minutes, :council_code,
        :company_name, :cnpj,
        group_ids: [], speciality_ids: [], specialization_ids: []
      )
    end

    def load_form_data
      @contract_types = ContractType.active.ordered
      @groups = Group.ordered
      @specialities = Speciality.active.ordered
    end

    def create_user_for_professional(professional)
      return if professional.user.present?

      # Gerar senha temporária
      temp_password = SecureRandom.hex(8)

      # Criar usuário com dados do profissional
      user = User.create!(
        name: professional.full_name,
        email: professional.email,
        password: temp_password,
        password_confirmation: temp_password
      )

      # Associar usuário ao profissional
      professional.update!(user: user)

      # Associar grupos do profissional ao usuário
      professional.groups.each do |group|
        user.memberships.create!(group: group)
        Rails.logger.info "Grupo '#{group.name}' associado ao usuário #{user.email}"
      end

      # Criar convite se o profissional estiver ativo
      if professional.active?
        invite = user.invites.create!
        Rails.logger.info "Convite criado para #{user.email}: #{invite.invite_url}"
      end

      Rails.logger.info "Usuário criado automaticamente para profissional: #{professional.full_name}"
    rescue StandardError => e
      Rails.logger.error "Erro ao criar usuário para profissional #{professional.id}: #{e.message}"
    end
  end
end
