# frozen_string_literal: true

module Admin
  module SidebarHelper
    def menu_items
      items = []

      if current_user.permit?('dashboard.view')
        items << {
          name: 'Dashboard',
          path: admin_root_path,
          icon: '<i class="fas fa-tachometer-alt"></i>',
          active: current_page?(admin_root_path)
        }
      end

      if current_user.permit?('professionals.read')
        items << {
          name: 'Profissionais',
          path: admin_professionals_path,
          icon: '<i class="fas fa-users"></i>',
          active: current_page?(admin_professionals_path)
        }
      end

      if current_user.permit?('groups.read')
        items << {
          name: 'Grupos',
          path: admin_groups_path,
          icon: '<i class="fas fa-layer-group"></i>',
          active: current_page?(admin_groups_path)
        }
      end

      if current_user.permit?('specialties.read')
        items << {
          name: 'Especialidades',
          path: admin_specialties_path,
          icon: '<i class="fas fa-stethoscope"></i>',
          active: current_page?(admin_specialties_path)
        }
      end

      if current_user.permit?('specializations.read')
        items << {
          name: 'Especializações',
          path: admin_specializations_path,
          icon: '<i class="fas fa-graduation-cap"></i>',
          active: current_page?(admin_specializations_path)
        }
      end

      if current_user.permit?('contract_types.read')
        items << {
          name: 'Tipos de Contrato',
          path: admin_contract_types_path,
          icon: '<i class="fas fa-file-contract"></i>',
          active: current_page?(admin_contract_types_path)
        }
      end

      if current_user.permit?('documents.read')
        items << {
          name: 'Documentos',
          path: admin_documents_path,
          icon: '<i class="fas fa-file-alt"></i>',
          active: current_page?(admin_documents_path)
        }
      end

      if current_user.permit?('document_releases.read')
        items << {
          name: 'Documentos Liberados',
          path: admin_document_releases_path,
          icon: '<i class="fas fa-file-export"></i>',
          active: current_page?(admin_document_releases_path)
        }
      end

      if current_user.permit?('portal_intakes.read')
        items << {
          name: 'Portal Intakes',
          path: admin_portal_intakes_path,
          icon: '<i class="fas fa-door-open"></i>',
          active: current_page?(admin_portal_intakes_path)
        }
      end

      if current_user.permit?('agendas.read')
        items << {
          name: 'Agendas',
          path: admin_agendas_path,
          icon: '<i class="fas fa-calendar-alt"></i>',
          active: current_page?(admin_agendas_path)
        }
      end

      if current_user.permit?('medical_appointments.read')
        items << {
          name: 'Consultas Médicas',
          path: admin_medical_appointments_path,
          icon: '<i class="fas fa-user-md"></i>',
          active: current_page?(admin_medical_appointments_path)
        }
      end

      if current_user.permit?('permissions.read')
        items << {
          name: 'Gerenciar Permissões',
          path: admin_permissions_path,
          icon: '<i class="fas fa-shield-alt"></i>',
          active: current_page?(admin_permissions_path)
        }
      end

      items
    end
  end
end
