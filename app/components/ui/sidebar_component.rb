# frozen_string_literal: true

module Ui
  class SidebarComponent < ViewComponent::Base
    include Admin::SidebarHelper

    def initialize(current_path: nil, current_user: nil, **options)
      super()
      @current_path = current_path
      @current_user = current_user
      @options = options
    end

    private

    attr_reader :current_path, :current_user, :options

    def menu_items
      [
        {
          title: t('admin.breadcrumb.dashboard'),
          path: '/admin',
          icon: dashboard_icon,
          active: current_path&.start_with?('/admin') && !current_path&.include?('/admin/'),
          badge: nil,
          permission: 'dashboard.view',
          type: 'single'
        }
      ] + dropdown_menus
    end

    def dropdown_menus
      menus = []

      # Módulo: Cadastro de Profissionais
      if user_can_access_any?(['professionals.index', 'groups.manage', 'specialities.index', 'specializations.index',
                               'contract_types.index'])
        menus << {
          title: 'Cadastro de Profissionais',
          icon: professionals_icon,
          active: any_active?(['/admin/professionals', '/admin/groups', '/admin/specialities',
                               '/admin/specializations', '/admin/contract_types']),
          type: 'dropdown',
          items: [
            {
              title: 'Profissionais',
              path: '/admin/professionals',
              icon: professionals_icon,
              active: current_path&.start_with?('/admin/professionals'),
              permission: 'professionals.index'
            },
            {
              title: 'Grupos',
              path: '/admin/groups',
              icon: groups_icon,
              active: current_path&.start_with?('/admin/groups'),
              permission: 'groups.manage'
            },
            {
              title: 'Especialidades',
              path: '/admin/specialities',
              icon: specialities_icon,
              active: current_path&.start_with?('/admin/specialities'),
              permission: 'specialities.index'
            },
            {
              title: 'Especializações',
              path: '/admin/specializations',
              icon: specializations_icon,
              active: current_path&.start_with?('/admin/specializations'),
              permission: 'specializations.index'
            },
            {
              title: 'Tipos de Contrato',
              path: '/admin/contract_types',
              icon: contract_types_icon,
              active: current_path&.start_with?('/admin/contract_types'),
              permission: 'contract_types.index'
            }
          ]
        }
      end

      # Módulo: Portal de Operadoras
      if user_can_access_any?(['portal_intakes.index', 'external_users.index'])
        menus << {
          title: 'Portal de Operadoras',
          icon: portal_intakes_icon,
          active: any_active?(['/admin/portal_intakes', '/admin/external_users']),
          type: 'dropdown',
          items: [
            {
              title: 'Entradas do Portal',
              path: '/admin/portal_intakes',
              icon: portal_intakes_icon,
              active: current_path&.start_with?('/admin/portal_intakes'),
              permission: 'portal_intakes.index'
            },
            {
              title: 'Operadoras',
              path: '/admin/external_users',
              icon: groups_icon,
              active: current_path&.start_with?('/admin/external_users'),
              permission: 'external_users.index'
            }
          ]
        }
      end

      # Módulo: Documentos
      if user_can_access_any?(['documents.access', 'documents.view_released', 'documents.manage_permissions'])
        menus << {
          title: 'Documentos',
          icon: documents_icon,
          active: any_active?(['/admin/workspace', '/admin/released_documents', '/admin/professional_permissions']),
          type: 'dropdown',
          items: [
            {
              title: 'Workspace',
              path: '/admin/workspace',
              icon: documents_icon,
              active: current_path&.start_with?('/admin/workspace'),
              permission: 'documents.access'
            },
            {
              title: 'Documentos Liberados',
              path: '/admin/released_documents',
              icon: released_documents_icon,
              active: current_path&.start_with?('/admin/released_documents'),
              permission: 'documents.view_released'
            },
            {
              title: 'Gerenciar Permissões',
              path: '/admin/professional_permissions',
              icon: permissions_icon,
              active: current_path&.start_with?('/admin/professional_permissions'),
              permission: 'documents.manage_permissions'
            }
          ]
        }
      end

      # Módulo: Fluxogramas
      if user_can_access_any?(['flow_charts.index', 'flow_charts.manage'])
        menus << {
          title: 'Fluxogramas',
          icon: documents_icon,
          active: any_active?(['/admin/flow_charts', '/admin/fluxogramas']),
          type: 'dropdown',
          items: [
            {
              title: 'Gerenciar Fluxogramas',
              path: '/admin/flow_charts',
              icon: documents_icon,
              active: current_path&.start_with?('/admin/flow_charts') && !current_path&.start_with?('/admin/fluxogramas'),
              permission: 'flow_charts.index'
            },
            {
              title: 'Fluxogramas Publicados',
              path: '/admin/fluxogramas',
              icon: documents_icon,
              active: current_path&.start_with?('/admin/fluxogramas'),
              permission: 'flow_charts.index'
            }
          ]
        }
      end

      # Módulo: Agendamentos
      if user_can_access?('agendas.read')
        menus << {
          title: 'Agendamentos',
          path: '/admin/agendas',
          icon: agendas_icon,
          active: current_path&.start_with?('/admin/agendas'),
          badge: nil,
          permission: 'agendas.read',
          type: 'single'
        }
      end

      # Módulo: Beneficiários
      if user_can_access_any?(['beneficiaries.index', 'anamneses.index'])
        menus << {
          title: 'Beneficiários',
          icon: beneficiaries_icon,
          active: any_active?(['/admin/beneficiaries', '/admin/anamneses']),
          type: 'dropdown',
          items: [
            {
              title: 'Listar Beneficiários',
              path: '/admin/beneficiaries',
              icon: beneficiaries_icon,
              active: current_path&.start_with?('/admin/beneficiaries'),
              permission: 'beneficiaries.index'
            },
            {
              title: 'Anamneses',
              path: '/admin/anamneses',
              icon: anamneses_icon,
              active: current_path&.start_with?('/admin/anamneses'),
              permission: 'anamneses.index'
            },
            {
              title: 'Anamneses de Hoje',
              path: '/admin/anamneses/today',
              icon: today_icon,
              active: current_path == '/admin/anamneses/today',
              permission: 'anamneses.index'
            }
          ]
        }
      end

      menus
    end

    def user_can_access_any?(permissions)
      permissions.any? { |permission| user_can_access?(permission) }
    end

    def any_active?(paths)
      paths.any? { |path| current_path&.start_with?(path) }
    end

    def support_items
      [
        {
          title: 'Configurações',
          path: '#',
          icon: settings_icon,
          active: false,
          badge: nil
        },
        {
          title: 'Integrações',
          path: '#',
          icon: integrations_icon,
          active: false,
          badge: 'New'
        }
      ]
    end

    def dashboard_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9,22 9,12 15,12 15,22"/></svg>'.html_safe
    end

    def professionals_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>'.html_safe
    end

    def groups_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M21 8.12a5 5 0 0 0-2.8-4.5"/><path d="M21 8.12a5 5 0 0 0-2.8 4.5"/><path d="M21 8.12a5 5 0 0 0-2.8-4.5"/><path d="M21 8.12a5 5 0 0 0-2.8 4.5"/></svg>'.html_safe
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

    def documents_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14,2 14,8 20,8"/><line x1="16" x2="8" y1="13" y2="13"/><line x1="16" x2="8" y1="17" y2="17"/><polyline points="10,9 9,9 8,9"/></svg>'.html_safe
    end

    def released_documents_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12l2 2 4-4"/><path d="M21 12c-1 0-2-1-2-2s1-2 2-2 2 1 2 2-1 2-2 2z"/><path d="M3 12c1 0 2-1 2-2s-1-2-2-2-2 1-2 2 1 2 2 2z"/><path d="M12 3c0 1-1 2-2 2s-2-1-2-2 1-2 2-2 2 1 2 2z"/><path d="M12 21c0-1 1-2 2-2s2 1 2 2-1 2-2 2-2-1-2-2z"/></svg>'.html_safe
    end

    def permissions_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/><circle cx="12" cy="12" r="3"/></svg>'.html_safe
    end

    def settings_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/><circle cx="12" cy="12" r="3"/></svg>'.html_safe
    end

    def integrations_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><circle cx="12" cy="5" r="2"/><path d="M12 7v4"/></svg>'.html_safe
    end

    def portal_intakes_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14,2 14,8 20,8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10,9 9,9 8,9"/></svg>'.html_safe
    end

    def agendas_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>'.html_safe
    end

    def beneficiaries_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>'.html_safe
    end

    def anamneses_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14,2 14,8 20,8"/><line x1="16" x2="8" y1="13" y2="13"/><line x1="16" x2="8" y1="17" y2="17"/><polyline points="10,9 9,9 8,9"/></svg>'.html_safe
    end

    def today_icon
      '<svg class="shrink-0 size-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12,6 12,12 16,14"/></svg>'.html_safe
    end

    def user_can_access?(permission_key)
      return false if current_user.blank?
      return true if current_user.admin?

      current_user.permit?(permission_key)
    end
  end
end
