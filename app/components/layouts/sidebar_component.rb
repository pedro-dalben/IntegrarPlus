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
      safe_join([
                  # Overlay para mobile
                  content_tag(:div, '',
                              class: 'fixed inset-0 z-40 bg-black/50 lg:hidden',
                              ':class': 'sidebarToggle ? "block" : "hidden"',
                              '@click': 'sidebarToggle = false'),
                  # Sidebar
                  content_tag(:aside,
                              ':class': "sidebarToggle ? 'translate-x-0 lg:w-[90px]' : '-translate-x-full'",
                              class: 'sidebar fixed left-0 top-0 z-9999 flex h-screen w-[290px] flex-col overflow-y-hidden border-r border-gray-200 bg-white px-5 duration-300 ease-linear lg:static lg:translate-x-0 dark:bg-gray-800 dark:border-gray-700',
                              '@click.outside': 'sidebarToggle = false') do
                    content_tag(:div,
                                class: 'flex items-center gap-2 pt-8 pb-7 sidebar-header',
                                ':class': 'sidebarToggle ? "justify-center" : "justify-between"') do
                      link_to('/admin', class: 'flex items-center') do
                        content_tag(:span, 'IntegrarPlus',
                                    class: 'text-xl font-semibold dark:text-white',
                                    ':class': 'sidebarToggle ? "lg:hidden" : ""')
                      end
                    end +
                      content_tag(:div,
                                  class: 'flex flex-col overflow-y-auto duration-300 ease-linear no-scrollbar') do
                        content_tag(:nav) do
                          render_menu_groups
                        end
                      end
                  end
                ])
    end

    private

    def render_menu_groups
      safe_join([
                  render_menu_group('MENU', main_menu_items)
                ])
    end

    def render_menu_group(title, items)
      content_tag(:div, class: 'mb-6') do
        content_tag(:h3, title,
                    class: 'mb-4 text-xs uppercase leading-[20px] text-gray-400',
                    ':class': 'sidebarToggle ? "lg:hidden" : ""') +
          content_tag(:ul, class: 'flex flex-col gap-4') do
            safe_join(items.map { |item| render_menu_item(item) })
          end
      end
    end

    def main_menu_items
      AdminNav.items.map do |item|
        {
          label: item[:label],
          path: item[:path] || '#',
          icon: icon_for(item[:icon]),
          active: item_active?(item),
          children: item[:children]&.map do |child|
            {
              label: child[:label],
              path: child[:path],
              active: current_path.start_with?(child[:path])
            }
          end
        }
      end
    end

    def other_menu_items
      []
    end

    def item_active?(item)
      return true if item[:path] == '/admin' && current_path == '/admin'
      return true if item[:path] && current_path.start_with?(item[:path])
      return true if item[:children]&.any? { |child| current_path.start_with?(child[:path]) }

      false
    end

    def icon_for(icon_class)
      content_tag(:i, '', class: "#{icon_class} menu-item-icon w-6 h-6")
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
      item[:active] || current_path.start_with?(item[:path])

      content_tag(:li) do
        link_to(item[:path],
                class: 'menu-item group',
                ':class': "(page === '#{current_page}') ? 'menu-item-active' : 'menu-item-inactive'") do
          safe_join([
                      item[:icon],
                      content_tag(:span, item[:label],
                                  class: 'menu-item-text',
                                  ':class': 'sidebarToggle ? "lg:hidden" : ""')
                    ])
        end
      end
    end

    def render_menu_item_with_dropdown(item)
      expanded = item[:children]&.any? { |child| current_path.start_with?(child[:path]) }
      expanded || (item[:active] || false)

      content_tag(:li) do
        content_tag(:a,
                    href: '#',
                    '@click.prevent': "selected = (selected === '#{item[:label]}' ? '' : '#{item[:label]}')",
                    class: 'menu-item group',
                    ':class': "(selected === '#{item[:label]}') ? 'menu-item-active' : 'menu-item-inactive'") do
          safe_join([
                      item[:icon],
                      content_tag(:span, item[:label],
                                  class: 'menu-item-text',
                                  ':class': 'sidebarToggle ? "lg:hidden" : ""'),
                      dropdown_arrow(item)
                    ])
        end +
          content_tag(:div,
                      class: 'translate transform overflow-hidden',
                      ':class': "(selected === '#{item[:label]}') ? 'block' : 'hidden'") do
            content_tag(:ul,
                        class: 'menu-dropdown mt-2 flex flex-col gap-1 pl-9',
                        ':class': 'sidebarToggle ? "lg:hidden" : "flex"') do
              safe_join(item[:children].map { |child| render_dropdown_item(child) })
            end
          end
      end
    end

    def render_dropdown_item(item)
      current_path.start_with?(item[:path])

      content_tag(:li) do
        link_to(item[:path],
                class: 'menu-dropdown-item group',
                ':class': "page === '#{current_page}' ? 'menu-dropdown-item-active' : 'menu-dropdown-item-inactive'") do
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

    def dropdown_arrow(item)
      content_tag(:svg,
                  content_tag(:path, '',
                              d: 'M4.79175 7.39584L10.0001 12.6042L15.2084 7.39585',
                              stroke: 'currentColor',
                              'stroke-width': '1.5',
                              'stroke-linecap': 'round',
                              'stroke-linejoin': 'round'),
                  class: 'menu-item-arrow',
                  ':class': "[(selected === '#{item[:label]}') ? 'menu-item-arrow-active' : 'menu-item-arrow-inactive']",
                  width: '20',
                  height: '20',
                  viewBox: '0 0 20 20',
                  fill: 'none',
                  xmlns: 'http://www.w3.org/2000/svg')
    end

    def current_path
      helpers.request.fullpath
    end

    def current_page
      path = helpers.request.path
      case path
      when '/admin'
        'dashboard'
      when '/admin/professionals'
        'profissionais'
      when '/admin/contract_types'
        'formas de contratação'
      when '/admin/specialities'
        'especialidades'
      when '/admin/specializations'
        'especializações'
      else
        'dashboard'
      end
    end
  end
end
