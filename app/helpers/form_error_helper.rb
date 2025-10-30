# frozen_string_literal: true

module FormErrorHelper
  def field_error_class(object, field)
    if object.errors[field].any?
      'border-error-300 dark:border-error-700 focus:border-error-300 dark:focus:border-error-800 focus:ring-error-500/10'
    else
      'border-gray-300 dark:border-gray-700 focus:border-brand-300 dark:focus:border-brand-800 focus:ring-brand-500/10'
    end
  end

  def field_has_error?(object, field)
    object.errors[field].any?
  end

  def field_error_message(object, field)
    return nil unless object.errors[field].any?

    object.errors[field].first
  end

  def render_field_error_icon
    render partial: 'shared/field_error_icon'
  end

  def render_field_error_message(object, field)
    return ''.html_safe unless field_has_error?(object, field)

    content_tag(:p, field_error_message(object, field),
                class: 'text-xs text-error-500 dark:text-error-400 mt-1.5')
  end
end
