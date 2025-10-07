# frozen_string_literal: true

module Portal
  class PortalIntakesController < BaseController
    before_action :set_portal_intake, only: [:show]
    rescue_from Pundit::NotAuthorizedError, with: :handle_authorization_error

    def index
      @portal_intakes = policy_scope(PortalIntake, policy_scope_class: PortalIntakePolicy::Scope)
                        .includes(:journey_events)
                        .recent

      @portal_intakes = apply_filters(@portal_intakes)
      @pagy, @portal_intakes = pagy(@portal_intakes, items: 20)

      @statuses = PortalIntake.statuses.keys
    end

    def show
      authorize @portal_intake
    end

    def new
      @portal_intake = PortalIntake.new
      @portal_intake.data_encaminhamento = Date.current
      @portal_intake.convenio = current_external_user.company_name
      @portal_intake.portal_intake_referrals.build
      authorize @portal_intake
    end

    def create
      @portal_intake = PortalIntake.new(portal_intake_params)
      @portal_intake.operator = current_external_user
      @portal_intake.requested_at = Time.current
      @portal_intake.data_encaminhamento = Date.current # Sempre usar a data atual
      @portal_intake.convenio = current_external_user.company_name # Sempre usar o convênio do usuário logado
      @portal_intake.plan_name = current_external_user.company_name # Plano médico é o mesmo que o convênio
      @portal_intake.beneficiary_name = @portal_intake.nome # beneficiary_name é o mesmo que nome
      authorize @portal_intake

      if @portal_intake.save
        redirect_to portal_portal_intake_path(@portal_intake),
                    notice: 'Solicitação enviada com sucesso! Aguarde o agendamento da anamnese.'
      else
        # Reconstruir os encaminhamentos em caso de erro
        @portal_intake.portal_intake_referrals.build if @portal_intake.portal_intake_referrals.empty?
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_portal_intake
      @portal_intake = PortalIntake.find(params[:id])
    end

    def portal_intake_params
      permitted_params = params.expect(
        portal_intake: [
          :beneficiary_name, :plan_name, :card_code,
          :carteira_codigo, :nome, :telefone_responsavel,
          :data_encaminhamento, :data_nascimento, :endereco, :responsavel,
          :tipo_convenio, :cpf,
          { portal_intake_referrals_attributes: %i[
            id cid encaminhado_para medico medico_crm data_encaminhamento descricao _destroy
          ] }
        ]
      )

      # Sanitizar parâmetros adicionais
      sanitize_portal_intake_params(permitted_params)
    end

    def sanitize_portal_intake_params(params)
      portal_intake = params[:portal_intake]
      return params unless portal_intake

      # Sanitizar campos de texto
      text_fields = %w[beneficiary_name plan_name card_code carteira_codigo nome
                       endereco responsavel convenio]

      text_fields.each do |field|
        next unless portal_intake[field].present?

        # Remover caracteres perigosos
        portal_intake[field] = portal_intake[field].gsub(/[<>'"&]/, '')
      end

      # Sanitizar CPF - manter apenas números e formatação
      portal_intake[:cpf] = portal_intake[:cpf].gsub(/[^0-9.-]/, '') if portal_intake[:cpf].present?

      # Sanitizar telefone - manter apenas números e formatação
      if portal_intake[:telefone_responsavel].present?
        portal_intake[:telefone_responsavel] = portal_intake[:telefone_responsavel].gsub(/[^0-9()\s-]/, '')
      end

      # Sanitizar encaminhamentos
      if portal_intake[:portal_intake_referrals_attributes]
        portal_intake[:portal_intake_referrals_attributes].each do |_key, referral|
          next unless referral.is_a?(Hash)

          # Sanitizar campos de texto do encaminhamento
          %w[medico descricao].each do |field|
            next unless referral[field].present?

            referral[field] = referral[field].gsub(/[<>'"&]/, '')
          end

          # Sanitizar CID - manter apenas letras, números e ponto
          referral[:cid] = referral[:cid].gsub(/[^A-Za-z0-9.]/, '').upcase if referral[:cid].present?

          # Sanitizar CRM - manter apenas números
          referral[:medico_crm] = referral[:medico_crm].gsub(/[^0-9]/, '') if referral[:medico_crm].present?
        end
      end

      params
    end

    def apply_filters(scope)
      scope = scope.by_status(params[:status]) if params[:status].present?
      if params[:start_date].present? && params[:end_date].present?
        scope = scope.requested_between(Date.parse(params[:start_date]),
                                        Date.parse(params[:end_date]))
      end
      scope
    rescue Date::Error
      scope
    end

    def handle_authorization_error(_exception)
      if current_external_user && !current_external_user.active?
        redirect_to portal_new_external_user_session_path,
                    alert: 'Sua conta foi desativada. Entre em contato com o administrador do sistema para reativar seu acesso.'
      else
        redirect_to portal_root_path,
                    alert: 'Você não tem permissão para realizar esta ação.'
      end
    end
  end
end
