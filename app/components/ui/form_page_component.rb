# frozen_string_literal: true

module Ui
  class FormPageComponent < ViewComponent::Base
    renders_one :actions
    renders_many :sections
    renders_one :form_actions

    def initialize(model:, back_path:, title:, subtitle: nil)
      @model = model
      @back_path = back_path
      @title = title
      @subtitle = subtitle
    end

    private

    attr_reader :model, :back_path, :title, :subtitle

    def has_errors?
      model.errors.any?
    end

    def error_messages
      model.errors.full_messages
    end

    def resource_name
      model.class.model_name.human.downcase
    end
  end
end
