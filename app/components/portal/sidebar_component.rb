# frozen_string_literal: true

module Portal
  class SidebarComponent < ViewComponent::Base
    def initialize(current_path:, current_external_user:)
      @current_path = current_path
      @current_external_user = current_external_user
    end

    private

    attr_reader :current_path, :current_external_user

    def menu_items
      [
        {
          title: 'Entradas Portal',
          path: portal_portal_intakes_path,
          icon: 'hospital',
          active: current_path.start_with?('/portal/portal_intakes')
        },
        {
          title: 'Nova Entrada',
          path: new_portal_portal_intake_path,
          icon: 'user-plus',
          active: current_path == new_portal_portal_intake_path
        }
      ]
    end

    def svg_icon(name)
      case name
      when 'document-text'
        content_tag(:svg, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', class: 'w-5 h-5') do
          tag.path('stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2',
                   d: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z')
        end
      when 'plus'
        content_tag(:svg, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', class: 'w-5 h-5') do
          tag.path('stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M12 4v16m8-8H4')
        end
      when 'hospital'
        content_tag(:svg, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', class: 'w-5 h-5') do
          tag.path('stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2',
                   d: 'M19 14l-7 7m0 0l-7-7m7 7V3m9 12V9a2 2 0 00-2-2H4a2 2 0 00-2 2v6')
        end
      when 'user-plus'
        content_tag(:svg, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', class: 'w-5 h-5') do
          tag.path('stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2',
                   d: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7zM20 8v6M23 11h-6')
        end
      else
        content_tag(:div, '', class: 'w-5 h-5')
      end
    end
  end
end
