# frozen_string_literal: true

module Ui
  class DataTableComponent < ViewComponent::Base
    renders_one :actions
    renders_one :search
    renders_one :filters

    def initialize(searchable: true, filterable: true, selectable: true, paginated: true)
      @searchable = searchable
      @filterable = filterable
      @selectable = selectable
      @paginated = paginated
    end

    private

    attr_reader :searchable, :filterable, :selectable, :paginated
  end
end
