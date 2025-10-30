# frozen_string_literal: true

module PortalIntakes
  class ReferralsComponent < ViewComponent::Base
    def initialize(form:, container_id:, add_button_id:, remove_button_class:,
                   title: 'Dados dos Encaminhamentos (Opcional)')
      @form = form
      @title = title
      @container_id = container_id
      @add_button_id = add_button_id
      @remove_button_class = remove_button_class
    end

    private

    attr_reader :form, :title, :container_id, :add_button_id, :remove_button_class
  end
end
