class Ui::BreadcrumbComponent < ViewComponent::Base
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

    current_path = '/admin'

    path_parts.each_with_index do |part, index|
      current_path += "/#{part}"

      if part.match?(/^\d+$/)
        resource_name = path_parts[index - 1]&.singularize
        action = path_parts[index + 1] || 'show'

        breadcrumbs << {
          name: t("admin.breadcrumb.#{resource_name}", default: resource_name&.humanize),
          path: "/admin/#{path_parts[0..index - 1].join('/')}",
          active: false
        }

        breadcrumbs << {
          name: get_page_title(resource_name, action),
          path: nil,
          active: true
        }
        break
      elsif %w[new edit].include?(part)
        resource_name = path_parts[index - 1]&.singularize

        breadcrumbs << {
          name: t("admin.breadcrumb.#{resource_name}", default: resource_name&.humanize),
          path: "/admin/#{path_parts[0..index - 1].join('/')}",
          active: false
        }

        breadcrumbs << {
          name: get_page_title(resource_name, part),
          path: nil,
          active: true
        }
        break
      else
        resource_name = part.singularize

        breadcrumbs << if index == path_parts.length - 1
                         {
                           name: get_page_title(resource_name, 'index'),
                           path: nil,
                           active: true
                         }
                       else
                         {
                           name: t("admin.breadcrumb.#{resource_name}", default: resource_name&.humanize),
                           path: current_path,
                           active: false
                         }
                       end
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
