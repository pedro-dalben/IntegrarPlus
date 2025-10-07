# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend
  include SecurityHelper

  def generate_pagination_series(pagy)
    return [] if pagy.pages <= 1

    series = []
    current_page = pagy.page
    total_pages = pagy.pages

    # Sempre mostrar primeira página
    series << 1

    # Adicionar gap se necessário
    series << :gap if current_page > 4

    # Páginas ao redor da página atual
    start_page = [2, current_page - 1].max
    end_page = [total_pages - 1, current_page + 1].min

    (start_page..end_page).each do |page|
      series << page if page > 1 && page < total_pages
    end

    # Adicionar gap se necessário
    series << :gap if current_page < total_pages - 3

    # Sempre mostrar última página
    series << total_pages if total_pages > 1

    series
  end

  def pagy_nav(pagy)
    html = +'<nav class="flex items-center justify-center gap-2">'

    series = if pagy.respond_to?(:series)
               pagy.series
             else
               generate_pagination_series(pagy)
             end

    if pagy.prev
      html << link_to('« Primeira', build_pagy_url(pagy, 1),
                      class: 'px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-900 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white transition-colors')
    end

    if pagy.prev
      html << link_to('‹ Anterior', build_pagy_url(pagy, pagy.prev),
                      class: 'px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-900 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white transition-colors')
    end

    series.each do |item|
      if item.is_a?(Integer) || item.to_s.match?(/^\d+$/)
        page_number = item.to_i
        if page_number == pagy.page
          html << content_tag(:span, item,
                              class: 'px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-blue-600 rounded-lg shadow-sm')
        else
          html << link_to(item, build_pagy_url(pagy, page_number),
                          class: 'px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-900 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white transition-colors')
        end
      elsif item == :gap
        html << content_tag(:span, '...', class: 'px-2 py-2 text-sm font-medium text-gray-400')
      end
    end

    if pagy.next
      html << link_to('Próxima ›', build_pagy_url(pagy, pagy.next),
                      class: 'px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-900 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white transition-colors')
    end

    if pagy.next
      html << link_to('Última »', build_pagy_url(pagy, pagy.pages),
                      class: 'px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:text-gray-900 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white transition-colors')
    end

    html << '</nav>'
    html.html_safe
  end

  def build_pagy_url(_pagy, page)
    # Preservar todos os parâmetros exceto a página
    params = request.query_parameters.except(:page)
    params[:page] = page
    url_for(params)
  end
end
