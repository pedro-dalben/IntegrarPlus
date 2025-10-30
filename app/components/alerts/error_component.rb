# frozen_string_literal: true

module Alerts
  class ErrorComponent < ViewComponent::Base
    def initialize(model:, title: nil)
      @model = model
      @title = title || default_title
    end

    def render?
      @model.present? && @model.errors.any?
    end

    private

    attr_reader :model

    def default_title
      @model.errors.count
      "Erro ao salvar #{@model.class.model_name.human.downcase}"
    end

    def errors_list
      @model.errors.full_messages
    end

    def error_count
      @model.errors.count
    end
  end
end
