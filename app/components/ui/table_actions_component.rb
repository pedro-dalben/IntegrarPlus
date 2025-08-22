# frozen_string_literal: true

module Ui
  class TableActionsComponent < ViewComponent::Base
    renders_many :actions

    def initialize(model:, resource_name:)
      @model = model
      @resource_name = resource_name
    end

    private

    attr_reader :model, :resource_name

    def show_path
      "admin_#{resource_name}_path"
    end

    def edit_path
      "edit_admin_#{resource_name}_path"
    end

    def delete_path
      "admin_#{resource_name}_path"
    end
  end
end
