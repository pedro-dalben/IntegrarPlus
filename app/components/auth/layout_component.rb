# frozen_string_literal: true

module Auth
  class LayoutComponent < ViewComponent::Base
    def initialize(title: 'Entrar', subtitle: 'Acesse sua conta para gerenciar atendimentos e serviços da clínica')
      @title = title
      @subtitle = subtitle
    end

    def call
      content_tag :div, class: 'login-container' do
        safe_join([
                    sidebar,
                    main_content
                  ])
      end
    end

    private

    def sidebar
      content_tag :div, class: 'login-sidebar' do
        content_tag :div, class: 'login-gradient' do
          content_tag :div, class: 'login-overlay' do
            content_tag :div, class: 'login-content' do
              safe_join([
                          content_tag(:div, class: 'mb-8') do
                            content_tag(:h1, 'Integrar+', class: 'login-title')
                          end,
                          content_tag(:p, 'Plataforma de gestão da clínica Integrar, referência em atendimento multidisciplinar e cuidado humanizado.',
                                      class: 'login-subtitle'),
                          content_tag(:div, class: 'login-features') do
                            safe_join([
                                        feature_item('Atendimento Integrado',
                                                     'Equipe multidisciplinar com foco no cuidado personalizado'),
                                        feature_item('Gestão Eficiente',
                                                     'Organize agendas, prontuários e faturamento em um só lugar'),
                                        feature_item('Qualidade Certificada',
                                                     'Clínica acreditada ONA Nível 1 em segurança e assistência')
                                      ])
                          end
                        ])
            end
          end
        end
      end
    end

    def feature_item(title, description)
      content_tag :div, class: 'login-feature' do
        safe_join([
                    content_tag(:div, class: 'login-feature-icon') do
                      content_tag(:svg, fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24') do
                        content_tag(:path, '', 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2',
                                               d: 'M5 13l4 4L19 7')
                      end
                    end,
                    content_tag(:div, class: 'login-feature-text') do
                      safe_join([
                                  content_tag(:h3, title),
                                  content_tag(:p, description)
                                ])
                    end
                  ])
      end
    end

    def main_content
      content_tag :div, class: 'login-main' do
        content_tag :div, class: 'login-form-container' do
          safe_join([
                      header,
                      content_tag(:div, class: 'login-form-content') do
                        content
                      end
                    ])
        end
      end
    end

    def header
      content_tag :div, class: 'login-header' do
        safe_join([
                    content_tag(:div, class: 'login-logo') do
                      helpers.image_tag('logo.png',
                                        alt: 'Integrar+ Logo')
                    end,
                    content_tag(:h1, @title, class: 'login-form-title'),
                    content_tag(:p, @subtitle, class: 'login-form-subtitle')
                  ])
      end
    end
  end
end
