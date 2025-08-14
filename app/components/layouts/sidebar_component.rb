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
                  # Desktop sidebar
                  content_tag(:aside, class: sidebar_classes) do
                    content_tag(:div, class: 'flex items-center gap-2 pt-8 pb-7 sidebar-header') do
                      link_to('/admin', class: 'flex items-center') do
                        content_tag(:span, 'IntegrarPlus', class: 'text-xl font-semibold')
                      end
                    end +
                      content_tag(:div,
                                  class: 'flex flex-col overflow-y-auto duration-300 ease-linear no-scrollbar') do
                        content_tag(:nav, data: { controller: 'sidebar-nav' }) do
                          render_menu_groups
                        end
                      end
                  end,
                  # Mobile sidebar
                  mobile_sidebar_html
                ])
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
              content_tag(:div,
                          class: 'flex flex-col overflow-y-auto duration-300 ease-linear no-scrollbar h-full pb-8') do
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
                             class: "overflow-hidden #{expanded ? 'block' : 'hidden'}",
                             data: { accordion_target: 'panel' }) do
        content_tag(:ul, class: 'flex flex-col gap-1 mt-2 menu-dropdown') do
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
  end
end
