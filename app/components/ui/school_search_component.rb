# frozen_string_literal: true

module Ui
  class SchoolSearchComponent < ViewComponent::Base
    def initialize(form:, field_name: :school_name, placeholder: "Digite o nome da escola para buscar...", value: nil, **options)
      @form = form
      @field_name = field_name
      @placeholder = placeholder
      @value = value
      @options = options
    end

    private

    attr_reader :form, :field_name, :placeholder, :value, :options

    def search_url
      Rails.application.routes.url_helpers.admin_schools_search_path
    end

    def field_id
      "#{form.object_name}_#{field_name}"
    end

    def field_name_with_brackets
      "#{form.object_name}[#{field_name}]"
    end
  end
end
