# frozen_string_literal: true

class Ui::SidebarComponent < ViewComponent::Base
  def initialize(current_path: nil, **options)
    @current_path = current_path
    @options = options
  end

  private

  attr_reader :current_path, :options

  def menu_items
    [
      {
        title: "Dashboard",
        path: "/admin/dashboard",
        icon: dashboard_icon,
        active: current_path&.start_with?("/admin/dashboard")
      },
      {
        title: "Profissionais",
        path: "/admin/professionals", 
        icon: professionals_icon,
        active: current_path&.start_with?("/admin/professionals")
      },
      {
        title: "Especialidades",
        path: "/admin/specialities",
        icon: specialities_icon,
        active: current_path&.start_with?("/admin/specialities")
      },
      {
        title: "Especializações",
        path: "/admin/specializations",
        icon: specializations_icon,
        active: current_path&.start_with?("/admin/specializations")
      },
      {
        title: "Tipos de Contrato",
        path: "/admin/contract_types",
        icon: contract_types_icon,
        active: current_path&.start_with?("/admin/contract_types")
      }
    ]
  end

  def dashboard_icon
    '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9,22 9,12 15,12 15,22"/></svg>'.html_safe
  end

  def professionals_icon
    '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>'.html_safe
  end

  def specialities_icon
    '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>'.html_safe
  end

  def specializations_icon
    '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14,2 14,8 20,8"/><line x1="16" x2="8" y1="13" y2="13"/><line x1="16" x2="8" y1="17" y2="17"/><polyline points="10,9 9,9 8,9"/></svg>'.html_safe
  end

  def contract_types_icon
    '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14,2 14,8 20,8"/><line x1="16" x2="8" y1="13" y2="13"/><line x1="16" x2="8" y1="17" y2="17"/><polyline points="10,9 9,9 8,9"/></svg>'.html_safe
  end
end