# frozen_string_literal: true

module PortalIntakeComponents
  class TimelineComponent < ViewComponent::Base
    def initialize(journey_events:)
      @journey_events = journey_events
    end

    private

    attr_reader :journey_events

    def icon_class_for(event_type)
      case event_type
      when 'created'
        'text-blue-500'
      when 'scheduled_anamnesis'
        'text-green-500'
      when 'finished_anamnesis'
        'text-purple-500'
      when 'cancelled_anamnesis'
        'text-red-500'
      when 'rescheduled_anamnesis'
        'text-yellow-500'
      else
        'text-gray-500'
      end
    end

    def icon_svg_for(event_type)
      case event_type
      when 'created'
        plus_circle_icon
      when 'scheduled_anamnesis'
        calendar_icon
      when 'finished_anamnesis'
        check_circle_icon
      when 'cancelled_anamnesis'
        x_circle_icon
      when 'rescheduled_anamnesis'
        calendar_icon
      else
        circle_icon
      end
    end

    def plus_circle_icon
      content_tag :svg, class: 'h-5 w-5', fill: 'currentColor', viewBox: '0 0 20 20' do
        content_tag :path, '', 'fill-rule': 'evenodd',
                               d: 'M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z', 'clip-rule': 'evenodd'
      end
    end

    def calendar_icon
      content_tag :svg, class: 'h-5 w-5', fill: 'currentColor', viewBox: '0 0 20 20' do
        content_tag :path, '', 'fill-rule': 'evenodd',
                               d: 'M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z', 'clip-rule': 'evenodd'
      end
    end

    def check_circle_icon
      content_tag :svg, class: 'h-5 w-5', fill: 'currentColor', viewBox: '0 0 20 20' do
        content_tag :path, '', 'fill-rule': 'evenodd',
                               d: 'M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z', 'clip-rule': 'evenodd'
      end
    end

    def circle_icon
      content_tag :svg, class: 'h-5 w-5', fill: 'currentColor', viewBox: '0 0 20 20' do
        content_tag :circle, '', cx: '10', cy: '10', r: '4'
      end
    end

    def x_circle_icon
      content_tag :svg, class: 'h-5 w-5', fill: 'currentColor', viewBox: '0 0 20 20' do
        content_tag :path, '', 'fill-rule': 'evenodd',
                               d: 'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z', 'clip-rule': 'evenodd'
      end
    end
  end
end
