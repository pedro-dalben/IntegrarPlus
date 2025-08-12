# frozen_string_literal: true

module Ui
  class ProTableComponent < ViewComponent::Base
    def initialize(columns:, rows:, actions: nil)
      @columns = columns
      @rows = rows
      @actions = actions
    end

    def call
      content_tag :div, class: 'overflow-x-auto' do
        content_tag :table, class: 'min-w-full text-sm' do
          safe_join([
                      thead,
                      tbody
                    ])
        end
      end
    end

    private

    def thead
      content_tag :thead do
        content_tag :tr, class: 'text-left text-gray-500 border-b', style: 'border-color: rgb(var(--t-fg) / 0.06)' do
          safe_join(@columns.map do |c|
            content_tag(:th, c[:label],
                        class: 'py-2 pr-4')
          end + [(@actions ? content_tag(:th, '', class: 'py-2 pr-4 text-right') : nil)].compact)
        end
      end
    end

    def tbody
      content_tag :tbody do
        safe_join(@rows.map { |row| tr(row) })
      end
    end

    def tr(row)
      content_tag :tr, class: 'border-b last:border-b-0', style: 'border-color: rgb(var(--t-fg) / 0.06)' do
        tds = @columns.map { |c| content_tag(:td, row[c[:key]], class: 'py-2 pr-4') }
        tds << content_tag(:td, @actions ? @actions.call(row) : '', class: 'py-2 pr-4 text-right') if @actions
        safe_join(tds)
      end
    end
  end
end
