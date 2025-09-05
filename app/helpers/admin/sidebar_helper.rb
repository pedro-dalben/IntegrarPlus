module Admin::SidebarHelper
  def menu_items
    items = []

    if current_user.permit?('dashboard.view')
      items << {
        name: 'Dashboard',
        path: admin_root_path,
        icon: 'fas fa-tachometer-alt',
        active: current_page?(admin_root_path)
      }
    end

    if current_user.permit?('professionals.read')
      items << {
        name: 'Profissionais',
        path: admin_professionals_path,
        icon: 'fas fa-users',
        active: current_page?(admin_professionals_path)
      }
    end

    if current_user.permit?('groups.read')
      items << {
        name: 'Grupos',
        path: admin_groups_path,
        icon: 'fas fa-layer-group',
        active: current_page?(admin_groups_path)
      }
    end

    if current_user.permit?('specialties.read')
      items << {
        name: 'Especialidades',
        path: admin_specialties_path,
        icon: 'fas fa-stethoscope',
        active: current_page?(admin_specialties_path)
      }
    end

    if current_user.permit?('specializations.read')
      items << {
        name: 'Especializações',
        path: admin_specializations_path,
        icon: 'fas fa-graduation-cap',
        active: current_page?(admin_specializations_path)
      }
    end

    if current_user.permit?('contract_types.read')
      items << {
        name: 'Tipos de Contrato',
        path: admin_contract_types_path,
        icon: 'fas fa-file-contract',
        active: current_page?(admin_contract_types_path)
      }
    end

    if current_user.permit?('documents.read')
      items << {
        name: 'Documentos',
        path: admin_documents_path,
        icon: 'fas fa-file-alt',
        active: current_page?(admin_documents_path)
      }
    end

    if current_user.permit?('document_releases.read')
      items << {
        name: 'Documentos Liberados',
        path: admin_document_releases_path,
        icon: 'fas fa-file-export',
        active: current_page?(admin_document_releases_path)
      }
    end

    if current_user.permit?('portal_intakes.read')
      items << {
        name: 'Portal Intakes',
        path: admin_portal_intakes_path,
        icon: 'fas fa-door-open',
        active: current_page?(admin_portal_intakes_path)
      }
    end

    if current_user.permit?('agendas.read')
      items << {
        name: 'Agendas',
        path: admin_agendas_path,
        icon: 'fas fa-calendar-alt',
        active: current_page?(admin_agendas_path)
      }
    end

    if current_user.permit?('medical_appointments.read')
      items << {
        name: 'Consultas Médicas',
        path: admin_medical_appointments_path,
        icon: 'fas fa-user-md',
        active: current_page?(admin_medical_appointments_path)
      }
    end

    if current_user.permit?('permissions.read')
      items << {
        name: 'Gerenciar Permissões',
        path: admin_permissions_path,
        icon: 'fas fa-shield-alt',
        active: current_page?(admin_permissions_path)
      }
    end

    items
  end
end
