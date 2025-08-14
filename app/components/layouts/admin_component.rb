# frozen_string_literal: true

module Layouts
  class AdminComponent < ViewComponent::Base
    include ApplicationHelper

    renders_one :actions

    def initialize(title:, breadcrumbs: nil, hide_sidebar: false)
      @title = title
      @breadcrumbs = breadcrumbs || []
      @hide_sidebar = hide_sidebar
    end

    def call
      content_tag :div, class: 'min-h-screen bg-white text-gray-900', data: { controller: 'sidebar' } do
        safe_join([
          (@hide_sidebar ? nil : render(Layouts::SidebarComponent.new(current_professional: helpers.current_user))),
          content_tag(:div, class: 'lg:pl-[290px]') do
            safe_join([
                        render(Layouts::TopbarComponent.new(current_professional: helpers.current_user, title: @title,
                                                            breadcrumbs: @breadcrumbs)),
                        content_tag(:main, class: 'pt-16') do
                          content_tag(:div, class: 'container-app py-6') do
                            safe_join([
                                        render_flash,
                                        render_breadcrumbs,
                                        content_tag(:div,
                                                    class: 'flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6 gap-4') do
                                          safe_join([
                                                      content_tag(:h1, @title,
                                                                  class: 'text-2xl sm:text-3xl font-semibold'),
                                                      (if actions
                                                         content_tag(:div, actions,
                                                                     class: 'flex items-center gap-2')
                                                       else
                                                         ''
                                                       end)
                                                    ])
                                        end,
                                        content
                                      ])
                          end
                        end,
                        render(Layouts::FooterComponent.new)
                      ])
          end
        ].compact)
      end
    end

    private

    def render_flash
      return '' if flash.empty?

      content_tag :div, class: 'space-y-3 mb-6' do
        flash.map do |type, message|
          render_alert_component(type, message)
        end.join.html_safe
      end
    end

    def render_alert_component(type, message)
      kind = case type.to_s
             when 'notice', 'success' then :success
             when 'alert', 'error', 'danger' then :danger
             when 'warning' then :warning
             else :info
             end

      alert_classes = case kind
                      when :success
                        'border border-success-200 bg-success-50 text-success-800 dark:border-success-800/30 dark:bg-success-800/10 dark:text-success-400'
                      when :danger
                        'border border-red-200 bg-red-50 text-red-800 dark:border-red-800/30 dark:bg-red-800/10 dark:text-red-400'
                      when :warning
                        'border border-yellow-200 bg-yellow-50 text-yellow-800 dark:border-yellow-800/30 dark:bg-yellow-800/10 dark:text-yellow-400'
                      else
                        'border border-blue-200 bg-blue-50 text-blue-800 dark:border-blue-800/30 dark:bg-blue-800/10 dark:text-blue-400'
                      end

      content_tag(:div, class: "rounded-xl p-4 #{alert_classes}") do
        content_tag(:div, class: 'flex items-start gap-3') do
          safe_join([
                      alert_icon(kind),
                      content_tag(:div, class: 'flex-1') do
                        content_tag(:p, message, class: 'text-sm font-medium')
                      end
                    ])
        end
      end
    end

    def alert_icon(kind)
      icon_color = case kind
                   when :success then 'text-success-500'
                   when :danger then 'text-red-500'
                   when :warning then 'text-yellow-500'
                   else 'text-blue-500'
                   end

      path = case kind
             when :success
               'M9 12l2 2 4-4M21 12c0 4.97-4.03 9-9 9s-9-4.03-9-9 4.03-9 9-9 9 4.03 9 9z'
             when :danger
               'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-2.694-.833-3.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z'
             when :warning
               'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-2.694-.833-3.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z'
             else
               'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
             end

      content_tag(:div, class: "-mt-0.5 #{icon_color}") do
        content_tag(:svg,
                    content_tag(:path, '',
                                d: path,
                                stroke: 'currentColor',
                                'stroke-width': '2',
                                'stroke-linecap': 'round',
                                'stroke-linejoin': 'round'),
                    class: 'w-5 h-5',
                    fill: 'none',
                    viewBox: '0 0 24 24')
      end
    end

    def render_breadcrumbs
      return '' if @breadcrumbs.blank?

      content_tag :nav, aria: { label: 'Breadcrumb' }, class: 'mb-4' do
        content_tag :ol, class: 'flex flex-wrap items-center gap-2 text-sm text-muted' do
          safe_join(
            @breadcrumbs.map.with_index do |crumb, idx|
              is_last = idx == @breadcrumbs.length - 1
              label = crumb[:label] || crumb[0]
              path = crumb[:path] || crumb[1]
              if is_last || path.blank?
                content_tag(:li, label, class: 'text-fg')
              else
                content_tag(:li) do
                  link_to(label, path, class: 'hover:underline')
                end
              end
            end
          )
        end
      end
    end
  end
end
