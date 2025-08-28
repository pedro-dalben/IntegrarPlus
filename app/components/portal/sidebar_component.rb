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
          title: "Solicitações",
          path: portal_service_requests_path,
          icon: "document-text",
          active: current_path.start_with?("/portal/service_requests")
        },
        {
          title: "Nova Solicitação",
          path: new_portal_service_request_path,
          icon: "plus",
          active: current_path == new_portal_service_request_path
        }
      ]
    end

    def svg_icon(name)
      case name
      when "document-text"
        content_tag(:svg, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", class: "w-5 h-5") do
          tag(:path, "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z")
        end
      when "plus"
        content_tag(:svg, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", class: "w-5 h-5") do
          tag(:path, "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M12 4v16m8-8H4")
        end
      else
        content_tag(:div, "", class: "w-5 h-5")
      end
    end
  end
end
