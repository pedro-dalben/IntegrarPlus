# frozen_string_literal: true

module Admin
  module SidebarHelper
    def sidebar_menu_item_active?(path)
      # Para o dashboard (/admin), verificar exatamente a rota
      if path == '/admin'
        current_page?(path) || request.path == '/admin'
      else
        # Para outras rotas, usar start_with normalmente
        current_page?(path) || request.path.start_with?(path)
      end
    end

    def sidebar_group_active?(group_paths)
      group_paths.any? { |path| request.path.start_with?(path) }
    end

    def sidebar_menu_item_classes(path, base_classes = 'menu-item group', active_class = 'menu-item-active',
                                  inactive_class = 'menu-item-inactive')
      if base_classes.empty?
        # Para ícones
        sidebar_menu_item_active?(path) ? active_class : inactive_class
      else
        # Para links
        active_classes = sidebar_menu_item_active?(path) ? " #{active_class}" : " #{inactive_class}"
        "#{base_classes}#{active_classes}"
      end
    end

    def sidebar_group_classes(group_paths, base_classes = 'menu-item group')
      active_classes = sidebar_group_active?(group_paths) ? ' menu-item-active' : ''
      "#{base_classes}#{active_classes}"
    end

    def sidebar_dropdown_classes(group_paths, base_classes = 'translate transform overflow-hidden')
      active_classes = sidebar_group_active?(group_paths) ? '' : ' hidden'
      "#{base_classes}#{active_classes}"
    end

    def sidebar_group_expanded?(group_paths)
      sidebar_group_active?(group_paths) ? 'true' : 'false'
    end
  end
end
