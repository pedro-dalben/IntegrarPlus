# frozen_string_literal: true

module Layouts
  class SidebarComponent < ViewComponent::Base
    include ApplicationHelper

    def initialize(current_professional: nil, collapsed: false)
      super()
      @current_professional = current_professional
      @collapsed = collapsed
    end

    def call
      # Desktop sidebar
      content_tag(:aside, class: sidebar_classes) do
        content_tag(:div, class: 'flex items-center gap-2 pt-8 pb-7 sidebar-header') do
          link_to('/admin', class: 'flex items-center') do
            content_tag(:span, 'IntegrarPlus', class: 'text-xl font-semibold')
          end
        end +
        content_tag(:div, class: 'flex flex-col overflow-y-auto duration-300 ease-linear no-scrollbar') do
          content_tag(:nav, data: { controller: 'sidebar-nav' }) do
            render_menu_groups
          end
        end
      end +
      # Mobile sidebar
      mobile_sidebar_html
    end

    private

    def sidebar_classes
      base_classes = 'sidebar fixed left-0 top-0 z-50 flex h-screen w-[290px] flex-col overflow-y-hidden border-r bg-white px-5 lg:static lg:translate-x-0'
      base_classes += @collapsed ? ' collapsed' : ''
      base_classes
    end

        def mobile_sidebar_html
      content_tag(:div, class: 'lg:hidden') do
        # Overlay
        content_tag(:div, '',
                    class: 'fixed inset-0 z-40 bg-black/50 hidden',
                    data: {
                      sidebar_target: 'overlay',
                      action: 'click->sidebar#close'
                    }) +
        # Mobile panel
        content_tag(:aside, 
                    class: 'fixed inset-y-0 left-0 z-50 w-[290px] transform -translate-x-full transition-transform duration-300 ease-in-out bg-white border-r px-5 shadow-xl',
                    data: { sidebar_target: 'panel' },
                    style: 'border-color: rgb(var(--t-fg) / 0.06)') do
          content_tag(:div, class: 'flex items-center justify-between pt-8 pb-7') do
            link_to('/admin', class: 'flex items-center') do
              content_tag(:span, 'IntegrarPlus', class: 'text-xl font-semibold')
            end +
            content_tag(:button, 
                        class: 'inline-flex items-center justify-center size-8 rounded-lg hover:bg-gray-100 dark:hover:bg-white/5',
                        data: { action: 'click->sidebar#close' }) do
              content_tag(:svg,
                          content_tag(:path, '', 
                                     d: 'M6 18L18 6M6 6l12 12',
                                     stroke: 'currentColor',
                                     'stroke-width': '2',
                                     'stroke-linecap': 'round',
                                     'stroke-linejoin': 'round'),
                          class: 'size-5',
                          fill: 'none',
                          viewBox: '0 0 24 24')
            end
          end +
          content_tag(:div, class: 'flex flex-col overflow-y-auto duration-300 ease-linear no-scrollbar h-full pb-8') do
            content_tag(:nav) do
              render_menu_groups
            end
          end
        end
      end
    end

    def render_menu_groups
      safe_join([
        render_menu_group('MENU', main_menu_items),
        render_menu_group('OTHERS', other_menu_items)
      ])
    end

    def render_menu_group(title, items)
      content_tag(:div, class: 'mb-6') do
        content_tag(:h3, title, class: 'mb-4 text-xs uppercase leading-[20px] text-gray-400') +
        content_tag(:ul, class: 'flex flex-col gap-4') do
          safe_join(items.map { |item| render_menu_item(item) })
        end
      end
    end

    def main_menu_items
      [
        {
          label: 'Dashboard',
          path: '/admin',
          icon: dashboard_icon,
          active: current_path == '/admin' || current_path.start_with?('/admin/dashboard')
        },
        {
          label: 'Cadastros', 
          path: '#',
          icon: forms_icon,
          children: [
            { label: 'Usuários', path: '/admin/users' },
            { label: 'Empresas', path: '/admin/companies' }
          ]
        },
        {
          label: 'Configurações',
          path: '#',
          icon: settings_icon,
          children: [
            { label: 'Sistema', path: '/admin/settings/system' },
            { label: 'Integrações', path: '/admin/settings/integrations' }
          ]
        }
      ]
    end

    def other_menu_items
      [
        {
          label: 'Catálogo de UI',
          path: '/admin/ui',
          icon: ui_elements_icon,
          active: current_path.start_with?('/admin/ui')
        }
      ]
    end

    def render_menu_item(item)
      content_tag(:li) do
        if item[:children].present?
          render_menu_item_with_dropdown(item)
        else
          render_simple_menu_item(item)
        end
      end
    end

    def render_simple_menu_item(item)
      active = item[:active] || current_path.start_with?(item[:path])
      
      link_to(item[:path], class: menu_item_classes(active)) do
        safe_join([
          item[:icon],
          content_tag(:span, item[:label], class: 'menu-item-text')
        ])
      end
    end

    def render_menu_item_with_dropdown(item)
      expanded = item[:children]&.any? { |child| current_path.start_with?(child[:path]) }
      active = expanded || (item[:active] || false)
      
      button = content_tag(:button, 
                          class: menu_item_classes(active),
                          data: { 
                            controller: 'accordion', 
                            action: 'click->accordion#toggle' 
                          },
                          aria: { expanded: expanded.to_s }) do
        safe_join([
          item[:icon],
          content_tag(:span, item[:label], class: 'menu-item-text flex-1'),
          dropdown_arrow(active)
        ])
      end

      dropdown = content_tag(:div, 
                            class: "overflow-hidden transform translate #{expanded ? 'block' : 'hidden'}",
                            data: { accordion_target: 'panel' }) do
        content_tag(:ul, class: 'flex flex-col gap-1 mt-2 menu-dropdown pl-9') do
          safe_join(item[:children].map { |child| render_dropdown_item(child) })
        end
      end

      safe_join([button, dropdown])
    end

    def render_dropdown_item(item)
      active = current_path.start_with?(item[:path])
      
      content_tag(:li) do
        link_to(item[:path], class: dropdown_item_classes(active)) do
          item[:label]
        end
      end
    end

    def menu_item_classes(active)
      base = 'menu-item group'
      base += active ? ' menu-item-active' : ' menu-item-inactive'
      base
    end

    def dropdown_item_classes(active)
      base = 'menu-dropdown-item group'
      base += active ? ' menu-dropdown-item-active' : ' menu-dropdown-item-inactive'
      base
    end

    def dropdown_arrow(active)
      content_tag(:svg, 
                  content_tag(:path, '', 
                             d: 'M4.79175 7.39584L10.0001 12.6042L15.2084 7.39585',
                             stroke: 'currentColor',
                             'stroke-width': '1.5',
                             'stroke-linecap': 'round',
                             'stroke-linejoin': 'round'),
                  class: "menu-item-arrow #{active ? 'menu-item-arrow-active' : 'menu-item-arrow-inactive'}",
                  width: '20',
                  height: '20',
                  viewBox: '0 0 20 20',
                  fill: 'none',
                  xmlns: 'http://www.w3.org/2000/svg')
    end

    def current_path
      helpers.request.fullpath
    end

    # SVG Icons
    def dashboard_icon
      content_tag(:svg, 
                  content_tag(:path, '', 
                             'fill-rule': 'evenodd',
                             'clip-rule': 'evenodd',
                             d: 'M5.5 3.25C4.25736 3.25 3.25 4.25736 3.25 5.5V8.99998C3.25 10.2426 4.25736 11.25 5.5 11.25H9C10.2426 11.25 11.25 10.2426 11.25 8.99998V5.5C11.25 4.25736 10.2426 3.25 9 3.25H5.5ZM4.75 5.5C4.75 5.08579 5.08579 4.75 5.5 4.75H9C9.41421 4.75 9.75 5.08579 9.75 5.5V8.99998C9.75 9.41419 9.41421 9.74998 9 9.74998H5.5C5.08579 9.74998 4.75 9.41419 4.75 8.99998V5.5ZM5.5 12.75C4.25736 12.75 3.25 13.7574 3.25 15V18.5C3.25 19.7426 4.25736 20.75 5.5 20.75H9C10.2426 20.75 11.25 19.7427 11.25 18.5V15C11.25 13.7574 10.2426 12.75 9 12.75H5.5ZM4.75 15C4.75 14.5858 5.08579 14.25 5.5 14.25H9C9.41421 14.25 9.75 14.5858 9.75 15V18.5C9.75 18.9142 9.41421 19.25 9 19.25H5.5C5.08579 19.25 4.75 18.9142 4.75 18.5V15ZM12.75 5.5C12.75 4.25736 13.7574 3.25 15 3.25H18.5C19.7426 3.25 20.75 4.25736 20.75 5.5V8.99998C20.75 10.2426 19.7426 11.25 18.5 11.25H15C13.7574 11.25 12.75 10.2426 12.75 8.99998V5.5ZM15 4.75C14.5858 4.75 14.25 5.08579 14.25 5.5V8.99998C14.25 9.41419 14.5858 9.74998 15 9.74998H18.5C18.9142 9.74998 19.25 9.41419 19.25 8.99998V5.5C19.25 5.08579 18.9142 4.75 18.5 4.75H15ZM15 12.75C13.7574 12.75 12.75 13.7574 12.75 15V18.5C12.75 19.7426 13.7574 20.75 15 20.75H18.5C19.7426 20.75 20.75 19.7427 20.75 18.5V15C20.75 13.7574 19.7426 12.75 18.5 12.75H15ZM14.25 15C14.25 14.5858 14.5858 14.25 15 14.25H18.5C18.9142 14.25 19.25 14.5858 19.25 15V18.5C19.25 18.9142 18.9142 19.25 18.5 19.25H15C14.5858 19.25 14.25 18.9142 14.25 18.5V15Z',
                             fill: 'currentColor'),
                  class: 'menu-item-icon w-6 h-6 fill-current',
                  width: '24',
                  height: '24',
                  viewBox: '0 0 24 24',
                  fill: 'none',
                  xmlns: 'http://www.w3.org/2000/svg')
    end

    def forms_icon
      content_tag(:svg,
                  content_tag(:path, '',
                             'fill-rule': 'evenodd',
                             'clip-rule': 'evenodd',
                             d: 'M5.5 3.25C4.25736 3.25 3.25 4.25736 3.25 5.5V18.5C3.25 19.7426 4.25736 20.75 5.5 20.75H18.5001C19.7427 20.75 20.7501 19.7426 20.7501 18.5V5.5C20.7501 4.25736 19.7427 3.25 18.5001 3.25H5.5ZM4.75 5.5C4.75 5.08579 5.08579 4.75 5.5 4.75H18.5001C18.9143 4.75 19.2501 5.08579 19.2501 5.5V18.5C19.2501 18.9142 18.9143 19.25 18.5001 19.25H5.5C5.08579 19.25 4.75 18.9142 4.75 18.5V5.5ZM6.25005 9.7143C6.25005 9.30008 6.58583 8.9643 7.00005 8.9643L17 8.96429C17.4143 8.96429 17.75 9.30008 17.75 9.71429C17.75 10.1285 17.4143 10.4643 17 10.4643L7.00005 10.4643C6.58583 10.4643 6.25005 10.1285 6.25005 9.7143ZM6.25005 14.2857C6.25005 13.8715 6.58583 13.5357 7.00005 13.5357H17C17.4143 13.5357 17.75 13.8715 17.75 14.2857C17.75 14.6999 17.4143 15.0357 17 15.0357H7.00005C6.58583 15.0357 6.25005 14.6999 6.25005 14.2857Z',
                             fill: 'currentColor'),
                  class: 'menu-item-icon w-6 h-6 fill-current',
                  width: '24',
                  height: '24',
                  viewBox: '0 0 24 24',
                  fill: 'none',
                  xmlns: 'http://www.w3.org/2000/svg')
    end

    def settings_icon
      content_tag(:svg,
                  content_tag(:path, '',
                             'fill-rule': 'evenodd',
                             'clip-rule': 'evenodd',
                             d: 'M14 2.75C14 2.33579 14.3358 2 14.75 2C15.1642 2 15.5 2.33579 15.5 2.75V5.73291L17.75 5.73291H19C19.4142 5.73291 19.75 6.0687 19.75 6.48291C19.75 6.89712 19.4142 7.23291 19 7.23291H18.5L18.5 12.2329C18.5 15.5691 15.9866 18.3183 12.75 18.6901V21.25C12.75 21.6642 12.4142 22 12 22C11.5858 22 11.25 21.6642 11.25 21.25V18.6901C8.01342 18.3183 5.5 15.5691 5.5 12.2329L5.5 7.23291H5C4.58579 7.23291 4.25 6.89712 4.25 6.48291C4.25 6.0687 4.58579 5.73291 5 5.73291L6.25 5.73291L8.5 5.73291L8.5 2.75C8.5 2.33579 8.83579 2 9.25 2C9.66421 2 10 2.33579 10 2.75L10 5.73291L14 5.73291V2.75ZM7 7.23291L7 12.2329C7 14.9943 9.23858 17.2329 12 17.2329C14.7614 17.2329 17 14.9943 17 12.2329L17 7.23291L7 7.23291Z',
                             fill: 'currentColor'),
                  class: 'menu-item-icon w-6 h-6 fill-current',
                  width: '24',
                  height: '24',
                  viewBox: '0 0 24 24',
                  fill: 'none',
                  xmlns: 'http://www.w3.org/2000/svg')
    end

    def ui_elements_icon
      content_tag(:svg,
                  content_tag(:path, '',
                             'fill-rule': 'evenodd',
                             'clip-rule': 'evenodd',
                             d: 'M11.665 3.75618C11.8762 3.65061 12.1247 3.65061 12.3358 3.75618L18.7807 6.97853L12.3358 10.2009C12.1247 10.3064 11.8762 10.3064 11.665 10.2009L5.22014 6.97853L11.665 3.75618ZM4.29297 8.19199V16.0946C4.29297 16.3787 4.45347 16.6384 4.70757 16.7654L11.25 20.0365V11.6512C11.1631 11.6205 11.0777 11.5843 10.9942 11.5425L4.29297 8.19199ZM12.75 20.037L19.2933 16.7654C19.5474 16.6384 19.7079 16.3787 19.7079 16.0946V8.19199L13.0066 11.5425C12.9229 11.5844 12.8372 11.6207 12.75 11.6515V20.037ZM13.0066 2.41453C12.3732 2.09783 11.6277 2.09783 10.9942 2.41453L4.03676 5.89316C3.27449 6.27429 2.79297 7.05339 2.79297 7.90563V16.0946C2.79297 16.9468 3.27448 17.7259 4.03676 18.1071L10.9942 21.5857L11.3296 20.9149L10.9942 21.5857C11.6277 21.9024 12.3732 21.9024 13.0066 21.5857L19.9641 18.1071C20.7264 17.7259 21.2079 16.9468 21.2079 16.0946V7.90563C21.2079 7.05339 20.7264 6.27429 19.9641 5.89316L13.0066 2.41453Z',
                             fill: 'currentColor'),
                  class: 'menu-item-icon w-6 h-6 fill-current',
                  width: '24',
                  height: '24',
                  viewBox: '0 0 24 24',
                  fill: 'none',
                  xmlns: 'http://www.w3.org/2000/svg')
    end
  end
end
