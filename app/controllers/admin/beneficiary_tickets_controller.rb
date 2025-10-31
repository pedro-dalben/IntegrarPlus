# frozen_string_literal: true

module Admin
  class BeneficiaryTicketsController < BaseController
    before_action :set_beneficiary
    before_action :set_ticket, only: %i[update destroy]

    def create
      unless current_user.permit?('beneficiary.tabs.tickets.edit')
        return redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'),
                           alert: 'Sem permissão para criar chamados.'
      end

      @ticket = @beneficiary.beneficiary_tickets.build(ticket_params.merge(created_by: current_user))
      if @ticket.save
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'), notice: 'Chamado criado.'
      else
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'),
                    alert: @ticket.errors.full_messages.to_sentence
      end
    end

    def update
      unless current_user.permit?('beneficiary.tabs.tickets.edit')
        return redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'), alert: 'Sem permissão.'
      end

      if @ticket.update(ticket_params)
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'), notice: 'Chamado atualizado.'
      else
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'),
                    alert: @ticket.errors.full_messages.to_sentence
      end
    end

    def destroy
      unless current_user.permit?('beneficiary.tabs.tickets.destroy')
        return redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'), alert: 'Sem permissão.'
      end

      if @ticket.destroy
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'), notice: 'Chamado removido.'
      else
        redirect_to admin_beneficiary_path(@beneficiary, tab: 'tickets'), alert: 'Erro ao remover chamado.'
      end
    end

    private

    def set_beneficiary
      @beneficiary = Beneficiary.find(params[:beneficiary_id])
    end

    def set_ticket
      @ticket = @beneficiary.beneficiary_tickets.find(params[:id])
    end

    def ticket_params
      params.expect(beneficiary_ticket: %i[title description status assigned_professional_id])
    end
  end
end
