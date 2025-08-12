# frozen_string_literal: true

module Layouts
  class TopbarComponent < ViewComponent::Base
    def initialize(current_professional: nil, title: nil, breadcrumbs: nil)
      super()
      @current_professional = current_professional
      @title = title
      @breadcrumbs = breadcrumbs || []
    end

    def call
      content_tag :header, class: 'sticky top-0 z-50 bg-white/80 dark:bg-gray-900/80 backdrop-blur border-b',
                           style: 'border-color: rgb(var(--t-fg) / 0.06)' do
        content_tag :div, class: 'container-app h-16 flex items-center gap-3 justify-between' do
          safe_join([
                      content_tag(:div, class: 'flex items-center gap-3 min-w-0') do
                        safe_join([
                                                        content_tag(:button,
                                class: 'inline-flex items-center justify-center size-9 rounded-lg hover:bg-gray-100 dark:hover:bg-white/5 lg:hidden', 
                                data: { 
                                  action: 'click->sidebar#open',
                                  sidebar_target: 'trigger'
                                }) do
                      content_tag(:span, 'Menu', class: 'sr-only') + 
                      content_tag(:svg, 
                                  content_tag(:path, '', 
                                             d: 'M4 6h16M4 12h16M4 18h16',
                                             stroke: 'currentColor',
                                             'stroke-width': '2',
                                             'stroke-linecap': 'round',
                                             'stroke-linejoin': 'round'),
                                  class: 'size-5',
                                  fill: 'none',
                                  viewBox: '0 0 24 24')
                    end,
                                    content_tag(:div, class: 'flex items-center gap-3 min-w-0') do
                                      safe_join([
                                                  content_tag(:div,
                                                              class: 'hidden sm:block text-gray-500 text-sm truncate') do
                                                    safe_join(render_breadcrumbs_inline)
                                                  end,
                                                  content_tag(:div, @title || '',
                                                              class: 'text-xl md:text-2xl font-semibold tracking-tight truncate')
                                                ])
                                    end
                                  ])
                      end,
                      content_tag(:div, class: 'flex items-center gap-3') do
                        safe_join([
                                    content_tag(:div, class: 'relative hidden sm:block') do
                                      content_tag(:span, '',
                                                  class: 'pointer-events-none absolute inset-y-0 left-0 grid place-items-center w-9 text-gray-400') +
                                      tag.input(type: :search, placeholder: 'Buscar...', class: 'h-9 rounded-lg border pl-9 pr-3 text-sm',
                                                style: 'border-color: rgb(var(--t-fg) / 0.12); background: var(--color-surface)')
                                    end,
                                    user_dropdown
                                  ])
                      end
                    ])
        end
      end
    end

    private

    def render_breadcrumbs_inline
      return [] if @breadcrumbs.blank?

      @breadcrumbs.map.with_index do |crumb, idx|
        is_last = idx == @breadcrumbs.length - 1
        label = crumb[:label] || crumb[0]
        path = crumb[:path] || crumb[1]
        if is_last || path.blank?
          content_tag(:span, label, class: 'text-gray-500', aria: { current: 'page' })
        else
          safe_join([
                      link_to(label, path, class: 'text-gray-500 hover:underline'),
                      content_tag(:span, '›', class: 'px-1 text-gray-400')
                    ])
        end
      end
    end

    def user_dropdown
      content_tag(:div, class: 'relative', data: { controller: 'menu' }) do
        content_tag(:button,
                    class: 'inline-flex items-center gap-2 rounded-lg px-2.5 py-1.5 hover:bg-gray-100 dark:hover:bg-white/5', aria: { haspopup: 'menu', expanded: 'false' }, data: { action: 'click->menu#toggle' }) do
          avatar = content_tag(:div, initials_for(@current_professional&.try(:full_name)) || 'US',
                               class: 'h-8 w-8 rounded-full grid place-content-center bg-brand-50 text-brand-600 text-sm font-medium relative')
          text_block = content_tag(:div, class: 'hidden lg:flex flex-col items-start leading-tight') do
            content_tag(:span, @current_professional&.try(:full_name) || 'Usuário',
                        class: 'text-sm font-semibold text-fg') +
              content_tag(:span, @current_professional&.try(:email) || '', class: 'text-xs text-gray-500')
          end
          avatar + text_block
        end +
          content_tag(:div,
                      class: 'absolute right-0 mt-2 w-56 rounded-xl border bg-white dark:bg-gray-800 shadow-xl hidden', data: { menu_target: 'panel' }, style: 'border-color: rgb(var(--t-fg) / 0.06)') do
            safe_join([
                        link_to('Meu Perfil', '#',
                                class: 'block px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-white/5'),
                        button_to('Sair', destroy_user_session_path,
                                  method: :delete,
                                  data: { turbo_confirm: 'Tem certeza que deseja sair?' },
                                  class: 'block w-full text-left px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-white/5 border-none bg-transparent',
                                  form: { class: 'block w-full' })
                      ])
          end
      end
    end

    def initials_for(name)
      return 'US' if name.blank?

      name.split(/\s+/).first(2).pluck(0).join.upcase
    end
  end
end
