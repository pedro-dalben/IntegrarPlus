# frozen_string_literal: true

module Ui
  class DividerComponent < ViewComponent::Base
    def initialize(text: 'Ou', class_name: '')
      @text = text
      @class_name = class_name
    end

    def call
      content_tag :div, class: "relative #{@class_name}" do
        safe_join([
                    content_tag(:div, class: 'absolute inset-0 flex items-center') do
                      content_tag(:div, '', class: 'w-full border-t border-gray-300')
                    end,
                    content_tag(:div, class: 'relative flex justify-center text-sm') do
                      content_tag(:span, @text, class: 'px-2 bg-white text-gray-500')
                    end
                  ])
      end
    end
  end
end
