# frozen_string_literal: true

module Ui
  class DataTableComponent < ViewComponent::Base
    renders_many :headers
    renders_many :rows
    renders_one :empty_state

    def initialize(collection:, searchable: false, paginated: false)
      @collection = collection
      @searchable = searchable
      @paginated = paginated
    end

    private

    attr_reader :collection, :searchable, :paginated

    def has_data?
      collection&.any?
    end

    def table_classes
      'w-full'
    end

    def thead_classes
      'border-b border-gray-200 bg-gray-50 dark:border-gray-800 dark:bg-gray-900'
    end

    def tbody_classes
      'divide-y divide-gray-200 bg-white dark:divide-gray-800 dark:bg-white/[0.03]'
    end

    def th_classes
      'px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500 dark:text-gray-400'
    end

    def tr_classes
      'hover:bg-gray-50 dark:hover:bg-gray-900'
    end

    def td_classes
      'whitespace-nowrap px-6 py-4'
    end
  end
end
