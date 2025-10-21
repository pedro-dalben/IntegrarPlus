# frozen_string_literal: true

module Ui
  class BreadcrumbComponent < ViewComponent::Base
    def initialize(current_path: nil)
      @current_path = current_path || request.path
    end

    def before_render
      @breadcrumbs = generate_breadcrumbs
    end

    private

    def generate_breadcrumbs
      breadcrumbs = []

      breadcrumbs << { name: t('admin.breadcrumb.home'), path: '/admin', active: false }

      path_parts = @current_path.split('/').reject(&:empty?)

      path_parts.shift if path_parts.first == 'admin'

      if path_parts.empty?
        breadcrumbs << { name: t('admin.breadcrumb.dashboard'), path: nil, active: true }
        return breadcrumbs
      end

      # Analisar o path para determinar a estrutura
      case path_parts.length
      when 1
        # /admin/resource - página de índice
        resource_name = path_parts[0].singularize
        breadcrumbs << {
          name: get_page_title(resource_name, 'index'),
          path: nil,
          active: true
        }
      when 2
        if path_parts[1].match?(/^\d+$/)
          # /admin/resource/123 - página de visualização
          resource_name = path_parts[0].singularize
          breadcrumbs << {
            name: t("admin.breadcrumb.#{resource_name}", default: resource_name&.humanize),
            path: "/admin/#{path_parts[0]}",
            active: false
          }
          breadcrumbs << {
            name: get_page_title(resource_name, 'show'),
            path: nil,
            active: true
          }
        elsif %w[new edit].include?(path_parts[1])
          # /admin/resource/new ou /admin/resource/edit
          resource_name = path_parts[0].singularize
          breadcrumbs << {
            name: t("admin.breadcrumb.#{resource_name}", default: resource_name&.humanize),
            path: "/admin/#{path_parts[0]}",
            active: false
          }
          breadcrumbs << {
            name: get_page_title(resource_name, path_parts[1]),
            path: nil,
            active: true
          }
        end
      when 3
        if path_parts[1].match?(/^\d+$/) && %w[new edit].include?(path_parts[2])
          # /admin/resource/123/edit ou /admin/resource/123/new
          resource_name = path_parts[0].singularize
          breadcrumbs << {
            name: t("admin.breadcrumb.#{resource_name}", default: resource_name&.humanize),
            path: "/admin/#{path_parts[0]}",
            active: false
          }
          breadcrumbs << {
            name: get_page_title(resource_name, path_parts[2]),
            path: nil,
            active: true
          }
        end
      end

      breadcrumbs
    end

    def get_page_title(resource_name, action)
      return 'Página' unless resource_name

      t("admin.pages.#{resource_name}.#{action}.title",
        default: t("admin.pages.#{resource_name}.index.title",
                   default: resource_name.humanize))
    end

    def get_page_subtitle(resource_name, action)
      return '' unless resource_name

      t("admin.pages.#{resource_name}.#{action}.subtitle",
        default: t("admin.pages.#{resource_name}.index.subtitle",
                   default: ''))
    end

    def current_page_title
      path_parts = @current_path.split('/').reject(&:empty?)
      path_parts.shift if path_parts.first == 'admin'

      return t('admin.pages.dashboard.title') if path_parts.empty?

      resource_name = nil
      action = 'index'

      path_parts.each_with_index do |part, index|
        if part.match?(/^\d+$/)
          resource_name = path_parts[index - 1]&.singularize
          action = path_parts[index + 1] || 'show'
          break
        elsif %w[new edit].include?(part)
          resource_name = path_parts[index - 1]&.singularize
          action = part
          break
        else
          resource_name = part.singularize
        end
      end

      get_page_title(resource_name, action)
    end

    def current_page_subtitle
      path_parts = @current_path.split('/').reject(&:empty?)
      path_parts.shift if path_parts.first == 'admin'

      return t('admin.pages.dashboard.subtitle') if path_parts.empty?

      resource_name = nil
      action = 'index'

      path_parts.each_with_index do |part, index|
        if part.match?(/^\d+$/)
          resource_name = path_parts[index - 1]&.singularize
          action = path_parts[index + 1] || 'show'
          break
        elsif %w[new edit].include?(part)
          resource_name = path_parts[index - 1]&.singularize
          action = part
          break
        else
          resource_name = part.singularize
        end
      end

      get_page_subtitle(resource_name, action)
    end
  end
end
