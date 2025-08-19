# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def permit?(_permission_key)
    true
  end

  def pagy_nav(pagy)
    html = +'<nav class="flex items-center gap-2">'

    if pagy.prev
      html << link_to('&laquo; Primeira', pagy_url_for(pagy, 1),
                      class: 'px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-gray-300')
    end

    if pagy.prev
      html << link_to('&lsaquo; Anterior', pagy_url_for(pagy, pagy.prev),
                      class: 'px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-gray-300')
    end

    pagy.series.each do |item|
      if item.is_a?(Integer) || item.to_s.match?(/^\d+$/)
        page_number = item.to_i
        if page_number == pagy.page
          html << content_tag(:span, item,
                              class: 'px-3 py-2 text-sm font-medium text-white bg-blue-600 border border-blue-600 rounded-lg')
        else
          html << link_to(item, pagy_url_for(pagy, page_number),
                          class: 'px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-gray-300')
        end
      elsif item == :gap
        html << content_tag(:span, '...', class: 'px-3 py-2 text-sm font-medium text-gray-500')
      end
    end

    if pagy.next
      html << link_to('Próxima &rsaquo;', pagy_url_for(pagy, pagy.next),
                      class: 'px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-gray-300')
    end

    if pagy.next
      html << link_to('Última &raquo;', pagy_url_for(pagy, pagy.last),
                      class: 'px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-gray-300')
    end

    html << '</nav>'
    html.html_safe
  end
end
