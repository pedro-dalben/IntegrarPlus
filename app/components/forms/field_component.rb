# frozen_string_literal: true

module Forms
  class FieldComponent < ViewComponent::Base
    include FormErrorHelper

    def initialize(form:, field:, label:, type: :text, required: false, placeholder: nil, options: {},
                   wrapper_class: nil, stimulus_controller: nil, stimulus_data: {})
      @form = form
      @field = field
      @label = label
      @type = type
      @required = required
      @placeholder = placeholder
      @options = options
      @wrapper_class = wrapper_class
      @stimulus_controller = stimulus_controller
      @stimulus_data = stimulus_data
    end

    def render?
      @form.present? && @field.present?
    end

    private

    attr_reader :form, :field, :label, :type, :required, :placeholder, :options, :wrapper_class, :stimulus_controller,
                :stimulus_data

    def object
      @object ||= form.object
    end

    def has_error?
      field_has_error?(object, field)
    end

    def error_message
      field_error_message(object, field)
    end

    def base_input_classes
      "dark:bg-dark-900 shadow-theme-xs #{field_error_class(object,
                                                            field)} h-11 w-full rounded-lg border bg-transparent px-4 #{if has_error?
                                                                                                                          'pr-10'
                                                                                                                        end} py-2.5 text-sm text-gray-800 placeholder:text-gray-400 focus:ring-3 focus:outline-hidden dark:bg-gray-900 dark:text-white/90 dark:placeholder:text-white/30"
    end

    def input_classes
      [base_input_classes, options[:class]].compact.join(' ')
    end

    def label_text
      "#{label}#{' *' if required}"
    end

    def container_classes
      classes = ['relative']
      classes << stimulus_controller if stimulus_controller.present?
      classes.join(' ')
    end

    def container_data_attributes
      return {} if stimulus_controller.blank?

      attributes = { controller: stimulus_controller }
      stimulus_data.each do |key, value|
        attributes[:"#{stimulus_controller.tr('-', '_')}_#{key}"] = value
      end
      attributes
    end

    def input_options
      opts = {
        class: input_classes,
        placeholder: placeholder,
        required: required
      }

      if stimulus_controller.present? && stimulus_data[:target].present?
        opts[:data] = { "#{stimulus_controller.tr('-', '_')}_target": stimulus_data[:target] }
      end

      opts.merge(options.except(:class))
    end

    def error_icon_html
      return ''.html_safe unless has_error?

      content_tag(:span, class: 'absolute top-1/2 right-3.5 -translate-y-1/2') do
        content_tag(:svg, width: '16', height: '16', viewBox: '0 0 16 16', fill: 'none',
                          xmlns: 'http://www.w3.org/2000/svg') do
          tag.path(
            'fill-rule': 'evenodd',
            'clip-rule': 'evenodd',
            d: 'M2.58325 7.99967C2.58325 5.00813 5.00838 2.58301 7.99992 2.58301C10.9915 2.58301 13.4166 5.00813 13.4166 7.99967C13.4166 10.9912 10.9915 13.4163 7.99992 13.4163C5.00838 13.4163 2.58325 10.9912 2.58325 7.99967ZM7.99992 1.08301C4.17995 1.08301 1.08325 4.17971 1.08325 7.99967C1.08325 11.8196 4.17995 14.9163 7.99992 14.9163C11.8199 14.9163 14.9166 11.8196 14.9166 7.99967C14.9166 4.17971 11.8199 1.08301 7.99992 1.08301ZM7.09932 5.01639C7.09932 5.51345 7.50227 5.91639 7.99932 5.91639H7.99999C8.49705 5.91639 8.89999 5.51345 8.89999 5.01639C8.89999 4.51933 8.49705 4.11639 7.99999 4.11639H7.99932C7.50227 4.11639 7.09932 4.51933 7.09932 5.01639ZM7.99998 11.8306C7.58576 11.8306 7.24998 11.4948 7.24998 11.0806V7.29627C7.24998 6.88206 7.58576 6.54627 7.99998 6.54627C8.41419 6.54627 8.74998 6.88206 8.74998 7.29627V11.0806C8.74998 11.4948 8.41419 11.8306 7.99998 11.8306Z',
            fill: '#F04438'
          )
        end
      end
    end
  end
end
