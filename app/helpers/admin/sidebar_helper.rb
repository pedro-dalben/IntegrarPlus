module Admin
  module SidebarHelper
    def sidebar_menu_item_active?(path)
      current_page?(path) || request.path.start_with?(path)
    end

    def sidebar_group_active?(group_paths)
      group_paths.any? { |path| request.path.start_with?(path) }
    end

    def sidebar_menu_item_classes(path, base_classes = 'menu-item group')
      active_classes = sidebar_menu_item_active?(path) ? ' menu-item-active' : ''
      "#{base_classes}#{active_classes}"
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
