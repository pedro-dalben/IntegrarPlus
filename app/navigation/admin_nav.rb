# frozen_string_literal: true

module AdminNav
  module_function

  def items
    [
      { label: 'Dashboard', path: '/admin', icon: 'bi-speedometer2', required_permission: 'dashboard.view' },
      { label: 'Workspace', path: '/admin/workspace', icon: 'bi-folder2-open', required_permission: 'documents.read' },
      { label: 'Documentos Liberados', path: '/admin/released_documents', icon: 'bi-check-circle',
        required_permission: 'documents.read' },
      { label: 'Portal Operadoras', path: '/admin/portal_intakes', icon: 'bi-hospital', required_permission: 'portal_intakes.index' },
      { label: 'Cadastros', icon: 'bi-people', required_permission: 'professionals.read', children: [
        { label: 'Profissionais', path: '/admin/professionals', icon: 'bi-person',
          required_permission: 'professionals.read' },
        { label: 'Grupos', path: '/admin/groups', icon: 'bi-collection', required_permission: 'groups.manage' }
      ] },

      { label: 'Configurações', icon: 'bi-gear', required_permission: 'settings.read', children: [
        { label: 'Formas de Contratação', path: '/admin/contract_types', icon: 'bi-briefcase',
          required_permission: 'settings.read' },
        { label: 'Especialidades', path: '/admin/specialities', icon: 'bi-clipboard2-pulse',
          required_permission: 'settings.read' },
        { label: 'Especializações', path: '/admin/specializations', icon: 'bi-award',
          required_permission: 'settings.read' }
      ] },
      { label: 'Catálogo de UI', path: '/admin/ui', icon: 'bi-layers', required_permission: 'settings.read' }
    ]
  end
end
