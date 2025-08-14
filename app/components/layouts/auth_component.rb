# frozen_string_literal: true

module Layouts
  class AuthComponent < ViewComponent::Base
    def initialize(title: 'Entrar')
      @title = title
    end

    def call
      content_tag :div, class: 'min-h-screen flex items-center justify-center bg-gray-50' do
        content_tag :div, class: 'w-full max-w-md bg-white rounded-2xl border p-8',
                          style: 'border-color: rgba(15, 23, 42, 0.06)' do
          safe_join([
                      content_tag(:div, class: 'flex items-center justify-center mb-6') do
                        content_tag(:span, 'IP', class: 'size-10 grid place-content-center rounded-xl text-white',
                                                 style: 'background: #3641f5')
                      end,
                      content_tag(:h1, @title, class: 'text-center text-2xl font-semibold mb-6'),
                      content
                    ])
        end
      end
    end
  end
end
